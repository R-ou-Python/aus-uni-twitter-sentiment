#-------------------------------------------
# This script sets out to produce a time
# series chart of proportion of uni tweets
# that are covid related
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 26 March 2020
#-------------------------------------------

# Import libraries

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import re

# Import data

data = pd.read_csv("data/raw-data.csv")

#-----------------------CLEAN DATES----------------------------

clean_data = data

# Remove specific times to leave data only and transform to datetime

clean_data['created_at_clean'] = clean_data['created_at'].str.split(' ').str[0]

clean_data['created_at_clean'] = pd.to_datetime(clean_data['created_at_clean'])

#-----------------------DUMMY VARIABLE FOR COVID-19------------

# Define string search criteria

the_strings = ["COVID", "COVID19", "COVID-19", "covid", "covid19", "covid-19", "Covid",
"Covid19", "Covid-19", "Coronavirus", "coronavirus"]

# Create dummy variable to then calculate proportion of tweets per day

daily_data = clean_data

daily_data['indicator'] = ['COVID' if re.search("(COVID|COVID19|COVID-19|covid|covid19|covid-19|Covid|Covid19|Covid-19|Coronavirus|coronavirus)",
a) else 'Non-COVID' for a in daily_data['text']]

daily_data = daily_data.groupby(['created_at_clean', 'indicator']).indicator.agg('count').to_frame('counter').reset_index()

daily_data

f = lambda x: 100 * x / float(x.sum())
daily_data['prop_tweets'] = (daily_data.groupby(['created_at_clean'])['counter'].transform(f))

daily_data

#-----------------------PLOTTING-------------------------------

fig = plt.figure(figsize = (9,5))
facet = sns.lineplot(data = daily_data, x = 'created_at_clean', y = 'counter', hue = 'indicator', style = 'indicator', dashes = False)
plt.xlabel("Date")
plt.ylabel("Number of university tweets")
plt.title("Universities have increased the amount they tweet over the COVID-19 pandemic to-date")
legend = plt.legend()
legend.texts[0].set_text("Tweet type")
plt.subplots_adjust(top = 0.88)
plt.savefig("uni-ts.svg")
plt.show()
