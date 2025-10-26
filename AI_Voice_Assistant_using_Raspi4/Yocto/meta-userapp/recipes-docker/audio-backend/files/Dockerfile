# Use the arm64v8 Python image as the base image
FROM --platform=linux/arm64 arm64v8/python:3.10-slim-buster AS base

# Set environment variables to prevent issues with debconf
ENV DEBIAN_FRONTEND=noninteractive


# Install necessary system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    portaudio19-dev \           # Required for audio capture with sounddevice
    libsndfile1-dev \           # For audio file support
    libasound2-dev \            # ALSA sound system support
    fftw3-dev \                 # FFT for audio processing
    ffmpeg \                    # For audio/video handling
    git \                       # For fetching additional dependencies if needed
    libqt5widgets5 \            # Qt5 Widgets library
    libqt5gui5 \                # Qt5 GUI base library
    libqt5core5a \              # Core Qt5 functionality
    qt5-default \               # Installs all basic Qt5 components
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    
# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Set the working directory and copy application files
WORKDIR /app
COPY requirements.txt ./
COPY . ./

# Install Python dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Command to run the application
CMD ["python3", "main.py"]

# Metadata for Buildx
LABEL maintainer="ahmed.ferganey707@gmail.com"
