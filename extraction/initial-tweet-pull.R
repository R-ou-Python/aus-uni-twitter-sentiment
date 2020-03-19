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

# Load in twitter handles of universities

handle_raw <- read_excel("data/uni_BD.xlsx") %>%
  clean_names()

# Turn handles into a vector to use in a loop

the_handles <- unique(handle_raw$twitter_handle)

#---------------------------------------TWEET SCRAPING-----------------------------

empty.list <- list()
for(i in the_handles){
  the_tweets <- searchTwitter(i, n = 10, lang = "en")
  
  uni_feed <- twListToDF(the_tweets) %>%
    mutate(uni = i)
  
  empty.list[[i]] <- uni_feed

}

tweet_data <- rbindlist(empty.list, use.names = TRUE)

#---------------------------------------CLEANING-----------------------------------


