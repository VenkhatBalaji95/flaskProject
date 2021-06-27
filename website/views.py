from flask import Blueprint

view = Blueprint("views",__name__)

@view.route('/')
def homePage():
    return "Home page"
