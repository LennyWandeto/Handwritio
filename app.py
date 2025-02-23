from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from PIL import Image
import pytesseract

app = Flask(__name__)
CORS(app)  # Enable cross-origin requests (needed for Flutter)

# Create an uploads folder if it doesn't exist
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

@app.route("/", methods=["GET"])
def home():
    return "Handwritio Backend is Running!"

@app.route("/upload", methods=["POST"])
def upload_image():
    if "image" not in request.files:
        return jsonify({"error": "No image file found"}), 400
    
    image = request.files["image"]
    if image.filename == "":
        return jsonify({"error": "No selected file"}), 400

    image_path = os.path.join(app.config["UPLOAD_FOLDER"], image.filename)
    image.save(image_path)

    # Process image and extract text
    extracted_text = extract_text(image_path)

    return jsonify({"message": "Image processed successfully", "text": extracted_text})

def extract_text(image_path):
    try:
        image = Image.open(image_path)
        text = pytesseract.image_to_string(image)  # Extract text
        return text
    except Exception as e:
        return f"Error extracting text: {str(e)}"

if __name__ == "__main__":
    app.run(debug=True)
