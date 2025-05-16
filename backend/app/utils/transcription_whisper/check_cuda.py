import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA version: {torch.version.cuda}")
print(f"GPU device: {torch.cuda.get_device_name(0)}")

# if you have CUDA 12.6, use this command:
# pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121