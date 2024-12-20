from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.route("/api/health")
def healthcheck():
    return "Alive"

@app.route("/@{{ cookiecutter.app_name }}")
def @{{ cookiecutter.app_name }}():
    return "<p>Welcome to @{{ cookiecutter.app_name }}!</p>"

if __name__ == "__main__":
    app.run()
