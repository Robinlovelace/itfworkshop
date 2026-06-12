library(sf)
library(dplyr)
library(mapgl)
library(htmlwidgets)

# Read the Ukrainian refugee data
df <- read.csv("ukraine_refugees.csv")
df$total <- df$refugees + df$asylum_seekers

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
all_iso <- unique(c("UKR", df$iso_code))
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

# Aggregate flows across all years (total for each destination)
flows_agg <- df |>
  group_by(iso_code) |>
  summarise(count = sum(total, na.rm = TRUE), .groups = "drop") |>
  filter(count > 0) |>
  mutate(
    origin = "UKR",
    dest = iso_code
  ) |>
  select(origin, dest, count)

# Check for unmatched IDs
unmatched <- setdiff(unique(c(flows_agg$origin, flows_agg$dest)), locations$id)
if (length(unmatched) > 0) {
  message("Unmatched IDs (not in Natural Earth 110m): ", paste(unmatched, collapse = ", "))
  # Filter these out
  flows_agg <- flows_agg |>
    filter(origin %in% locations$id, dest %in% locations$id)
}

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

message("Saving as files/basic_flowmap.html...")
saveWidget(m, "files/basic_flowmap.html", selfcontained = TRUE)
message("Done! Saved files/basic_flowmap.html")
