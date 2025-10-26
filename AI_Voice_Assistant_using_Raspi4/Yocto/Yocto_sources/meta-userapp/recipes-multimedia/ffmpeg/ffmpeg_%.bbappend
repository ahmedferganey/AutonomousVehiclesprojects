# FFmpeg configuration
FFMPEG_EXTRA_OECONF += " \
    --enable-shared \
    --disable-static \
    --enable-gpl \
    --enable-nonfree \
    --enable-libx264 \
    --enable-libopus \
    --enable-libvorbis \
"
#PACKAGECONFIG_append = " gpl"
PACKAGECONFIG[gpl] = " gpl"
# FFmpeg requires libx264 and libopus for codec support
DEPENDS += " \
    x264 \
    libopus \
"
LICENSE_FLAGS_ACCEPTED += "commercial_ffmpeg"

