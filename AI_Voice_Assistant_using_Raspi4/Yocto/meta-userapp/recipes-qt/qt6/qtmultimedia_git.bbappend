# qtmultimedia_git.bbappend

# Default PACKAGECONFIG settings
# Enable ALSA, PulseAudio, libva, and VAAPI by default
PACKAGECONFIG ??= "alsa pulseaudio libva vaapi"

# ALSA configuration
# Enables ALSA backend for audio playback
PACKAGECONFIG[alsa] = "-DQT_FEATURE_alsa=ON,-DQT_FEATURE_alsa=OFF,alsa-lib,alsa-lib"

# PulseAudio configuration
# Enables PulseAudio backend for audio playback
PACKAGECONFIG[pulseaudio] = "-DQT_FEATURE_pulseaudio=ON,-DQT_FEATURE_pulseaudio=OFF,pulseaudio,pulseaudio"

# libva configuration
# Enables libva for hardware-accelerated video decoding
PACKAGECONFIG[libva] = "-DQT_FEATURE_libva=ON,-DQT_FEATURE_libva=OFF,libva,libva"

# VAAPI configuration
# Enables VAAPI for hardware-accelerated video decoding
PACKAGECONFIG[vaapi] = "-DQT_FEATURE_vaapi=ON,-DQT_FEATURE_vaapi=OFF,libva-vaapi,libva-vaapi"

# Optional: GStreamer configuration
# Enables GStreamer backend for multimedia playback
PACKAGECONFIG[gstreamer] = "-DQT_FEATURE_gstreamer=ON,-DQT_FEATURE_gstreamer=OFF,gstreamer1.0,gstreamer1.0"
