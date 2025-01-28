import sounddevice as sd
import numpy as np
from collections import deque


class RingBuffer:
    """A thread-safe ring buffer for streaming audio data."""

    def __init__(self, max_size):
        """
        Initialize the ring buffer.
        :param max_size: Maximum number of audio samples to store.
        """
        self.buffer = deque(maxlen=max_size)

    def write(self, data):
        """Write audio data to the buffer."""
        self.buffer.extend(data)

    def read(self):
        """Read and return all data from the buffer."""
        data = []
        while self.buffer:
            data.append(self.buffer.popleft())
        return np.array(data)

    def __len__(self):
        """Return the current number of samples in the buffer."""
        return len(self.buffer)


class AudioInputHandler:
    """Handles audio streaming and buffering."""

    def __init__(self, max_duration=60, silence_threshold=0.01):
        self.ring_buffer = RingBuffer(max_size=16000 * max_duration)  # Store up to 1 minute of audio
        self.stream = None
        self.running = False
        self.silence_threshold = silence_threshold

    def audio_callback(self, indata, frames, time, status):
        """Callback for audio streaming."""
        if status:
            print(f"Audio stream status: {status}")
        audio_data = indata[:, 0]  # Get mono audio
        if np.max(np.abs(audio_data)) > self.silence_threshold:  # Avoid silence
            self.ring_buffer.write(audio_data)

    def start_stream(self):
        """Start streaming audio."""
        self.running = True
        self.stream = sd.InputStream(
            samplerate=16000,
            blocksize=1024,
            dtype="float32",
            channels=1,
            callback=self.audio_callback,
        )
        self.stream.start()

    def stop_stream(self):
        """Stop streaming and close resources."""
        if self.stream:
            self.stream.stop()
            self.stream.close()
        self.running = False

    def get_last_minute_data(self):
        """Get the data buffered in the last minute."""
        return self.ring_buffer.read()
