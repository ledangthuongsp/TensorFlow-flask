from flask import Flask, request, jsonify
import requests
import logging
from werkzeug.utils import secure_filename
from inference_sdk import InferenceHTTPClient
from PIL import Image
import io
import os
import tempfile

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Initialize Roboflow client
CLIENT = InferenceHTTPClient(
    api_url="https://detect.roboflow.com",
    api_key="QWEjrGQxLc7LJu13VuzO"
)

@app.route('/')
def hello_world():
    return jsonify({'message': 'Hello World!'})

@app.route('/detect', methods=['POST'])
def detect_objects():
    try:
        logging.info("Received a request to /detect")

        if 'file' not in request.files:
            logging.error("No file part in the request")
            return jsonify({'error': 'No file part in the request'}), 400
        
        file = request.files['file']
        if file.filename == '':
            logging.error("No selected file")
            return jsonify({'error': 'No selected file'}), 400
        
        filename = secure_filename(file.filename)
        file_content = file.read()

        # Validate if the file is a valid image
        try:
            image = Image.open(io.BytesIO(file_content))
            image.verify()  # Verify that it is, in fact, an image
        except Exception as e:
            logging.error("Invalid image file")
            return jsonify({'error': 'Invalid image file', 'details': str(e)}), 400

        # Write the file content to a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as temp_file:
            temp_file.write(file_content)
            temp_file_path = temp_file.name

        # Use InferenceHTTPClient to send the image to Roboflow
        result = CLIENT.infer(temp_file_path, model_id="garbage-classification-3/2")

        # Clean up the temporary file
        os.remove(temp_file_path)

        return jsonify(result)
    except Exception as e:
        logging.exception("Error in /detect")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    from waitress import serve
    serve(app, host="0.0.0.0", port=5000)
