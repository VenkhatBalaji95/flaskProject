from flask import Flask

def createApp():
    app = Flask(__name__)

    from .views import view
    from .auth import auth

    app.register_blueprint(view, url_prefix="/")
    app.register_blueprint(auth, url_prefix="/")
    return app
