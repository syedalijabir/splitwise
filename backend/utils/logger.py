import logging

def get_logger(name: str = "app"):
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)

    if not logger.handlers:
        ch = logging.StreamHandler()
        ch.setLevel(logging.DEBUG)

        formatter = logging.Formatter(
            '[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
        )
        ch.setFormatter(formatter)

        logger.addHandler(ch)

    return logger
