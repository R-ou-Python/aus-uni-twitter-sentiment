#---------------------------------------
# This script sets out to produce an
# initial sentiment analysis by
# university and return a ' mean net 
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


