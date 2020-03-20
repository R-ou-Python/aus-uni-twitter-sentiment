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

# Set up positive and negative words as vectors for looping after removing short
# words

pos_clean <- pos_words %>%
  mutate(positive_words_clean = rm_nchar_words(positive_words, "1,2")) %>%
  mutate(positive_words_clean = str_trim(positive_words_clean, side = "both")) %>%
  filter(positive_words_clean != "+") %>%
  filter(!is.na(positive_words_clean)) %>%
  rename(positive_words = positive_words_clean)

neg_clean <- neg_words %>%
  mutate(negative_words_clean = rm_nchar_words(negative_words, "1,2")) %>%
  mutate(negative_words_clean = str_trim(negative_words_clean, side = "both")) %>%
  filter(!is.na(negative_words_clean)) %>%
  rename(negative_words_ = negative_words_clean)

pos_vector <- unique(pos_clean$positive_words)

neg_vector <- unique(neg_clean$negative_words)

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
  summarise(counter = sum(str_count(text, i))) %>%
  ungroup() %>%
  mutate(word = i)

  pos.list[[i]] <- pos_content_count
}

pos_tweet_sum <- rbindlist(pos.list, use.names = TRUE) %>%
  group_by(screen_name) %>%
  summarise(counter = sum(counter)) %>%
  ungroup()

# Summarise counts of positive words



#---------------------------------------VISUALISATION------------------------------


