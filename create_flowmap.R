library(sf)
library(tidyverse)
message("You need to install the mapgl package from e-kotov.r-universe.dev...")
# install.packages('mapgl', repos = c('https://e-kotov.r-universe.dev', 'https://cloud.r-project.org'))
library(mapgl)
library(htmlwidgets)

# Read the Ukrainian refugee data
df <- read_csv("ukraine_refugees.csv")
df <- df |>
  filter(!is.na(iso_code)) |>
  transmute(
    origin = "UKR",
    dest = iso_code,
    count = refugees + asylum_seekers,
    year = year
  ) |>
  mutate(date = as.Date(paste0("2022-01-0", (year - 2021))))
# Download and read country boundaries
message("Downloading country boundaries...")
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

# Use ADM0_A3 for ISO codes (more reliable than ISO_A3 which has -99 for some)
countries_shp$iso <- countries_shp$ADM0_A3

# Filter to countries in our dataset plus Ukraine as origin
all_iso <- unique(c("UKR", df$dest))
countries <- countries_shp |>
  filter(iso %in% all_iso) |>
  select(iso_code = iso, name = NAME)

# Compute centroids in WGS84
sf_use_s2(FALSE)
centroids <- st_centroid(countries)
locations <- data.frame(
  id = centroids$iso_code,
  name = centroids$name,
  lon = st_coordinates(centroids)[, 1],
  lat = st_coordinates(centroids)[, 2]
)

message("Locations prepared: ", nrow(locations), " countries")

# Check for unmatched IDs
unmatched <- setdiff(unique(c(df$origin, df$dest)), locations$id)
if (length(unmatched) > 0) {
  message("Unmatched IDs (not in Natural Earth 110m): ", paste(unmatched, collapse = ", "))
  message("Percent of flows with unmatched IDs: ", round(sum(df$count[df$origin %in% unmatched | df$dest %in% unmatched]) / sum(df$count) * 100, 2), "%")
  # Filter these out
  df <- df |>
    filter(origin %in% locations$id, dest %in% locations$id)
}


# Aggregate flows across all years (total for each destination)
flows_agg <- df |>
  group_by(dest) |>
  summarise(count = sum(count, na.rm = TRUE), .groups = "drop") |>
  mutate(origin = "UKR") |>
  filter(count > 0)


message("Flows prepared: ", nrow(flows_agg), " destination countries")
message("Total flows: ", sum(flows_agg$count))

# Create the flow map using MapLibre (no API key needed)
m <- maplibre(
  style = carto_style("dark-matter"),
  center = c(25, 48),
  zoom = 3,
  projection = "mercator"
) |>
  add_flowmap(
    id = "ukraine-flows",
    locations = locations,
    flows = flows_agg,
    flow_color_scheme = "Inferno",
    flow_dark_mode = TRUE,
    flow_opacity = 0.8
  )
# Flowmap with timeline:
m2 <- maplibre(
  style = carto_style("dark-matter"),
  center = c(25, 48),
  zoom = 3,
  projection = "mercator"
) |>
  add_flowmap(
    id = "ukraine-flows",
    locations = locations,
    flows = df,
    flow_color_scheme = "Inferno",
    flow_dark_mode = TRUE,
    flow_opacity = 0.8
  ) |>
  add_time_control(
    data = df,
    time_column = "date",
    time_interval = "day",
    title = "Ukraine OD Flows"
  )

message("Saving as files/basic_flowmap.html...")
saveWidget(m2, "files/basic_flowmap.html", selfcontained = TRUE)
message("Done! Saved files/basic_flowmap.html")

m2
