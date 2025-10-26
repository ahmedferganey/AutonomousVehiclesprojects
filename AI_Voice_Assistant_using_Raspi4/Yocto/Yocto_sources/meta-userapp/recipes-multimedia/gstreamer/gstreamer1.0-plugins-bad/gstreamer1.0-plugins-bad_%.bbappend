# GStreamer plugins-bad configuration

PACKAGECONFIG:append = " opengl x11 wayland alsa "

# GStreamer plugins-bad requires ALSA and PulseAudio for audio backends
DEPENDS += " \
    alsa-lib \
"
