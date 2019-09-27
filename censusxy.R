# remotes::install_github("slu-openGIS/censusxy")
library(readr)
library(magrittr)
library(censusxy)


murals <- read_csv("~/Downloads/murals.csv")

murals$city <- c("Baltimore")
murals$state <- c("MD")

murals %>% tail(n=20)

somemurals <- cxy_geocode(murals, address = address, city = city, state = state)

write_csv(murals,"mymurals.csv")
## Then, edit it a bit

murals <- read_csv("mymurals.csv")
somemurals <- cxy_geocode(murals, address = address, city = city, state = state)
View(somemurals)

library(rex)

endzip <- rex::regex(c("[0-9][0-9][0-9][0-9][0-9]$"))

library(stringr)
somemurals$zip <- str_match(somemurals$cxy_match,endzip)

somemurals[6,]$zip <- 21201

murals$zip <- somemurals$zip      
somemuralsz <- cxy_geocode(murals, address = address, city = city, state = state, zip =zip)
write_csv(somemurals,"~/Downloads/muralsz.csv")
