#-------------------------------------------
# This script sets out to build a clustering
# algorithm to group universities on China
# enrolment reliance and mean net COVID-19
# Twitter sentiment.
#
# NOTE: This script requires setup.R,
# and mean-net-sentiment-score.R to have been
# run first
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 23 March 2020
#-------------------------------------------

# Load data

reliance <- read.csv("data/international-proportion-data.csv")
load("sentiment-output-data.Rda")
load("initial-tweet-pull.Rda")

# Merge data

merged_data <- merged_sum %>%
  inner_join(reliance, by = c("university" = "provider"))

#------------------------CLUSTER ALGORITHM--------------------

scaled_data <- merged_data %>%
  mutate(mean_net_sent = scale(mean_net_sent),
         prop_eftsl = scale(prop_eftsl)) %>%
  dplyr::select(c(university, mean_net_sent, prop_eftsl))

scaled_tbl <- column_to_rownames(scaled_data, var = "university")

# Determine optimal

fviz_nbclust(scaled_tbl, kmeans, method = "wss") +
  labs(subtitle = "Elbow method")

fviz_nbclust(scaled_tbl, kmeans, method = "silhouette")+
  labs(subtitle = "Silhouette method") # Use 6 clusters

# Fit k-mean algorithm

set.seed(123)
fit <- kmeans(scaled_data[,2:3], 6)

str(fit)

scaled_data$grouping <- as.factor(fit$cluster)

# Plot k-means

the_palette <- c("1" = "#25388E",
                 "2" = "#57DBD8",
                 "3" = "#F84791",
                 "4" = "#F9B8B1",
                 "5" = "#37BEB0",
                 "6" = "#0C6170")

p <- scaled_data %>%
  ggplot(aes(x = prop_eftsl, y = mean_net_sent, colour = grouping, group = grouping)) +
  geom_point(aes(colour = grouping), size = 2, stat = "identity") +
  geom_text_repel(aes(colour = grouping, label = university)) +
  labs(title = "Cluster analysis of Australian universities on their reliance on internationals and mean net COVID-19 Tweet sentiment",
       x = "Scaled proportion of student load that is international",
       y = "Scaled mean net Tweet sentiment",
       caption = "Source: Twitter Developer API\nMean net sentiment = average of positive word count - mean negative word count at the Tweet level\nPositive and negative word lexicon source: Hu & Liu (2004)",
       colour = NULL) +
  scale_colour_manual(values = the_palette) +
  theme_bw() +
  theme(legend.position = "none",
          axis.text = element_text(colour = "#25388E"),
          axis.title = element_text(colour = "#25388E", face = "bold"),
          panel.border = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_line(colour = "white"),
          axis.line = element_line(colour = "#25388E"),
          panel.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
          plot.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
          legend.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
          legend.box.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
          legend.key = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
          legend.text = element_text(colour = "#25388E"),
          legend.title = element_text(colour = "#25388E"),
          plot.title = element_text(colour = "#25388E"),
          plot.subtitle = element_text(colour = "#25388E"),
          plot.caption = element_text(colour = "#25388E"))
print(p)
