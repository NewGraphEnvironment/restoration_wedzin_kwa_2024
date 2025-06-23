# create bii wenii study area

# lets build a custom watersehed just for upstream of the confluence of Neexdzii Kwa and Wetzin Kwa
# blueline key
blk <- 360819468
# downstream route measure
drm <- 51

aoi <- fwapgr::fwa_watershed_at_measure(blue_line_key = blk,
                                        downstream_route_measure = drm)


# burn to file
sf::st_write(aoi, "data/gis/skt/owen_ck_wshed.geojson",  delete_dsn = TRUE, append=FALSE)


# neexdzi kwa

blk <- 360873822
# downstream route measure
drm <- 166030.4

aoi <- fwapgr::fwa_watershed_at_measure(blue_line_key = blk,
                                        downstream_route_measure = drm)

# burn to file
sf::st_write(aoi, "data/gis/skt/upper_bulkley_wshed.geojson",  delete_dsn = TRUE, append=FALSE)


