# Block find forever
### https://geo.fcc.gov/api/census/#!/block/get_block_find

library(httr)
library(jsonlite)
library(readr)


bffurl <- "https://geo.fcc.gov/api/census"
bfpath <- "/block/find"

options(stringsAsFactors = FALSE)

## ?latitude=39.28776&longitude=-76.63607&format=json

latitude=39.28776
longitude=-76.63607

## Puerto Rico, ok
latitude = 18.4219
longitude = -66.1173

returnformat = c("json")

send <- paste0(bffurl,bfpath, "?", "latitude=", latitude, 
               "&longitude=",  longitude, "&format=", returnformat)

rawres <- GET(send)

names(rawres)
payload <- rawToChar(rawres$content)

jsonenvelope <- fromJSON(payload)

print(jsonenvelope$messages)
print(jsonenvelope$Block[1])
print(jsonenvelope$Block[2])
boundingbox <- jsonenvelope$Block[2]

print(jsonenvelope$County)
print(jsonenvelope$State)

#### Process 76,683 Puerto Rico Records NOOOOO! TOO LOOONG!
readblocks <- read_csv("~/Downloads/SomeBlocks.csv")
thisrun <- nrow(readblocks)

startfile=TRUE
for(index in 1:thisrun){
  longitude=readblocks[index,]$longitude
  latitude=readblocks[index,]$latitude
  ourblock=readblocks[index,]$block

  sendit <- send <- paste0(bffurl,bfpath, "?", "latitude=", latitude, 
                           "&longitude=",  longitude, "&format=", returnformat)
  ## print(sendit)  
  rawres <- GET(send)
  if(rawres$status_code == 200)
  {
  payload <- rawToChar(rawres$content)
  jsonenvelope <- fromJSON(payload)
  
  theirblock <- jsonenvelope$Block[1]
  boundingbox <- jsonenvelope$Block[2]
  
  xmax <- jsonenvelope$Block$bbox[1]
  ymax <- jsonenvelope$Block$bbox[2]
  xmin <- jsonenvelope$Block$bbox[3]
  ymin <- jsonenvelope$Block$bbox[4]
  
  result <- tribble(~key, ~block, ~latitude, ~longitude, ~xmax, ~ymax, ~xmin, ~ymin,
                    ourblock,theirblock$FIPS,
                    latitude, longitude,
                    xmax,ymax,xmin,ymin)
  
  write_csv(as.data.frame(result),"result.csv", append=!startfile)
  startfile=FALSE
  } else {
    print(rawres$status_code) # what error num?
  }
  
  
}

# xmax <- jsonenvelope$Block$bbox[1]
# ymax <- jsonenvelope$Block$bbox[2]
# xmin <- jsonenvelope$Block$bbox[3]
# ymin <- jsonenvelope$Block$bbox[4]
# 
# abs(xmax) > abs(xmin)  # W longitude
# ymax < ymin     # North is up

mfr <- read_csv("result.csv")
nrow(mfr) == nrow(readblocks)
mfr$keycode <- paste0("#",mfr$block)

mfr$nomatch<-mfr$keycode!=mfr$key
mfr %>% filter(nomatch==TRUE) %>% write_csv("~/Downloads/outside.csv")
