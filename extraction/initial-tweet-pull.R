#---------------------------------------
# This script sets out to pull tweets
# from Australian universities
#
# NOTE: This script requires setup.R and  
# twitter-initialisation.R to have been
# run first
#---------------------------------------

#---------------------------------------
# Author: Trent Henderson, 19 March 2020
#---------------------------------------

#---------------------------------------TWEET SCRAPING-----------------------------

# Rtweet approach

empty.list <- list()
for(i in the_handles){
  the_tweets <- get_timeline(i, n = 50, include_rts = FALSE)
  
  empty.list[[i]] <- the_tweets
}

tweet_data <- rbindlist(empty.list, use.names = TRUE)

#---------------------------------------CLEANING-----------------------------------

# Filter to tweets that contain references to COVID-19

covid_tweets <- tweet_data %>%
  filter(grepl("COVID|COVID19|COVID-19|covid|covid19|covid-19|
                Covid|Covid19|Covid-19|Coronavirus|coronavirus", 
                text)|
          grepl("COVID|COVID19|COVID-19|covid|covid19|covid-19|
                 Covid|Covid19|Covid-19|Coronavirus|coronavirus", 
                 hashtags)) %>%
  dplyr::select(c(screen_name, text, hashtags))
