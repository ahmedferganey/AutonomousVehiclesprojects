import whisper


class WhisperTranscriber:
    """Handles transcription logic using the Whisper model."""

    def __init__(self):
        self.model = whisper.load_model("base")  # Load Whisper model

    def transcribe(self, audio_data):
        """Transcribe audio data."""
        try:
            # Assuming audio_data is properly formatted and passed as required
            result = self.model.transcribe(audio_data)
            print("Transcription result:", result.get("text", ""))
            return result.get("text", "")
        except Exception as e:
            print(f"Error in transcription: {e}")
            return ""
