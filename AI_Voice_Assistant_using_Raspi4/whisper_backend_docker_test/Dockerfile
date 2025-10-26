# Multi-architecture Whisper ONNX Backend Dockerfile
# Supports: linux/amd64 (for testing on PC) and linux/arm64 (for Raspberry Pi 4)

# Stage 1: Build environment
ARG TARGETPLATFORM
FROM --platform=${TARGETPLATFORM:-linux/amd64} python:3.10-slim-bullseye AS builder

LABEL maintainer="Ahmed Ferganey <ahmed.ferganey707@gmail.com>"
LABEL description="Whisper ONNX Audio Transcription Backend - Multi-arch"
LABEL version="1.0.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libsndfile1-dev \
    libgomp1 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy and install Python dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /tmp/requirements.txt && \
    echo "✓ Python dependencies installed successfully"

# Stage 2: Runtime environment
FROM --platform=${TARGETPLATFORM:-linux/amd64} python:3.10-slim-bullseye

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsndfile1 \
    libgomp1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set Python environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Create app directory and set ownership
WORKDIR /app

# Copy application code
COPY app/ /app/app/

# Create directories for models and cache
RUN mkdir -p /app/models /app/cache/audio_buffers && \
    echo "✓ Application directories created"

# Create non-root user for security (optional, can be disabled for testing)
ARG CREATE_USER=true
RUN if [ "$CREATE_USER" = "true" ]; then \
        useradd -m -u 1000 whisper && \
        chown -R whisper:whisper /app && \
        echo "✓ Created user: whisper"; \
    else \
        echo "⚠️ Running as root (testing mode)"; \
    fi

# Switch to non-root user if created
USER ${CREATE_USER:+whisper}

# Expose API port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run FastAPI with uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--log-level", "info"]

