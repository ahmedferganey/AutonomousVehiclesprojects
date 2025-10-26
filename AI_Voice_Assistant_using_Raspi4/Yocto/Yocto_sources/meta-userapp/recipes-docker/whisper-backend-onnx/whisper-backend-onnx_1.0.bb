SUMMARY = "Whisper ONNX transcription backend Docker container"
DESCRIPTION = "Docker container running FastAPI backend with Whisper ONNX model for real-time audio transcription on Raspberry Pi 4"
HOMEPAGE = "https://github.com/ahmedferganey/AI_Voice_Assistant"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "docker-ce"
RDEPENDS:${PN} = "docker-ce bash"

SRC_URI = " \
    file://Dockerfile \
    file://requirements.txt \
    file://app/main.py \
    file://app/__init__.py \
    file://app/config.py \
    file://app/models.py \
    file://app/whisper_engine.py \
    file://app/audio_processor.py \
    file://app/utils.py \
"

S = "${WORKDIR}"

# Docker image configuration
DOCKER_IMAGE_NAME = "whisper-backend-onnx"
DOCKER_IMAGE_TAG = "1.0.0"
DOCKER_IMAGE_FULL = "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

# Skip QA checks for architecture (Docker image)
INSANE_SKIP:${PN} = "arch"

do_compile[network] = "1"

do_compile() {
    # Create build directory
    mkdir -p ${B}/docker-build
    
    # Copy all files to build directory
    cp -r ${WORKDIR}/* ${B}/docker-build/
    
    # Build Docker image for ARM64
    bbnote "Building Docker image: ${DOCKER_IMAGE_FULL}"
    docker buildx build \
        --platform linux/arm64 \
        --tag ${DOCKER_IMAGE_FULL} \
        --tag ${DOCKER_IMAGE_NAME}:latest \
        --load \
        ${B}/docker-build
    
    if [ $? -ne 0 ]; then
        bbfatal "Docker image build failed"
    fi
    
    # Save Docker image to tar archive
    bbnote "Saving Docker image to tarball..."
    docker save ${DOCKER_IMAGE_FULL} -o ${B}/${DOCKER_IMAGE_NAME}.tar
    
    if [ $? -ne 0 ]; then
        bbfatal "Failed to save Docker image"
    fi
    
    bbnote "Docker image built and saved successfully"
}

do_install() {
    # Create directories
    install -d ${D}${localstatedir}/lib/docker-images
    install -d ${D}${systemd_system_unitdir}
    install -d ${D}${bindir}
    
    # Install Docker image tarball
    install -m 0644 ${B}/${DOCKER_IMAGE_NAME}.tar ${D}${localstatedir}/lib/docker-images/
    
    # Create systemd service file
    cat > ${D}${systemd_system_unitdir}/whisper-backend.service <<EOF
[Unit]
Description=Whisper ONNX Backend Docker Container
After=docker.service
Requires=docker.service

[Service]
Type=simple
Restart=always
RestartSec=10
TimeoutStartSec=0

# Load Docker image if not already loaded
ExecStartPre=-/bin/sh -c 'docker load -i ${localstatedir}/lib/docker-images/${DOCKER_IMAGE_NAME}.tar || true'

# Stop and remove existing container
ExecStartPre=-/usr/bin/docker stop whisper-backend
ExecStartPre=-/usr/bin/docker rm whisper-backend

# Run Docker container
ExecStart=/usr/bin/docker run \\
    --rm \\
    --name whisper-backend \\
    --publish 8000:8000 \\
    --memory=1g \\
    --cpus=4 \\
    --restart unless-stopped \\
    ${DOCKER_IMAGE_FULL}

# Stop container on service stop
ExecStop=/usr/bin/docker stop whisper-backend

[Install]
WantedBy=multi-user.target
EOF

    # Create helper script to load Docker image
    cat > ${D}${bindir}/load-whisper-backend <<EOF
#!/bin/sh
# Load Whisper backend Docker image

echo "Loading Whisper ONNX backend Docker image..."
docker load -i ${localstatedir}/lib/docker-images/${DOCKER_IMAGE_NAME}.tar

if [ \$? -eq 0 ]; then
    echo "✓ Docker image loaded successfully"
    echo "  Image: ${DOCKER_IMAGE_FULL}"
    echo ""
    echo "To start the backend:"
    echo "  systemctl start whisper-backend"
    echo "  systemctl enable whisper-backend"
else
    echo "✗ Failed to load Docker image"
    exit 1
fi
EOF

    chmod +x ${D}${bindir}/load-whisper-backend
}

FILES:${PN} += " \
    ${localstatedir}/lib/docker-images/${DOCKER_IMAGE_NAME}.tar \
    ${systemd_system_unitdir}/whisper-backend.service \
    ${bindir}/load-whisper-backend \
"

# Enable systemd service
inherit systemd
SYSTEMD_SERVICE:${PN} = "whisper-backend.service"
SYSTEMD_AUTO_ENABLE = "enable"

# Package info
PACKAGE_ARCH = "${MACHINE_ARCH}"

