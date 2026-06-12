library(sf)
library(dplyr)
library(ggplot2)

# Read the Ukrainian refugee data
df <- read.csv("ukraine_refugees.csv")
df$total <- df$refugees + df$asylum_seekers

# Download and read country boundaries
if (!file.exists("ne_110m_countries.zip")) {
  download.file(
    "https://naciscdn.org/naturalearth/110m/cultural/ne_110m_admin_0_countries.zip",
    "ne_110m_countries.zip",
    mode = "wb"
  )
}
countries_shp <- st_read(
  "/vsizip/ne_110m_countries.zip/ne_110m_admin_0_countries.shp",
  quiet = TRUE
)

# Use ADM0_A3 for ISO codes
countries_shp$iso <- countries_shp$ADM0_A3

# All countries for background map
ne_all <- countries_shp

# Filter to countries in our dataset plus Ukraine
all_iso <- unique(c("UKR", df$iso_code))
countries <- countries_shp |>
  filter(iso %in% all_iso)

# Compute centroids
sf_use_s2(FALSE)
centroids <- st_centroid(countries)
locations <- data.frame(
  id = centroids$iso,
  lon = st_coordinates(centroids)[, 1],
  lat = st_coordinates(centroids)[, 2],
  stringsAsFactors = FALSE
)

# Ukraine centroid
ukr_loc <- locations |> filter(id == "UKR")

# Create frames for each year
years <- sort(unique(df$year))

dir.create("frames", showWarnings = FALSE)

for (yr in years) {
  message("Creating frame for year ", yr)

  # Data for this year
  yr_data <- df |>
    filter(year == yr, total > 0) |>
    inner_join(locations, by = c("iso_code" = "id"))

  if (nrow(yr_data) == 0) next

  max_count <- max(yr_data$total, na.rm = TRUE)

  p <- ggplot() +
    # Country boundaries as background
    geom_sf(data = ne_all, fill = "#2a2a2a", color = "#444444", linewidth = 0.1) +
    # Flow lines
    geom_curve(
      data = yr_data,
      aes(x = ukr_loc$lon[1], y = ukr_loc$lat[1],
          xend = lon, yend = lat,
          size = total, color = total),
      curvature = 0.1,
      alpha = 0.7
    ) +
    # Ukraine point
    geom_point(
      data = ukr_loc,
      aes(x = lon, y = lat),
      color = "#ff6b35",
      size = 4
    ) +
    scale_size_continuous(range = c(0.3, 3), guide = "none") +
    scale_color_gradient(
      low = "#ffd700",
      high = "#dc143c",
      name = "Refugees"
    ) +
    coord_sf(
      xlim = c(-25, 70),
      ylim = c(28, 62),
      expand = FALSE
    ) +
    labs(
      title = paste0("Refugee displacement from Ukraine — ", yr),
      subtitle = paste0("Total: ", format(sum(yr_data$total), big.mark = ","))
    ) +
    theme_void() +
    theme(
      plot.background = element_rect(fill = "#1a1a1a", color = NA),
      plot.title = element_text(color = "white", face = "bold", hjust = 0.5, size = 16),
      plot.subtitle = element_text(color = "#cccccc", hjust = 0.5, size = 12),
      legend.position = "bottom",
      legend.text = element_text(color = "white"),
      legend.title = element_text(color = "white")
    )

  ggsave(
    paste0("frames/frame_", yr, ".png"),
    plot = p,
    width = 10,
    height = 7,
    dpi = 100
  )
}

message("All frames created!")
