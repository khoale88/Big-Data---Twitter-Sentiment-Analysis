import os
from flask import Flask, request, json, Response, render_template, url_for
import helper_func as hf



app = Flask(__name__)

app.config["RSCRIPT_FOLDER"] = "rscript/twitter_Sentiment_Analysis.R"
app.config["OUTPUT_FOLDER"] = "static/"


@app.route('/search', methods=['POST'])
def search():
    search_term = request.json["searchTerm"]
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

@app.route('/top_trends', methods=['GET'])
def get_trends():
    output = {}
    output["topTrends"] = hf.read_tweets_trend(app.config["OUTPUT_FOLDER"]+"tweets_topTrend.csv")

    return Response(response=json.dumps(output), status=200)

@app.route('/', methods=['GET'])
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)

