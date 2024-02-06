############################################################
# Profit-Taker Analytics Parser                            #
# Main parser development contributions by ScamCat         #
# Minor parser development contributions by Basi           #
# Repo: https://github.com/Basiiii/Profit-Taker-Analytics  #
# Requires Python 3.10                                     #
############################################################

import traceback
from src.analyzer import Analyzer
from src.utils import color

def error_msg():
    traceback.print_exc()
    print('An unknown error occurred. Please screenshot this and report this along with your EE.log attached.')


def main():
    Analyzer().run()


if __name__ == "__main__":
    # noinspection PyBroadException
    try:
        main()
    except KeyboardInterrupt as e:  # To gracefully exit on ctrl + c
        pass
    except Exception:
        error_msg()
