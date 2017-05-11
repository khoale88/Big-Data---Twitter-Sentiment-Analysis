import os
import uuid
from threading import Thread
from flask import Flask, request, json, Response, render_template, session
from helper_func import search_term_require, remove_session_files, csv_to_array, call_rscript
from model import SEARCHES

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
app.config["LINE_GRAPH_FILENAME"] = "lineGraph.png"

@app.route('/ping', methods=['GET'])
def ping():
    """for pinging purpose"""
    return Response(status=200)

@app.route('/search', methods=['POST'])
def search():
    """web integrated API taking searchTerm input"""

    search_term = request.json["searchTerm"]
    return search_with_term(search_term)

@app.route('/search/<string:search_term>', methods=['POST'])
def search_with_term(search_term):
    """ testing API using Postman
        204 - accept the request
        304 - same searchTerm with previous request
        403 - new searchTerm is rejected due to current thread is in process"""

    if session['id'] not in SEARCHES:
        SEARCHES[session['id']] = None
    search_thread = SEARCHES[session['id']]
    if search_thread is not None:
        if search_thread.getName() == search_term:
            #case the current thread has the same searchTerm, sever won't reset thread
            return Response(status=304)
        else:
            #case new searchTerm is send,
            if search_thread.isAlive():
                #reject if thread is running
                return Response(status=403)
            else:
                #deregister fininshed thread to start a new one
                search_thread = SEARCHES[session['id']] = None

    if search_thread is None:
        remove_session_files(directory=app.config["OUTPUT_FOLDER"],
                             session_id=session['id'])
        #create a new thread calling R script
        search_thread = Thread(target=call_rscript,
                               args=(app.config["RSCRIPT_FOLDER"],
                                     app.config["RSCRIPT"],
                                     search_term,
                                     app.config["OUTPUT_FOLDER"],
                                     session['id']))
        search_thread.setName(session['id'])
        search_thread.start()
        #refresh the search term
        SEARCHES[session['id']] = search_thread
        session['search_term'] = search_term
        return Response(status=204)

@app.route('/topTrends', methods=['GET'])
@search_term_require
def get_tweet_trends():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    filename = session['id'] + "." + app.config["TWEET_TREND_FILENAME"]
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the trend with status code = 200
        tweet_trends = csv_to_array(filename)
        return render_template("trendingTweets.html", items=tweet_trends)

    search_thread = SEARCHES[session['id']]
    if search_thread.isAlive():
        #processing, please wait
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/tweets', methods=['GET'])
@search_term_require
def get_tweets():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    filename = session["id"] + "." + app.config["TWEET_FILENAME"]
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the trend with status code = 200
        tweets = csv_to_array(filename)
        return render_template("allTweets.html", tweets=tweets)

    search_thread = SEARCHES[session['id']]
    if search_thread.isAlive():
        #processing, please wait
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/locMap', methods=['GET'])
@search_term_require
def get_loc_map():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    filename = session['id'] + '.' + app.config["LOCATION_MAP_FILENAME"]
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"locMap"     : filename,
                                             "searchTerm" : session['search_term']}),
                        status=200)

    search_thread = SEARCHES[session['id']]
    if search_thread.isAlive():
        #processing, please wait, file not ready
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/pieChart', methods=['GET'])
@search_term_require
def get_pie_chart():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    filename = session['id'] + '.' + app.config["PIE_CHART_FILENAME"]
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"pieChart"   : filename,
                                             "searchTerm" : session['search_term']}),
                        status=200)

    search_thread = SEARCHES[session['id']]
    if search_thread.isAlive():
        #processing, please wait, file not ready
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/wordCloud', methods=['GET'])
@search_term_require
def get_word_cloud():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    filename = session['id'] + '.' + app.config["WORD_CLOUD_FILENAME"]
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"wordCloud"  : filename,
                                             "searchTerm" : session['search_term']}),
                        status=200)
    search_thread = SEARCHES[session['id']]
    if search_thread.isAlive():
        #processing, please wait
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/lineGraph', methods=['GET'])
@search_term_require
def get_line_graph():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    filename = session['id'] + '.' + app.config["LINE_GRAPH_FILENAME"]
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps({"lineGraph"  : filename,
                                             "searchTerm" : session['search_term']}),
                        status=200)
    search_thread = SEARCHES[session['id']]
    if search_thread.isAlive():
        #processing, please wait
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/', methods=['GET'])
def index():
    """render index template (homepage)"""
    if 'id' not in session:
        session['id'] = uuid.uuid4().hex
    return render_template("index.html")

if __name__ == "__main__":
    app.secret_key = 'A0Zr98j/3yX R~XHH!jmN]LWX/,?RT'
    app.run(debug=True,
            host=app.config["SERVER_HOST"],
            port=app.config["SERVER_PORT"])

