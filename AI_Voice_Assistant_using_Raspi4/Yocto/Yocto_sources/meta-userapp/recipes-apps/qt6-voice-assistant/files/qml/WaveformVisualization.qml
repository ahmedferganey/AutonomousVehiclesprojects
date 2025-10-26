import QtQuick 2.15

Item {
    id: root
    
    property real audioLevel: 0.0
    property bool isActive: false
    property color waveColor: "#007aff"
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
        radius: 10
        border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
        border.width: 2
    }
    
    // Waveform canvas
    Canvas {
        id: waveformCanvas
        anchors.fill: parent
        anchors.margins: 10
        
        property var audioHistory: []
        property int maxHistoryLength: 100
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            if (!isActive || audioHistory.length === 0) {
                // Draw idle state
                drawIdleWave(ctx);
                return;
            }
            
            // Draw active waveform
            drawActiveWaveform(ctx);
        }
        
        function drawIdleWave(ctx) {
            ctx.strokeStyle = Qt.lighter(waveColor, 1.5);
            ctx.lineWidth = 2;
            ctx.beginPath();
            
            var amplitude = 20;
            var frequency = 0.02;
            var phase = Date.now() * 0.001;
            
            for (var x = 0; x < width; x++) {
                var y = height / 2 + Math.sin(x * frequency + phase) * amplitude;
                if (x === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            }
            
            ctx.stroke();
        }
        
        function drawActiveWaveform(ctx) {
            ctx.strokeStyle = waveColor;
            ctx.lineWidth = 3;
            ctx.beginPath();
            
            var step = width / maxHistoryLength;
            
            for (var i = 0; i < audioHistory.length; i++) {
                var x = i * step;
                var level = audioHistory[i];
                var y = height / 2 + (level - 0.5) * height * 0.8;
                
                if (i === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            }
            
            ctx.stroke();
            
            // Draw bars
            ctx.fillStyle = Qt.rgba(waveColor.r, waveColor.g, waveColor.b, 0.3);
            for (var j = 0; j < audioHistory.length; j++) {
                var barX = j * step;
                var barLevel = audioHistory[j];
                var barHeight = barLevel * height * 0.8;
                var barY = height / 2 - barHeight / 2;
                
                ctx.fillRect(barX, barY, step * 0.8, barHeight);
            }
        }
        
        Timer {
            interval: 50
            running: true
            repeat: true
            onTriggered: {
                if (isActive) {
                    waveformCanvas.audioHistory.push(audioLevel);
                    if (waveformCanvas.audioHistory.length > waveformCanvas.maxHistoryLength) {
                        waveformCanvas.audioHistory.shift();
                    }
                } else {
                    waveformCanvas.audioHistory = [];
                }
                waveformCanvas.requestPaint();
            }
        }
    }
    
    // Center line
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 20
        height: 1
        color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
        opacity: 0.5
    }
    
    // Audio level text
    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 15
        text: isActive ? "Level: " + (audioLevel * 100).toFixed(0) + "%" : "Idle"
        font.pixelSize: 12
        color: settingsManager.darkMode ? "#cccccc" : "#666666"
    }
}

