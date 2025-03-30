import os

def main():
    """ Run the full pipeline """
    os.system("python src/dataset.py")
    os.system("python src/train.py")
    os.system("python src/evaluate.py")

if __name__ == "__main__":
    main()
