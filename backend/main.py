from flask import Flask
import logging
from auth import auth
from flask_cors import CORS
from groups import groups
from friends import friends
from expenses import expenses

from utils.logger import get_logger
logger = get_logger(__name__)

URL_PREFIX='/api'
app = Flask(__name__)
app.register_blueprint(auth, url_prefix=URL_PREFIX)
app.register_blueprint(groups, url_prefix=URL_PREFIX)
app.register_blueprint(friends, url_prefix=URL_PREFIX)
app.register_blueprint(expenses, url_prefix=URL_PREFIX)
CORS(app)


if __name__ == '__main__':
    logging.info("Starting application")
    app.run(debug=True, host='0.0.0.0', port=5001)
