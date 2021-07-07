from flask import Blueprint,render_template

view = Blueprint("views",__name__)

@view.route('/')
def homePage():
    return render_template("home.html")
