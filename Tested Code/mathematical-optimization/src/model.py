import tensorflow as tf # type: ignore
from tensorflow.keras import layers, models # type: ignore

def build_model(input_shape):
    """ Define a simple neural network model for hybrid beamforming """
    model = models.Sequential([
        layers.Flatten(input_shape=input_shape),
        layers.Dense(128, activation='relu'),
        layers.Dense(64, activation='relu'),
        layers.Dense(1, activation='linear')  # Predicting spectral efficiency
    ])
    
    model.compile(optimizer='adam', loss='mse', metrics=['mae'])
    return model
