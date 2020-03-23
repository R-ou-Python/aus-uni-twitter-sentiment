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

# Import libraries

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns; sns.set()

from sklearn import preprocessing
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

# Import data

reliance = pd.read_csv("data/china-proportion-data.csv")
reliance

sentiment = pd.read_csv("data/sentiment-output-data.csv")
sentiment

#------------------------------MERGE DATA SETS---------------------------------

# Inner join to retain only rows where values are present in both data sets

merged_data = pd.merge(left = reliance, right = sentiment, left_on = 'provider', right_on = 'university')
merged_data

# Reduce dataframe to just columns of interest

clean_data = merged_data[['provider', 'prop_eftsl', 'mean_net_sent']]
clean_data

#------------------------------PRE PROCESSING FOR CLUSTER ANALYSIS-------------

# Convert provider name column to a row index to leave only numbers as data

clean_data = processed.set_index("provider")

# Remove NAs

clean_data = clean_data[clean_data['prop_eftsl'].notna()]
clean_data = clean_data[clean_data['mean_net_sent'].notna()]

# Standardise numerical variables to ensure proper fit

unstandardised = clean_data

cols_to_standardise = [
  column for column in unstandardised.columns
]

data_to_standardise = unstandardised[cols_to_standardise]

scaler = StandardScaler().fit(data_to_standardise)

standardised_data = unstandardised.copy()
standardised_columns = scaler.transform(data_to_standardise)
standardised_data[cols_to_standardise] = standardised_columns
standardised_data

#------------------------------BUILD CLUSTER ANALYSIS MODEL--------------------

# Determine optimal number of clusters to use in the model

Sum_of_squared_distances = []
K = range(1,15)
for k in K:
    km = KMeans(n_clusters=k)
    km = km.fit(standardised_data)
    Sum_of_squared_distances.append(km.inertia_)

plt.plot(K, Sum_of_squared_distances, 'bx-')
plt.xlabel('k')
plt.ylabel('Sum_of_squared_distances')
plt.title('Elbow Method For Optimal k')
plt.show()

# Build k-means cluster algorithm

kmeans = KMeans(n_clusters = 5).fit(standardised_data)
centroids = kmeans.cluster_centers_
print(centroids)
the_labels = kmeans.labels_
the_labels

# Add clusters back into dataframe for easier graphing and change provider name
# from rownames to a variable for easy interpretation

predict = kmeans.predict(standardised_data)

final_data = standardised_data

final_data['cluster_group'] = pd.Series(predict, index = final_data.index)

final_data.index.name = 'provider'
final_data.reset_index(inplace = True)

final_data

# Turn cluster numbers into meaningful labels

final_data['cluster_group'] = final_data['cluster_group'].replace([0], 'Moderate China reliance; Negative sentiment')
final_data['cluster_group'] = final_data['cluster_group'].replace([1], 'Low China reliance; Negative sentiment')
final_data['cluster_group'] = final_data['cluster_group'].replace([2], 'Low China reliance; Positive sentiment')
final_data['cluster_group'] = final_data['cluster_group'].replace([3], 'High China reliance; Neutral sentiment')
final_data['cluster_group'] = final_data['cluster_group'].replace([4], 'High China reliance; Positive sentiment')

final_data

#------------------------------GRAPH CLUSTER ANALYSIS--------------------------

# Define colour palette

the_palette = ["#25388E", "#57DBD8", "#F84791", "#F9B8B1", "#37BEB0"]

# Build plot

plt.figure()
facet = sns.lmplot(data=final_data, x = 'prop_eftsl', y = 'mean_net_sent', hue = 'cluster_group', fit_reg = False, legend = False, palette = the_palette)
plt.xlabel("Standardised Chinese proportion of all international EFTSL")
plt.ylabel("Standardised mean net Tweet sentiment")
plt.title("Cluster analysis of Australian universities on their reliance\non China and mean net COVID-19 Tweet sentiment")
plt.subplots_adjust(top = 0.88)
plt.savefig("output/cluster-plot.svg")
plt.show()
