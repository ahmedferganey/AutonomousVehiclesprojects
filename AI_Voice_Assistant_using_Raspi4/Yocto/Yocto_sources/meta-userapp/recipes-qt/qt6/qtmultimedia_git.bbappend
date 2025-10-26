# Ensure ALSA/PulseAudio/FFmpeg backends are explicitly enabled
#PACKAGECONFIG:append = " alsa pulseaudio ffmpeg gstreamer"
PACKAGECONFIG:append = " alsa ffmpeg gstreamer"
#PACKAGECONFIG[alsa] = "-alsa,-no-alsa,alsa-lib"
PACKAGECONFIG[alsa] = "-DQT_MULTIMEDIA_ALSA=ON,-DQT_MULTIMEDIA_ALSA=OFF,alsa-lib"
#PACKAGECONFIG[pulseaudio] = "-pulseaudio,-no-pulseaudio,pulseaudio"
#PACKAGECONFIG[ffmpeg] = "-ffmpeg,-no-ffmpeg,ffmpeg"
PACKAGECONFIG[ffmpeg] = "-DQT_MULTIMEDIA_FFMPEG=ON,-DQT_MULTIMEDIA_FFMPEG=OFF,ffmpeg"
#PACKAGECONFIG[gstreamer] = "-gstreamer,-no-gstreamer,gstreamer1.0 gstreamer1.0-plugins-base"
PACKAGECONFIG[gstreamer] = "-DQT_MULTIMEDIA_GSTREAMER=ON,-DQT_MULTIMEDIA_GSTREAMER=OFF,gstreamer1.0 gstreamer1.0-plugins-base"

DEPENDS += " \
    alsa-lib \
"

# QtMultimedia requires ALSA/PulseAudio for audio playback
#DEPENDS += " \
#    alsa-lib \
#    pulseaudio \
#"

