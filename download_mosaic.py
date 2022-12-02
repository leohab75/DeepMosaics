import gdown
import sys

id = "1_X8aB2ir_yPoM9QHUlRrVnUWY3s9iOga"
gdown.download_folder(id=id, output="pretrained_models/", quet=True, use_cookies=False)

sys.exit()
