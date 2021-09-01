from flask import Blueprint,render_template
import subprocess

view = Blueprint("views",__name__)

@view.route('/')
def homePage():
    return render_template("home.html")

@view.route("host")
def host():
    output = subprocess.run("hostname", stdout=subprocess.PIPE, text = True)
    output = output.stdout.strip()
    return output
