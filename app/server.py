from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from K8s with Helm & GitOps!"

app.run(host='0.0.0.0', port=5000)
