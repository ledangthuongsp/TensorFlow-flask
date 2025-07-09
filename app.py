from flask import Flask, request, jsonify
import logging
from PIL import Image
import io
import torch
from transformers import AutoImageProcessor, AutoModelForImageClassification

# === Flask setup ===
app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# === Load SigLIP2 model from Hugging Face ===
MODEL_NAME = "prithivMLmods/Augmented-Waste-Classifier-SigLIP2"
model = AutoModelForImageClassification.from_pretrained(MODEL_NAME)
processor = AutoImageProcessor.from_pretrained(MODEL_NAME)

# === Waste label mapping ===
LABELS = {
    "0": "Battery", "1": "Biological", "2": "Cardboard", "3": "Clothes",
    "4": "Glass", "5": "Metal", "6": "Paper", "7": "Plastic",
    "8": "Shoes", "9": "Trash"
}

@app.route('/')
def hello_world():
    return jsonify({'message': 'Hello World!'})

@app.route('/detect', methods=['POST'])
def detect_waste_type():
    try:
        logging.info("Received a request to /detect")

        if 'file' not in request.files:
            return jsonify({'error': 'No file part in the request'}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No selected file'}), 400

        # Read and validate image
        file_content = file.read()
        try:
            image = Image.open(io.BytesIO(file_content)).convert("RGB")
        except Exception as e:
            return jsonify({'error': 'Invalid image file', 'details': str(e)}), 400

        # Process the image
        inputs = processor(images=image, return_tensors="pt")

        with torch.no_grad():
            outputs = model(**inputs)
            logits = outputs.logits
            probs = torch.nn.functional.softmax(logits, dim=1).squeeze().tolist()

        predictions = {LABELS[str(i)]: round(probs[i], 3) for i in range(len(probs))}
        top_class = max(predictions, key=predictions.get)

        return jsonify({
            "predicted_class": top_class,
            "confidence": predictions[top_class],
            "all_scores": predictions
        })

    except Exception as e:
        logging.exception("Error in /detect")
        return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#     app.run()
