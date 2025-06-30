from flask import Flask
import logging
from flask_cors import CORS


# Create the Flask app
app = Flask(__name__)
CORS(app)


if __name__ == '__main__':
    logging.info("Starting application")
    app.run(debug=True, host='0.0.0.0', port=5001)