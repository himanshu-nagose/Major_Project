import numpy as np
import pickle
import tensorflow as tf # type: ignore

def load_data():
    """ Load dataset for evaluation """
    with open("data/processed/dataset.pkl", "rb") as f:
        data = pickle.load(f)

    X = np.array([np.abs(h).flatten() for h, _, _ in data])
    y = np.array([se for _, _, se in data])
    
    return X, y

def evaluate():
    """ Evaluate the trained model """
    X, y = load_data()
    model = tf.keras.models.load_model("models/hybrid_beamforming_model.h5")

    loss, mae = model.evaluate(X, y)
    print(f"Evaluation Results - Loss: {loss}, MAE: {mae}")

if __name__ == "__main__":
    evaluate()
