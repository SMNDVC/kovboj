from flask import Flask, render_template

app = Flask(__name__)


@app.route("/")
def index():
    return render_template("main2.html")


@app.route("/main")
def main_legacy():
    return render_template("main.html")
