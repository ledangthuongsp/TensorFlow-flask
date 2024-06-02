from flask import Flask, request, jsonify
import tensorflowjs as tfjs
import numpy as np
from PIL import Image
import io

app = Flask(__name__)

# Load the TensorFlow.js model
model = tfjs.converters.load_keras_model('model/model.json')

def preprocess_image(image):
    img = Image.open(io.BytesIO(image)).resize((224, 224))
    img = np.array(img) / 255.0
    img = np.expand_dims(img, axis=0)
    return img

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    image = file.read()
    processed_image = preprocess_image(image)

    prediction = model.predict(processed_image)
    return jsonify({'prediction': prediction.tolist()})

if __name__ == '__main__':
    app.run(debug=True)
