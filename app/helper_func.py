import subprocess
import csv

def call_rscript(script_path, *args):
    """run r script with arbitrary numbers of arguments"""
    subprocess.call(["Rscript", script_path] + [str(arg) for arg in args])

def read_tweets_trend(csv_path):

    with open(csv_path, 'r') as trend_file:
        trend_reader = csv.reader(trend_file)
        trends = [trend for sub_trend in trend_reader for trend in sub_trend]
    return trends


