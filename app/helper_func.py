import subprocess
import csv

def del_files_except(directory, exclude):
    """args[1]"""
    from os import listdir, remove
    from os.path import isfile, join
    #args[1] should be input path
    onlyfile = [f for f in listdir(directory) if isfile(join(directory, f))]
    for filename in onlyfile:
        if filename not in exclude:
            remove(join(directory, filename))

def call_rscript(script_path, *args):
    """run r script with arbitrary numbers of arguments"""
    subprocess.call(["Rscript", script_path] + [str(arg) for arg in args])

def read_tweets_trend(csv_path):
    """read all line in csv file and return a flaten arrays"""
    with open(csv_path, 'r') as trend_file:
        trend_reader = csv.reader(trend_file)
        trends = [trend for sub_trend in trend_reader for trend in sub_trend]
    return trends

