## ONNX Runtime & TensorFlow Lite – Minimal, Low-Risk Plan (Kirkstone + Qt 6.5)

Goals
- Build CPU-only ONNX Runtime and TensorFlow Lite with minimal risk.
- Avoid previous failures (NumPy headers, Abseil/Protobuf/Flatbuffers target issues, optional backends).
- Keep them out of the image until both build clean; then opt-in.

Assumptions
- Yocto: kirkstone; Layers: poky, meta-openembedded, meta-qt6; Machine: raspberrypi4-64
- Qt 6.5 LTS already selected via meta-qt6 lts-6.5
- OpenCV pinned to 4.5.5 (not 4.11)

Local.conf – Keep/Ensure
- OpenCV version: keep one pin only
  - PREFERRED_VERSION_opencv = "4.5.5"
- FFmpeg license accepted (already set)
  - LICENSE_FLAGS_ACCEPTED += "commercial_ffmpeg"
- Do NOT add ONNX/TFLite to the image yet
  - Do NOT add: IMAGE_INSTALL += " onnxruntime libtensorflow-lite"
- Keep OpenCV Python bindings OFF (already set)
  - PACKAGECONFIG:remove:pn-opencv = " python3"

Local.conf – Optional later (after both build clean)
- IMAGE_INSTALL:append = " onnxruntime libtensorflow-lite"

Build Order (run from poky/building)
1) Initialize env
   - source ../poky/oe-init-build-env .
2) Build TFLite core (CPU-only default)
   - bitbake -k tensorflow-lite
3) Build ONNX Runtime (CPU-only default)
   - bitbake -k onnxruntime
4) If both succeed, include in image and rebuild
   - echo 'IMAGE_INSTALL:append = " onnxruntime libtensorflow-lite"' >> conf/local.conf
   - bitbake -k core-image-base

Validation Checks
- Package data (post-build)
  - oe-pkgdata-util list-pkgs | grep -E '^(onnxruntime|libtensorflow-lite)(\b|-)'
  - oe-pkgdata-util list-pkg-files onnxruntime | head -40
  - oe-pkgdata-util list-pkg-files libtensorflow-lite | head -40

Troubleshooting Fast-Paths
- NumPy header errors during Python builds (OpenCV):
  - Ensure OpenCV Python is disabled (no PACKAGECONFIG python3 for opencv)
- TFLite Abseil/Protobuf/Flatbuffers target not found:
  - Share exact error; we will pin Flatbuffers/Abseil/Protobuf minimally to recipe-required versions only if needed
- ONNX Runtime optional backends pulling deps (CUDA/OpenVINO/TensorRT):
  - Keep default CPU-only; do not enable PACKAGECONFIG for those backends

Outcome
- Clean CPU-only builds for ONNX Runtime and TensorFlow Lite
- Safe opt-in to the final image only after successful builds


