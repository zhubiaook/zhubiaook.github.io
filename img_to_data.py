import base64
import sys
import os.path

image_path = sys.argv[1]
data = ''

with open(image_path, 'rb') as f:
    image_data = f.read()
    base64_data = base64.b64encode(image_data)
    suffix = os.path.splitext(image_path)[-1][1:]
    data = "data:image/" + suffix + ";base64," + base64_data.decode()

with open('./image.txt', 'w') as f:
    f.write(data)
