from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Manshi's Flask backend running on AWS EC2 via ALB!", 200

@app.route('/health')
def health():
    return jsonify(status="healthy"), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
