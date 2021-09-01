from flask import Blueprint,render_template
import os

view = Blueprint("views",__name__)

@view.route('/')
def homePage():
    return render_template("home.html")

@auth.route("host")
def host():
    command = "hostname"
    hostName = os.system(command)
    return hostName