from flask import Flask, jsonify, request, json, Response
import callR as cR


app =Flask(__name__)

@app.route('/fiveminutes/<string:search_term>', methods=['GET'])
def search(search_term):
    print search_term
    path = "output.png"
    output = {}
    cR.callR(search_term)
    output["path"] = path
    return Response(response=json.dumps(output),status=200)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0',port=5000)

