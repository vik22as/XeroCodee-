from flask import Flask
app = Flask(__name__)


@app.route("/")
def home():
    return "Hello, this is a sample Python Web App running on Flask Frame"
    
if __name__=='__main__':
    app.run(debug=True,host='0.0.0.0')
