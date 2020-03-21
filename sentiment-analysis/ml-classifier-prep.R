#---------------------------------------
# This script sets out to develop a 
# machine learning classification model
# to use in determining whether future
# university tweets about COVID-19 are
# positive or negative from the words 
# used in the tweet.
#
# The point is to avoid having to measure
# tweet content against the positive and
# negative lexicons each time.
#
# NOTE: This script requires setup.R and  
# twitter-initialisation.R to have been
# run first
#---------------------------------------

#---------------------------------------
# Author: Trent Henderson, 21 March 2020
#---------------------------------------

load("initial-tweet-pull.Rda")

# Set up positive and negative words as vectors for looping after removing short
# words and cleaning out symbols

pos_clean <- pos_words %>%
  mutate(positive_words_clean = rm_nchar_words(positive_words, "1,2")) %>%
  mutate(positive_words_clean = str_trim(positive_words_clean, side = "both")) %>%
  filter(positive_words_clean != "+") %>%
  filter(!is.na(positive_words_clean)) %>%
  dplyr::select(c(positive_words_clean)) %>%
  rename(positive_words = positive_words_clean)

neg_clean <- neg_words %>%
  mutate(negative_words_clean = rm_nchar_words(negative_words, "1,2")) %>%
  mutate(negative_words_clean = str_trim(negative_words_clean, side = "both")) %>%
  filter(!is.na(negative_words_clean)) %>%
  filter(negative_words_clean != "-faced") %>%
  filter(negative_words_clean != "-faces") %>%
  filter(negative_words_clean != "*") %>%
  filter(negative_words_clean != "**") %>%
  filter(negative_words_clean != "-cal") %>%
  filter(negative_words_clean != "-hum") %>%
  filter(negative_words_clean != "-viewable") %>%
  filter(negative_words_clean != " ") %>%
  dplyr::select(c(negative_words_clean)) %>%
  rename(negative_words = negative_words_clean) %>%
  arrange(negative_words)

neg_clean <- neg_clean[-1,]
neg_clean <- neg_clean[-1,]

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
    group_by(screen_name, text) %>%
    summarise(counter = sum(str_count(text, i))) %>%
    ungroup() %>%
    mutate(word = i)
  
  pos.list[[i]] <- pos_content_count
}

pos_tweet_sum <- rbindlist(pos.list, use.names = TRUE) %>%
  group_by(screen_name, text) %>%
  summarise(pos_count = sum(counter)) %>%
  ungroup()

# Summarise counts of negative words

neg.list <- list()
for(i in neg_vector){
  neg_content_count <- short_data %>%
    group_by(screen_name, text) %>%
    summarise(counter = sum(str_count(text, fixed(i)))) %>%
    ungroup() %>%
    mutate(word = i)
  
  neg.list[[i]] <- neg_content_count
}

neg_tweet_sum <- rbindlist(neg.list, use.names = TRUE) %>%
  group_by(screen_name, text) %>%
  summarise(neg_count = sum(counter)) %>%
  ungroup()

# Merge together to computer net sentiment and add full uni names
# Need to increase positive sentiment by proportionate difference
# in number of negative lexicon words compared to positive

the_diff <- solve(nrow(pos_clean),nrow(neg_clean))

handle_clean <- handle_raw %>%
  mutate(twitter_handle = gsub("@", "", twitter_handle))

merged_sum <- pos_tweet_sum %>%
  inner_join(neg_tweet_sum, by = c("screen_name" = "screen_name",
                                   "text" = "text")) %>%
  mutate(pos_count = pos_count * the_diff) %>%
  mutate(net_sent = pos_count - neg_count) %>%
  mutate(indicator = case_when(
    net_sent < 0  ~ "Negative",
    net_sent == 0 ~ "Neutral",
    net_sent > 0  ~ "Positive")) %>%
  dplyr::select(c(text, indicator))

#---------------------------------------EXPORT-------------------------------------


