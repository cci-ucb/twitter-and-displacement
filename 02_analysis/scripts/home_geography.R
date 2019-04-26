library(sf)
library(tidycensus)
library(tidyverse)
library(lubridate)
library(fs)
library(data.table)
library(reversegeocoder)
library(revgeo)
library(geojsonio)
library(furrr)
library(bit64)

options(future.globals.maxSize= 2000*1024^2)

## READ TWITTER DATA
sf_data <- fread("data/bo_2012.csv") %>% 
  add_count(u_id) %>% 
  filter(n > 20) 

## READ CALI TRACTS FROM CENSUS API
census_api_key("a9ed5fff3534bbb52dfda8179dcd8d08b2bb41b7")
options(tigris_use_cache = TRUE)
cali <- get_acs(state = "06", geography = "tract", variables = "B19013_001", geometry = T)
sf_tracts <- cali %>%
  st_transform(crs = 4326) %>%
  select(GEOID) %>%
  geojson_list() %>%
  unclass

## SET UP GEOCODER TO TIE TWEET TO TRACT
ctx <- rg_load_polygons(sf_tracts)
geocode_tract <- function(coordinates, ctx){
  rg_query(ctx, coordinates, "GEOID")
}

## ADD TRACT TO EACH TWEET
plan(multicore, workers = 5)
sf_data$tract <- future_pmap_chr(sf_data %>% 
                                   select(lon, lat) %>% 
                                   as.list(),
                                 function(lon, lat) geocode_tract(coordinates = c(lon, lat), ctx = ctx))

## GROUP BY USER, THEN CALCULATE HOME TRACT FOR EACH USER
sf_user <- sf_data %>%
  group_by(u_id) %>%
  nest()

sf_user_loc <- sf_user %>%
  mutate(home_tract = future_map_chr(sf_data, extract_home)) %>%
  select(-sf_data)

## LINK HOME TRACTS FOR EACH USER TO ORIGINAL DATA CONSISTING OF ALL TWEETS
sf_tracts_home <- left_join(sf_data, sf_user_loc)

## OUTPUT DATA
sf_tracts_home %>% 
  select(-n) %>% 
  na.omit() %>% 
  fwrite(., "sf_with_homeloc_scipen.csv")

## FUNCTION TO EXTRACT 'HOME' LOCATION
## WARNING: RELATIVELY NAIVE APPROACH
## IN ESSENCE: WE ONLY CONSIDER LOCATIONS WITH:
## 1. MORE THAN 10 TWEETS TOTAL
## 2. SENT FROM MORE THAN 10 DIFFERENT DAYS
## 3. SENT FROM MORE THAN 8 DIFFERENT HOURS OF THE DAY
## FOR ANY REMAINING CANDIDATES WE TAKE THE TRACT WITH MOST TWEETS
extract_home <- local(function(df) {
  home_loc <- df %>% 
    mutate(date = ymd_hms(date)) %>% 
    group_by(tract) %>% 
    summarise(count = n(), 
              days = n_distinct(as.Date(date)),
              hours = n_distinct(lubridate::hour(date))) %>% 
    filter(count > 10 & days > 10 & hours > 8) %>%
    top_n(n = 1, wt = count) %>% 
    slice(1) %>% 
    pull(tract)
  if(length(home_loc) == 0) return(NA)
  home_loc
})
