import cv2
import numpy as np
from ultralytics import YOLO
import os
import base64
from io import BytesIO
from PIL import Image

dirname = os.path.dirname(__file__)
model_path = os.path.join(dirname, "IAmodel.pt")

def base64_to_image(base64_str):
    img_data = base64.b64decode(base64_str)
    np_array = np.frombuffer(img_data, np.uint8)
    return cv2.imdecode(np_array, cv2.IMREAD_COLOR)

def image_to_base64(image):
    _, buffer = cv2.imencode('.png', image)
    img_base64 = base64.b64encode(buffer).decode('utf-8')
    return img_base64

def generate_mask(image, model_path):
    H, W, _ = image.shape

    model = YOLO(model_path)

    results = model(image)

    for result in results:
        if result.masks is None:
            print("Nenhuma máscara detectada.")
            return None

        for j, mask in enumerate(result.masks.data):
            mask = mask.numpy() * 255
            mask = cv2.resize(mask, (W, H))
            return mask

    return None

def overlay_mask(image, mask):
    mask = mask.astype(np.uint8)
    
    if len(mask.shape) == 3:
        mask = cv2.cvtColor(mask, cv2.COLOR_BGR2GRAY)
    
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    max_contour = max(contours, key=cv2.contourArea)

    mask_contour = np.zeros_like(mask)

    cv2.drawContours(mask_contour, [max_contour], -1, 255, thickness=cv2.FILLED)

    overlaid = cv2.bitwise_and(image, image, mask=mask_contour)

    white_background = np.ones_like(image) * 255

    inverted_mask = cv2.bitwise_not(mask_contour)

    background = cv2.bitwise_and(white_background, white_background, mask=inverted_mask)

    overlaid = cv2.bitwise_or(overlaid, background)

    return overlaid


def process_and_classify_images(base64_images):
    processed_images = []
    pil_images = []

    for base64_image in base64_images:
        image = base64_to_image(base64_image)
        mask = generate_mask(image, model_path)
        if mask is not None:
            processed_image = overlay_mask(image, mask)
            processed_images.append(processed_image)
            pil_images.append(Image.fromarray(cv2.cvtColor(processed_image, cv2.COLOR_BGR2RGB)))
        else:
            return None

    classification_result = olivindex2(pil_images)
    return classification_result

def olivindex2(images):

    tc = [0] * 8

    for image in images:
        im = np.array(image)

        m, n, _ = im.shape

        gre = np.tile(np.array([89, 90, 21]).reshape(1, 1, 3), (m, n, 1))
        gry = np.tile(np.array([134, 132, 35]).reshape(1, 1, 3), (m, n, 1))
        pur = np.tile(np.array([76, 50, 36]).reshape(1, 1, 3), (m, n, 1))
        blk = np.tile(np.array([37, 24, 19]).reshape(1, 1, 3), (m, n, 1))
        whi = np.tile(np.array([200, 190, 180]).reshape(1, 1, 3), (m, n, 1))
        vaz = np.tile(np.array([250, 250, 250]).reshape(1, 1, 3), (m, n, 1))

        dgre = np.sqrt(np.sum((im - gre) ** 2, axis=2))
        dgry = np.sqrt(np.sum((im - gry) ** 2, axis=2))
        dpur = np.sqrt(np.sum((im - pur) ** 2, axis=2))
        dblk = np.sqrt(np.sum((im - blk) ** 2, axis=2))
        dwhi = np.sqrt(np.sum((im - whi) ** 2, axis=2))
        dvaz = np.sqrt(np.sum((im - vaz) ** 2, axis=2))

        dgre = dgre.flatten()
        dgry = dgry.flatten()
        dpur = dpur.flatten()
        dblk = dblk.flatten()
        dwhi = dwhi.flatten()
        dvaz = dvaz.flatten()

        de = np.vstack((dgre, dgry, dpur, dblk, dwhi, dvaz))

        corclas = np.argmin(de, axis=0)

        PerCol = [
            np.sum(corclas == 0),
            np.sum(corclas == 1),
            np.sum(corclas == 2),
            np.sum(corclas == 3),
            np.sum(corclas == 4)
        ]

        PerCol = np.array(PerCol) / np.sum(PerCol) * 100

        if PerCol[0] > 1 or PerCol[1] > 90:
            if np.sum(PerCol[2:4]) <= 5 and PerCol[0] >= 50:
                tc[0] += 1
            elif np.sum(PerCol[2:4]) <= 5 and PerCol[1] > 50:
                tc[1] += 1
            elif np.sum(PerCol[0:2]) > np.sum(PerCol[2:4]):
                tc[2] += 1
            elif np.sum(PerCol[0:2]) < np.sum(PerCol[2:4]):
                tc[3] += 1
        else:
            if PerCol[4] / np.sum(PerCol[2:5]) >= 0.9:
                tc[4] += 1
            elif PerCol[4] / np.sum(PerCol[2:5]) <= 0.1:
                tc[7] += 1
            elif PerCol[4] / np.sum(PerCol[2:5]) > 0.5:
                tc[5] += 1
            elif PerCol[4] / np.sum(PerCol[2:5]) < 0.5:
                tc[6] += 1

    nt = sum(tc)

    pc = [float("{:.2f}".format(count / nt * 100)) for count in tc]

    IM = sum(pc[i] * (i + 1) for i in range(8)) / 100

    return {
        "classes": tc,
        "percentAmostras": pc,
        "indiceMaturacao": float("{:.2f}".format(IM)),
        "totalAmostras": nt,
    }
