import tweetTest as tt
import codecs
import csv

api = tt.TwitterClient()

tweets = api.get_tweets(query = 'Trump', count = 50)
tws = []

for tw in tweets:
    t = {}
    t['text'] = tw['text'].encode('utf8')
    t['sentiment'] = tw['sentiment']
    tws.append(t)

keys = tweets[0].keys()
print keys
with open('tweets.csv', 'w') as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(tws)
