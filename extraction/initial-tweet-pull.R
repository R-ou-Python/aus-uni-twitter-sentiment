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

# Preliminary analysis of just tweet text - extract most frequent unique words
# Note this does not consider approximate similarities yet

covid_words <- covid_tweets %>%
  dplyr::select(c(screen_name, text)) %>%
  unnest_tokens(word,text) %>%
  group_by(word) %>%
  summarise(counter = n()) %>%
  ungroup()%>%
  arrange(desc(counter))

# Remove all words with less than 3 characters as they are most likely meaningless

clean_covid_words <- covid_words %>%
  mutate(cleaner_words = rm_nchar_words(word, "1,3")) %>%
  mutate(program_simplified = str_trim(cleaner_words, side = "both")) %>%
  filter(cleaner_words != ".") %>%
  filter(cleaner_words != "'") %>%
  filter(!is.na(cleaner_words)) %>%
  dplyr::select(c(cleaner_words, counter)) %>%
  group_by(cleaner_words) %>%
  summarise(counter = sum(counter)) %>%
  ungroup() %>%
  filter(counter != 1804) %>% # Need to find more programmatic way of removing this
  arrange(desc(counter))

# Define a vector of meaningless words to filter out
# This can be added to rather than hard filter above

remove_words <- c("https")

clean_covid_words <- clean_covid_words %>%
  filter(cleaner_words %ni% remove_words)

# Extract just the top 20 words and plot

top_covid <- clean_covid_words %>%
  mutate(ranks = rank(desc(counter))) %>%
  filter(ranks <= 20) %>%
  dplyr::select(c(cleaner_words, counter))

p <- top_covid %>%
  ggplot(aes(x = reorder(cleaner_words, -counter), y = counter)) +
  geom_bar(fill = "#25388E", stat = "identity") +
  labs(title = "Top COVID-19 related words in recent tweets from Australian universities",
       x = "Word",
       y = "Frequency",
       caption = "Source: Twitter Developer API") +
  theme_bw() +
  theme(legend.position = "bottom",
        axis.text = element_text(colour = "#25388E"),
        axis.title = element_text(colour = "#25388E", face = "bold"),
        panel.border = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        axis.line = element_line(colour = "#25388E"),
        panel.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
        plot.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
        plot.title = element_text(colour = "#25388E", face = "bold"),
        plot.subtitle = element_text(colour = "#25388E"),
        plot.caption = element_text(colour = "#25388E"))
print(p)

#---------------------------------------PLOT EXPORT---------------------------------

CairoPNG("output/top-words.png", 1250, 700)
print(p)
dev.off()
