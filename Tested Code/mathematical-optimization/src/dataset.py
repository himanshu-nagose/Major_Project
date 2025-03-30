import numpy as np
import os
import pickle

def generate_dataset(num_samples=10000, N=64, M=16, L=15, sigma_sq=40):
    """ Generate dataset for ML model """
    data = []

    for _ in range(num_samples):
        H = (np.random.randn(M, N) + 1j * np.random.randn(M, N)) / np.sqrt(2)
        P = np.random.uniform(0, 100)  # Random power values
        spectral_efficiency = np.log2(np.linalg.det(np.identity(M) + (P / sigma_sq) * (H @ H.conj().T))).real
        
        data.append((H, P, spectral_efficiency))

    # Save dataset
    os.makedirs("data/processed", exist_ok=True)
    with open("data/processed/dataset.pkl", "wb") as f:
        pickle.dump(data, f)

    print(f"Dataset saved with {num_samples} samples.")

if __name__ == "__main__":
    generate_dataset()
