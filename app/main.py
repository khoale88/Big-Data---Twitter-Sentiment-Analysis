import os
from threading import Thread
from flask import Flask, request, json, Response, render_template, url_for
# from werkzeug.datastructures import Headers
import helper_func as hf

app = Flask(__name__)

app.config["SERVER_HOST"] = "0.0.0.0"
app.config["SERVER_PORT"] = 5000
app.config["RSCRIPT_FOLDER"] = "rscript/"
app.config["RSCRIPT"] = "twitter_Sentiment_Analysis.R"
app.config["OUTPUT_FOLDER"] = "static/"

app.config["STATIC_EXCLUSION"] = ["jquery-3.2.1.min.js", "style.css"]
app.config["TWEET_TREND_FILENAME"] = "tweets_topTrend.csv"
app.config["TWEET_FILENAME"] = "tweets_cleansed.csv"
app.config["LOCATION_MAP_FILENAME"] = "loc.png"
app.config["PIE_CHART_FILENAME"] = "pie.png"
app.config["WORD_CLOUD_FILENAME"] = "wordCloud.png"


CURRENT_SEARCH = None

@app.route('/search', methods=['POST'])
def search():
    """web integrated API taking searchTerm input"""

    search_term = request.json["searchTerm"]

    # replace the rest of this method with just one following line of code
    # to integrating with web UI with different tabs
    return search_with_term(search_term)


    # #delete all file b4 generate new files
    # exclude = ["jquery-3.2.1.min.js", "style.css"]
    # hf.del_files_except(directory=app.config["OUTPUT_FOLDER"],
    #                     exclude=exclude)

    # #call R script
    # hf.call_rscript(app.config["RSCRIPT_FOLDER"],
    #                 app.config["RSCRIPT"],
    #                 search_term,
    #                 app.config["OUTPUT_FOLDER"])

    # output = {}
    # output["pics"] = {}
    # # url_for("static", filename="output.png")
    # output["pics"]["locPNG"] = os.path.join(app.config["OUTPUT_FOLDER"],
    #                                         app.config["LOCATION_MAP_FILENAME"])
    # output["pics"]["piePNG"] = os.path.join(app.config["OUTPUT_FOLDER"],
    #                                         app.config["PIE_CHART_FILENAME"])
    # output["pics"]["wordCloudPNG"] = os.path.join(app.config["OUTPUT_FOLDER"],
    #                                               app.config["WORD_CLOUD_FILENAME"])

    # return Response(response=json.dumps(output), status=200)

@app.route('/search/<string:search_term>', methods=['POST'])
def search_with_term(search_term):
    """ testing API using Postman
        204 - accept the request
        304 - same searchTerm with previous request
        403 - new searchTerm is rejected due to current thread is in process"""

    global CURRENT_SEARCH
    if CURRENT_SEARCH is not None:
        if CURRENT_SEARCH.getName() == search_term:
            #case the current thread has the same searchTerm, sever won't reset thread
            return Response(status=304)
        else:
            #case new searchTerm is send,
            if CURRENT_SEARCH.isAlive():
                #reject if thread is running
                return Response(status=403)
            else:
                #deregister fininshed thread to start a new one
                CURRENT_SEARCH = None

    if CURRENT_SEARCH is None:
        #start only if current thread is available
        #delete old files b4 generating new files
        hf.del_files_except(directory=app.config["OUTPUT_FOLDER"],
                            exclude=app.config["STATIC_EXCLUSION"])
        #create a new thread calling R script
        search_thread = Thread(target=hf.call_rscript,
                               args=(app.config["RSCRIPT_FOLDER"],
                                     app.config["RSCRIPT"],
                                     search_term,
                                     app.config["OUTPUT_FOLDER"]))
        #assign thread name and start
        CURRENT_SEARCH = search_thread
        CURRENT_SEARCH.setName(search_term)
        CURRENT_SEARCH.start()
        return Response(status=204)

@app.route('/topTrends', methods=['GET'])
def get_tweet_trends():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""
    if CURRENT_SEARCH is None:
        #need to start at least one search
        return Response(status=404)

    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            app.config["TWEET_TREND_FILENAME"])
    if os.path.exists(filename):
    #if the file exist, return the trend with status code = 200
        tweet_trends = hf.csv_to_array(filename)
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"tweetTrends"  : tweet_trends,
                                             "searchTerm" : CURRENT_SEARCH.getName()}),
                        status=200)
    if CURRENT_SEARCH.isAlive():
        #processing, please wait
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/tweets', methods=['GET'])
def get_tweets():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""
    if CURRENT_SEARCH is None:
        #need to start at least one search
        return Response(status=404)

    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            app.config["TWEET_FILENAME"])
    if os.path.exists(filename):
    #if the file exist, return the trend with status code = 200
        tweets = hf.csv_to_array(filename)
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"tweet"  : tweets,
                                             "searchTerm" : CURRENT_SEARCH.getName()}),
                        status=200)
    if CURRENT_SEARCH.isAlive():
        #processing, please wait
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/locMap', methods=['GET'])
def get_loc_map():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""
    if CURRENT_SEARCH is None:
        #need to start at least one search
        return Response(status=404)

    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            app.config["LOCATION_MAP_FILENAME"])
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"locMap"     : filename,
                                             "searchTerm" : CURRENT_SEARCH.getName()}),
                        status=200)
    if CURRENT_SEARCH.isAlive():
        #processing, please wait, file not ready
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/pieChart', methods=['GET'])
def get_pie_chart():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""
    if CURRENT_SEARCH is None:
        #need to start at least one search
        return Response(status=404)

    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            app.config["PIE_CHART_FILENAME"])
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"pieChart"     : filename,
                                             "searchTerm" : CURRENT_SEARCH.getName()}),
                        status=200)
    elif CURRENT_SEARCH.isAlive():
        #processing, please wait, file not ready
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/wordCloud', methods=['GET'])
def get_word_cloud():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""
    if CURRENT_SEARCH is None:
        #need to start at least one search
        return Response(status=404)

    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            app.config["WORD_CLOUD_FILENAME"])
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"wordCloud" : filename,
                                             "searchTerm"   : CURRENT_SEARCH.getName()}),
                        status=200)
    elif CURRENT_SEARCH.isAlive():
        #processing, please wait
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/', methods=['GET'])
def index():
    """render index template (homepage)"""
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True,
            host=app.config["SERVER_HOST"],
            port=app.config["SERVER_PORT"])