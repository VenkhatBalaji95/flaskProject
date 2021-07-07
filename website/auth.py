from flask import Blueprint,render_template,request,flash,redirect,url_for

auth = Blueprint("auth",__name__)

@auth.route("login")
def login():
    return render_template("login.html")

@auth.route("logout")
def logout():
    return "Logout page"

@auth.route("signup", methods=["GET","POST"])
def signup():
    if request.method == "POST":
        email = request.form.get('email')
        firstName = request.form.get('firsname')
        password = request.form.get('password')
        password1 = request.form.get('password1')
        if len(firstName) < 4:
            flash('First name must be greater than 4 character.', category='error')
        elif password != password1:
            flash("Passwords don\'t match.", category='error')
        elif len(password) < 7:
            flash('Password must be at least 7 characters.', category='error')
        else:
            return redirect(url_for('views.homePage'))
    return render_template("signup.html")
