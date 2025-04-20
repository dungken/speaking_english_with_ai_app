FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies including ffmpeg and portaudio for audio processing
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       libc6-dev \
       build-essential \
       ffmpeg \
       portaudio19-dev \
       python3-pyaudio \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install PyAudio separately after system dependencies
RUN pip install pyaudio

# Copy application code
COPY . .

# Fix potentially corrupted user.py file
RUN sed -i '/INFO:     Application startup complete./d' /app/app/routes/user.py

# Expose port
EXPOSE 8000

# Command to run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
