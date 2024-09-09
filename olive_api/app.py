from flask import Flask, request, jsonify
from process_image import process_and_classify_images

app = Flask(__name__)

@app.route('/')
def home():
    return "API de Processamento de Imagens e Classificação de Azeitonas!"

@app.route('/process', methods=['POST'])
def process_image_route():
    data = request.get_json()
    if 'images' not in data:
        return jsonify({'error': 'Images not provided'}), 400

    base64_images = data['images']
    if not isinstance(base64_images, list) or len(base64_images) == 0:
        return jsonify({'error': 'Images should be a non-empty list'}), 400

    classification_result = process_and_classify_images(base64_images)

    if classification_result:
        return jsonify({'classification': classification_result})
    else:
        return jsonify({'error': 'Failed to process images'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)