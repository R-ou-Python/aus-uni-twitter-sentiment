#------------------------------------------------------------------------
# This script sets out necessary packages and generalisations for the
# project
#
# NOTE: Sentiment words are from:
#   Minqing Hu and Bing Liu. "Mining and Summarizing Customer Reviews." 
#     Proceedings of the ACM SIGKDD International Conference on Knowledge 
#     Discovery and Data Mining (KDD-2004), Aug 22-25, 2004, Seattle, 
#     Washington, USA
#-------------------------------------------------------------------------

#---------------------------------------
# Author: Trent Henderson, 19 March 2020
#---------------------------------------

library(tidyverse)
library(tidytext)
library(rtweet)
library(readxl)
library(janitor)
library(data.table)

# Load in twitter handles of universities

handle_raw <- read_excel("data/uni_BD.xlsx") %>%
  clean_names()

# Turn handles into a vector to use in a loop

the_handles <- unique(handle_raw$twitter_handle)

# Load in positive and negative sentiment words

pos_words <- read_excel("data/positive_words.xlsx")
neg_words <- read_excel("data/negative_words.xlsx")
