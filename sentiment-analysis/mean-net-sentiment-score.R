#---------------------------------------
# This script sets out to produce an
# initial sentiment analysis by
# university and return a 'mean net 
# sentiment score' to plot
#
# NOTE: This script requires setup.R and  
# twitter-initialisation.R to have been
# run first
#---------------------------------------

#---------------------------------------
# Author: Trent Henderson, 20 March 2020
#---------------------------------------

load("initial-tweet-pull.Rda")

# Set up positive and negative words as vectors for looping

pos_vector <- unique(pos_words$positive_words)

neg_vector <- unique(neg_words$negative_words)

#---------------------------------------PRE PROCESSING-----------------------------

# Filter to tweets that contain references to COVID-19 and cut dataframe to just 
# columns for university and tweet content

short_data <- tweet_data %>%
  filter(grepl("COVID|COVID19|COVID-19|covid|covid19|covid-19|
                Covid|Covid19|Covid-19|Coronavirus|coronavirus", 
               text)|
           grepl("COVID|COVID19|COVID-19|covid|covid19|covid-19|
                 Covid|Covid19|Covid-19|Coronavirus|coronavirus", 
                 hashtags)) %>%
  dplyr::select(c(screen_name, text))

# Summarise counts of positive words

pos.list <- list()
for(i in pos_vector){
pos_content_count <- short_data %>%
  group_by(screen_name) %>%
  summarise(counter = sum(str_count(short_data$text, i))) %>%
  ungroup() %>%
  mutate(word = i)

  pos.list[[i]] <- pos_content_count
}

pos_tweet_sum <- rbindlist(pos.list, use.names = TRUE)

# Summarise counts of positive words



#---------------------------------------VISUALISATION------------------------------


