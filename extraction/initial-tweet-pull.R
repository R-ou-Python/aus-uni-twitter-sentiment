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

