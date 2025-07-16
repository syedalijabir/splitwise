from flask import Flask
import logging
from auth import auth
from flask_cors import CORS


# Create the Flask app
app = Flask(__name__)
app.register_blueprint(auth, url_prefix='/api')
CORS(app)


if __name__ == '__main__':
    logging.info("Starting application")
    app.run(debug=True, host='0.0.0.0', port=5001)
