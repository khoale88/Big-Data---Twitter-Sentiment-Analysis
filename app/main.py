import os
from threading import Thread
from flask import Flask, request, json, Response, render_template, url_for
# from werkzeug.datastructures import Headers
import helper_func as hf

app = Flask(__name__)

app.config["RSCRIPT_FOLDER"] = "rscript/twitter_Sentiment_Analysis.R"
app.config["OUTPUT_FOLDER"] = "static/"
app.config["STATIC_EXCLUSION"] = ["jquery-3.2.1.min.js", "style.css"]

CURRENT_THREAD = None

@app.route('/search', methods=['POST'])
def search():
    """web integrated API taking searchTerm input"""

    search_term = request.json["searchTerm"]

    # replace the rest of this method with
    # return search_with_term(search_term)
    # to integrating with web UI with different tabs

    #delete all file b4 generate new files
    exclude = ["jquery-3.2.1.min.js", "style.css"]
    hf.del_files_except(directory=app.config["OUTPUT_FOLDER"],
                        exclude=exclude)

    #call R script
    hf.call_rscript(app.config["RSCRIPT_FOLDER"],
                    search_term,
                    app.config["OUTPUT_FOLDER"])

    output = {}
    output["pics"] = {}
    # url_for("static", filename="output.png")
    output["pics"]["locPNG"] = url_for("static", filename="loc.png")
    output["pics"]["piePNG"] = url_for("static", filename="pie.png")
    output["pics"]["wordCloudPNG"] = url_for("static", filename="wordCloud.png")

    return Response(response=json.dumps(output), status=200)

@app.route('/search/<string:search_term>', methods=['POST'])
def search_with_term(search_term):
    """ testing API using Postman
        204 - accept the request
        304 - same searchTerm with previous request
        403 - new searchTerm is rejected due to current thread is in process"""

    global CURRENT_THREAD
    if CURRENT_THREAD is not None:
        if CURRENT_THREAD.getName() == search_term:
            #case the current thread has the same searchTerm, sever won't reset thread
            return Response(status=304)
        else:
            #case new searchTerm is send,
            if CURRENT_THREAD.isAlive():
                #reject if thread is running
                return Response(status=403)
            else:
                #deregister fininshed thread to start a new one
                CURRENT_THREAD = None

    if CURRENT_THREAD is None:
        #start only if current thread is available
        #delete old files b4 generating new files
        hf.del_files_except(directory=app.config["OUTPUT_FOLDER"],
                            exclude=app.config["STATIC_EXCLUSION"])
        #create a new thread calling R script
        thread = Thread(target=hf.call_rscript,
                        args=(app.config["RSCRIPT_FOLDER"],
                              search_term,
                              app.config["OUTPUT_FOLDER"]))
        #assign thread name and start
        CURRENT_THREAD = thread
        CURRENT_THREAD.setName(search_term)
        CURRENT_THREAD.start()
        return Response(status=204)

@app.route('/topTrends', methods=['GET'])
def get_trends():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    if CURRENT_THREAD is None:
        #need to start at least one search
        return Response(status=404)

    filename = "tweets_topTrend.csv"
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the trend with status code = 200
        trends = hf.read_tweets_trend(filename)
        output = {"topTrends"  : trends,
                  "searchTerm" : CURRENT_THREAD.getName()}
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps(output),
                        status=200)
    if CURRENT_THREAD.isAlive():
        #processing, please wait
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)


@app.route('/locPNG', methods=['GET'])
def get_loc_map():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    if CURRENT_THREAD is None:
        #need to start at least one search
        return Response(status=404)

    filename = "loc.png"
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        output = {"locPNG"     : filename,
                  "searchTerm" : CURRENT_THREAD.getName()}
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps(output),
                        status=200)
    if CURRENT_THREAD.isAlive():
        #processing, please wait, file not ready
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/piePNG', methods=['GET'])
def get_pie_chart():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    if CURRENT_THREAD is None:
        #need to start at least one search
        return Response(status=404)

    filename = "pie.png"
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        output = {"piePNG"     : filename,
                  "searchTerm" : CURRENT_THREAD.getName()}
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps(output),
                        status=200)
    elif CURRENT_THREAD.isAlive():
        #processing, please wait, file not ready
        return Response(status=202)
    else:
        #error occurs and thread is stop, no output file
        return Response(status=500)

@app.route('/wordCloudPNG', methods=['GET'])
def get_word_cloud():
    """ 200 - succesful with return
        202 - processing
        404 - start a search
        500 - internal error, start a new seatch"""

    if CURRENT_THREAD is None:
        #need to start at least one search
        return Response(status=404)

    filename = "wordCloud.png"
    filename = os.path.join(app.config["OUTPUT_FOLDER"],
                            filename)
    if os.path.exists(filename):
    #if the file exist, return the path with status code = 200
        output = {"wordCloudPNG" : filename,
                  "searchTerm"   : CURRENT_THREAD.getName()}
        return Response(headers=[("Content-Type", "json/application")],
                        response=json.dumps(output),
                        status=200)

    elif CURRENT_THREAD.isAlive():
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
    app.run(debug=True, host='0.0.0.0', port=5000)

