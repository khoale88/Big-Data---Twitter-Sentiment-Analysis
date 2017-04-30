from flask import Flask, jsonify, request, json, Response, render_template, url_for
import callR as cR
import os


app =Flask(__name__)

app.config["RSCRIPT_FOLDER"] = "./RScript/sample_R.r"
# app.config["UPLOAD_FOLDER"] = "./uploads/"
# app.config["UNZIP_FOLDER"] = "./unzips/"
# app.config["OUTPUT_FOLDER"] = "./static/"

@app.route('/search', methods=['POST'])
def search():
    search_term = request.json["searchTerm"]
    print search_term
    cR.callR(app.config["RSCRIPT_FOLDER"], search_term)

    #move output.png to statuc folder
    os.rename("output.png", "static/output.png")

    output = {}
    output["link"] = url_for("static", filename="output.png")

    return Response(response=json.dumps(output), status=200)

@app.route('/',methods=['GET'])
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0',port=5000)

