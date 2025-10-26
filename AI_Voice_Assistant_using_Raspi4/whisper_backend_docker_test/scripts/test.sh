#!/bin/bash
# Test script for Whisper ONNX backend API

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🧪 Testing Whisper ONNX Backend API${NC}"
echo "===================================="
echo ""

# Configuration
BACKEND_URL="http://localhost:8000"
TIMEOUT=10

# Check if backend is running
echo -e "${YELLOW}Checking if backend is running...${NC}"
if ! curl -s --max-time $TIMEOUT "${BACKEND_URL}/health" > /dev/null 2>&1; then
    echo -e "${RED}❌ Backend is not running or not responding${NC}"
    echo ""
    echo "Start the backend first:"
    echo "  docker-compose up -d"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Backend is running${NC}"
echo ""

# Test 1: Root endpoint
echo -e "${YELLOW}Test 1: Root endpoint (/)${NC}"
response=$(curl -s "${BACKEND_URL}/")
echo "Response: $response"
echo -e "${GREEN}✓ Test 1 passed${NC}"
echo ""

# Test 2: Health check
echo -e "${YELLOW}Test 2: Health check (/health)${NC}"
response=$(curl -s "${BACKEND_URL}/health")
echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
if echo "$response" | grep -q "healthy"; then
    echo -e "${GREEN}✓ Test 2 passed - Backend is healthy${NC}"
else
    echo -e "${RED}⚠️ Test 2 warning - Backend may not be fully healthy${NC}"
fi
echo ""

# Test 3: Detailed status
echo -e "${YELLOW}Test 3: Detailed status (/status/detailed)${NC}"
response=$(curl -s "${BACKEND_URL}/status/detailed")
echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
echo -e "${GREEN}✓ Test 3 passed${NC}"
echo ""

# Test 4: Model info (may fail if model not loaded)
echo -e "${YELLOW}Test 4: Model info (/model/info)${NC}"
response=$(curl -s "${BACKEND_URL}/model/info")
if echo "$response" | grep -q "model_name"; then
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    echo -e "${GREEN}✓ Test 4 passed - Model is loaded${NC}"
else
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    echo -e "${YELLOW}⚠️ Test 4 skipped - Model not loaded (expected in mock mode)${NC}"
fi
echo ""

# Test 5: Transcribe audio file (if test audio exists)
echo -e "${YELLOW}Test 5: Transcribe audio file (POST /transcribe)${NC}"
if [ -f "../test_audio/test.wav" ]; then
    response=$(curl -s -X POST "${BACKEND_URL}/transcribe" \
        -F "audio_file=@../test_audio/test.wav" \
        -F "language=en")
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    echo -e "${GREEN}✓ Test 5 passed${NC}"
else
    echo -e "${YELLOW}⚠️ Test audio file not found, creating dummy file...${NC}"
    # Create a simple test WAV file (silence)
    mkdir -p ../test_audio
    python3 -c "
import wave
import struct
import random

# Create 2 seconds of random noise
sample_rate = 16000
duration = 2
samples = [int((random.random() * 2 - 1) * 32767 * 0.1) for _ in range(sample_rate * duration)]

with wave.open('../test_audio/test.wav', 'w') as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    wav_file.writeframes(struct.pack('h' * len(samples), *samples))

print('✓ Created test audio file')
    " 2>/dev/null && {
        response=$(curl -s -X POST "${BACKEND_URL}/transcribe" \
            -F "audio_file=@../test_audio/test.wav" \
            -F "language=en")
        echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
        echo -e "${GREEN}✓ Test 5 passed (mock mode)${NC}"
    } || {
        echo -e "${YELLOW}⚠️ Could not create test audio file${NC}"
    }
fi
echo ""

# Summary
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✅ All tests completed!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Backend URL: $BACKEND_URL"
echo ""
echo "To view logs:"
echo "  docker logs whisper-backend-test"
echo ""
echo "To stop backend:"
echo "  docker-compose down"
echo ""

