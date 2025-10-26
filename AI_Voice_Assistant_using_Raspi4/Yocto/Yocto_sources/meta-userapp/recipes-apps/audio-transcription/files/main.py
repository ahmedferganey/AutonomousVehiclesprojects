import sys
from PyQt5.QtWidgets import (
    QApplication,
    QMainWindow,
    QPushButton,
    QVBoxLayout,
    QWidget,
    QTextEdit,
    QLabel,
)
from PyQt5.QtCore import QThread, pyqtSignal
from audio_capture import AudioInputHandler
from whisper_model import WhisperTranscriber


class TranscriptionWorker(QThread):
    transcription_done = pyqtSignal(str)

    def __init__(self, audio_handler, transcriber):
        super().__init__()
        self.audio_handler = audio_handler
        self.transcriber = transcriber

    def run(self):
        # Fetch audio data and perform transcription
        audio_data = self.audio_handler.get_last_minute_data()
        transcription = self.transcriber.transcribe(audio_data)
        self.transcription_done.emit(transcription)


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Audio Stream Transcription")
        self.setGeometry(200, 200, 500, 300)

        # Initialize components
        self.audio_handler = AudioInputHandler(max_duration=60)
        self.transcriber = WhisperTranscriber()
        self.transcription_thread = None

        # Create UI elements
        self.layout = QVBoxLayout()
        self.status_label = QLabel("Status: Ready")
        self.transcription_output = QTextEdit()
        self.transcription_output.setReadOnly(True)

        self.start_button = QPushButton("Start Streaming")
        self.stop_button = QPushButton("Stop Streaming")
        self.transcribe_button = QPushButton("Transcribe")

        # Add elements to layout
        self.layout.addWidget(self.status_label)
        self.layout.addWidget(self.transcription_output)
        self.layout.addWidget(self.start_button)
        self.layout.addWidget(self.stop_button)
        self.layout.addWidget(self.transcribe_button)

        # Set central widget
        central_widget = QWidget()
        central_widget.setLayout(self.layout)
        self.setCentralWidget(central_widget)

        # Connect buttons to actions
        self.start_button.clicked.connect(self.start_streaming)
        self.stop_button.clicked.connect(self.stop_streaming)
        self.transcribe_button.clicked.connect(self.transcribe_audio)

    def start_streaming(self):
        if not self.audio_handler.running:
            self.audio_handler.start_stream()
            self.status_label.setText("Status: Streaming Audio")
            print("Started streaming audio.")

    def stop_streaming(self):
        if self.audio_handler.running:
            self.audio_handler.stop_stream()
            self.status_label.setText("Status: Streaming Stopped")
            print("Stopped streaming audio.")

    def transcribe_audio(self):
        self.status_label.setText("Status: Transcribing Audio...")
        self.transcription_thread = TranscriptionWorker(
            self.audio_handler, self.transcriber
        )
        self.transcription_thread.transcription_done.connect(self.display_transcription)
        self.transcription_thread.start()

    def display_transcription(self, transcription):
        self.status_label.setText("Status: Ready")
        self.transcription_output.append(f"Transcription:\n{transcription}")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())

