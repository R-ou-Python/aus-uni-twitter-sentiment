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
    group_by(screen_name) %>%
    summarise(counter = sum(str_count(text, i))) %>%
    ungroup() %>%
    mutate(word = i)

  pos.list[[i]] <- pos_content_count
}

pos_tweet_sum <- rbindlist(pos.list, use.names = TRUE) %>%
  group_by(screen_name) %>%
  summarise(pos_count = mean(counter)) %>%
  ungroup()

# Summarise counts of negative words

neg.list <- list()
for(i in neg_vector){
  neg_content_count <- short_data %>%
    group_by(screen_name) %>%
    summarise(counter = sum(str_count(text, fixed(i)))) %>%
    ungroup() %>%
    mutate(word = i)
  
  neg.list[[i]] <- neg_content_count
}

neg_tweet_sum <- rbindlist(neg.list, use.names = TRUE) %>%
  group_by(screen_name) %>%
  summarise(neg_count = mean(counter)) %>%
  ungroup()

# Merge together to computer net sentiment and add full uni names

handle_clean <- handle_raw %>%
  mutate(twitter_handle = gsub("@", "", twitter_handle))

merged_sum <- pos_tweet_sum %>%
  inner_join(neg_tweet_sum, by = c("screen_name" = "screen_name")) %>%
  mutate(net_sent = pos_count - neg_count) %>%
  mutate(indicator = case_when(
         net_sent < 0  ~ "Negative",
         net_sent == 0 ~ "Neutral",
         net_sent > 0  ~ "Positive")) %>%
  inner_join(handle_clean, by = c("screen_name" = "twitter_handle")) %>%
  arrange(desc(net_sent))

#---------------------------------------VISUALISATION------------------------------

# Define palette for plotting based on sentiment

sent_palette <- c("Negative" = "#F84791",
                  "Neutral" = "#25388E",
                  "Positive" = "#57DBD8")

p <- merged_sum %>%
  mutate(university = as.factor(university)) %>%
  mutate(university = fct_reorder(university, net_sent)) %>%
  ggplot(aes(x = university, y = net_sent)) +
  geom_segment(aes(x = university, y = 0, xend = university, yend = net_sent, colour = indicator), 
               size = 3, stat = "identity") +
  labs(title = "Net sentiment of Australia's universities' recent COVID-19-related tweets",
       x = NULL,
       y = "Mean net sentiment",
       caption = "Source: Twitter Developer API\nNet sentiment = mean positive word count - mean negative word count\nPositive and negative word lexicon source: Hu & Liu (2004)",
       colour = NULL) +
  coord_flip() +
  theme_bw() +
  theme(axis.text = element_text(colour = "#25388E"),
        axis.title = element_text(colour = "#25388E", face = "bold"),
        panel.border = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        axis.line = element_line(colour = "#25388E"),
        panel.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
        plot.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
        plot.title = element_text(colour = "#25388E", face = "bold"),
        plot.caption = element_text(colour = "#25388E"),
        legend.position = "none") +
  scale_colour_manual(values = sent_palette)
print(p)

#---------------------------------------PLOT EXPORT--------------------------------

CairoPNG("output/uni-net-sentiment.png", 1250, 700)
print(p)
dev.off()
