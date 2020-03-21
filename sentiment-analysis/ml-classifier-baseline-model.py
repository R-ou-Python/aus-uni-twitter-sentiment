#-------------------------------------------
# This script sets out to build a baseline
# machine learning classification algorithm
# to determine if a tweet's sentiment is
# positive or negative. The baseline model
# is a logistic regression.
#
# NOTE: This script requires setup.R,
# and ml-classifier-prep.R to have been run
# first
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 21 March 2020
#-------------------------------------------

# Import libraries

import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression

# Import data

df = pd.read_csv("data/ml-model-train.csv")
df

# Split data into train and test

sentences = df['text'].values
y = df['indicator'].values

sentences_train, sentences_test, y_train, y_test = train_test_split(sentences, y, test_size = 0.25, random_state = 1000)

vectorizer = CountVectorizer()
vectorizer.fit(sentences_train)

X_train = vectorizer.transform(sentences_train)
X_test  = vectorizer.transform(sentences_test)
X_train

# Build baseline classifier model using logistic regression to assess accuracy

classifier = LogisticRegression()
classifier.fit(X_train, y_train)
score = classifier.score(X_test, y_test)

print("Accuracy:", score)
