import os
from flask import Flask, request, json, Response, render_template, url_for
import callR as cR



app = Flask(__name__)

app.config["RSCRIPT_FOLDER"] = "./RScript/sample_R.r"
app.config["OUTPUT_FOLDER"] = "./static/"


@app.route('/search', methods=['POST'])
def search():
    search_term = request.json["searchTerm"]
    cR.call_rscript(app.config["RSCRIPT_FOLDER"],
                    search_term,
                    app.config["OUTPUT_FOLDER"]+"output.png")

    output = {}
    output["link"] = url_for("static", filename="output.png")

    return Response(response=json.dumps(output), status=200)

@app.route('/', methods=['GET'])
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)

