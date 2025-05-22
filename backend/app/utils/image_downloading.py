import requests
import os
from pathlib import Path

def download_images():
    # Create directory if it doesn't exist
    output_dir = Path(r'../uploads/images')
    output_dir.mkdir(parents=True, exist_ok=True)
    link_file = Path(__file__).parent / 'image_link.txt'
    # Get all URLs from the file
    urls = []
    with open(link_file, 'r') as f:
        urls = [line.strip() for line in f if line.strip() and not line.startswith('# ')]
    
    # Download each image
    for url in urls:
        try:
            response = requests.get(url)
            if response.status_code == 200:
                # Extract filename from URL
                filename = url.split('/')[-1]
                filepath = output_dir / filename
                
                # Save the image
                with open(filepath, 'wb') as f:
                    f.write(response.content)
                print(f"Successfully downloaded: {filename}")
            else:
                print(f"Failed to download: {url}")
        except Exception as e:
            print(f"Error downloading {url}: {str(e)}")

if __name__ == "__main__":
    download_images()