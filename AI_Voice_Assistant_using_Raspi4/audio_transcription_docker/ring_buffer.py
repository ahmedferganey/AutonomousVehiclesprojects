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
        """
        Write audio data to the buffer.
        :param data: Audio chunk to add to the buffer.
        """
        self.buffer.extend(data)

    def read(self, size):
        """
        Read audio data from the buffer.
        :param size: Number of audio samples to read.
        :return: List of audio data (up to size).
        """
        data = []
        for _ in range(size):
            if self.buffer:
                data.append(self.buffer.popleft())
            else:
                break
        return data

    def __len__(self):
        """Return the current number of samples in the buffer."""
        return len(self.buffer)
