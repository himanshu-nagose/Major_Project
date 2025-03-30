import pickle
import numpy as np
import tensorflow as tf # type: ignore
from model import build_model

def load_data():
    """ Load processed dataset """
    with open("data/processed/dataset.pkl", "rb") as f:
        data = pickle.load(f)

    X = np.array([np.abs(h).flatten() for h, _, _ in data])
    y = np.array([se for _, _, se in data])
    
    return X, y

def train():
    """ Train ML model for hybrid beamforming """
    X, y = load_data()
    
    model = build_model(input_shape=(X.shape[1],))
    model.fit(X, y, epochs=10, batch_size=32, validation_split=0.1)

    # Save trained model
    model.save("models/hybrid_beamforming_model.h5")
    print("Model training complete and saved.")

if __name__ == "__main__":
    train()
