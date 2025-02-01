# FFmpeg configuration
FFMPEG_EXTRA_OECONF += " \
    --enable-shared \
    --disable-static \
    --enable-gpl \
    --enable-nonfree \
    --enable-x264 \
    --enable-libopus \
    --enable-libvorbis \
"

# FFmpeg requires libx264 and libopus for codec support
DEPENDS += " \
    x264 \
    libopus \
"
