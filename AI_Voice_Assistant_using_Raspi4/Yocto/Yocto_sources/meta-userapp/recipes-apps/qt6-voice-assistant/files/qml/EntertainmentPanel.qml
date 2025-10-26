import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * Entertainment Panel - Media player with voice control
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
    radius: 10
    
    property string currentTrack: "No track playing"
    property string currentArtist: ""
    property string currentAlbum: ""
    property real progress: 0.0
    property real duration: 0.0
    property bool isPlaying: false
    property int volume: 50
    property string source: "Spotify" // Spotify, Radio, Local
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "🎵 Entertainment"
                font.pixelSize: 20
                font.bold: true
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
            }
            
            Item { Layout.fillWidth: true }
            
            // Source selector
            ComboBox {
                model: ["Spotify", "Radio", "Local Files", "Podcasts"]
                currentIndex: model.indexOf(source)
                onActivated: source = currentText
            }
        }
        
        // Album Art
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: settingsManager.darkMode ? "#1a1a1a" : "#f0f0f0"
            radius: 10
            
            Column {
                anchors.centerIn: parent
                spacing: 10
                
                Text {
                    text: "🎨"
                    font.pixelSize: 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: 0.5
                }
                
                Text {
                    text: "Album Art"
                    font.pixelSize: 14
                    color: settingsManager.darkMode ? "#666666" : "#999999"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        // Track Info
        Column {
            Layout.fillWidth: true
            spacing: 5
            
            Text {
                text: currentTrack
                font.pixelSize: 18
                font.bold: true
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
                elide: Text.ElideRight
                width: parent.width
            }
            
            Text {
                text: currentArtist
                font.pixelSize: 14
                color: settingsManager.darkMode ? "#999999" : "#666666"
                elide: Text.ElideRight
                width: parent.width
            }
            
            Text {
                text: currentAlbum
                font.pixelSize: 12
                color: settingsManager.darkMode ? "#666666" : "#999999"
                elide: Text.ElideRight
                width: parent.width
            }
        }
        
        // Progress Bar
        Column {
            Layout.fillWidth: true
            spacing: 5
            
            Slider {
                width: parent.width
                from: 0
                to: duration
                value: progress
                
                background: Rectangle {
                    x: parent.leftPadding
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 4
                    width: parent.availableWidth
                    height: implicitHeight
                    radius: 2
                    color: settingsManager.darkMode ? "#3d3d3d" : "#e0e0e0"
                    
                    Rectangle {
                        width: parent.parent.visualPosition * parent.width
                        height: parent.height
                        color: "#007aff"
                        radius: 2
                    }
                }
            }
            
            RowLayout {
                width: parent.width
                
                Text {
                    text: formatTime(progress)
                    font.pixelSize: 12
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: formatTime(duration)
                    font.pixelSize: 12
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                }
            }
        }
        
        // Playback Controls
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            
            Button {
                text: "⏮️"
                font.pixelSize: 24
                flat: true
                onClicked: {
                    // Previous track
                }
                
                ToolTip.visible: hovered
                ToolTip.text: "Previous"
            }
            
            Button {
                text: "⏪"
                font.pixelSize: 24
                flat: true
                onClicked: {
                    // Rewind
                }
                
                ToolTip.visible: hovered
                ToolTip.text: "Rewind 10s"
            }
            
            Button {
                text: isPlaying ? "⏸️" : "▶️"
                font.pixelSize: 32
                
                Layout.preferredWidth: 70
                Layout.preferredHeight: 70
                
                onClicked: {
                    isPlaying = !isPlaying
                }
                
                background: Rectangle {
                    color: parent.pressed ? "#005cbf" : (parent.hovered ? "#0066cc" : "#007aff")
                    radius: 35
                }
                
                ToolTip.visible: hovered
                ToolTip.text: isPlaying ? "Pause" : "Play"
            }
            
            Button {
                text: "⏩"
                font.pixelSize: 24
                flat: true
                onClicked: {
                    // Fast forward
                }
                
                ToolTip.visible: hovered
                ToolTip.text: "Forward 10s"
            }
            
            Button {
                text: "⏭️"
                font.pixelSize: 24
                flat: true
                onClicked: {
                    // Next track
                }
                
                ToolTip.visible: hovered
                ToolTip.text: "Next"
            }
        }
        
        // Volume Control
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "🔈"
                font.pixelSize: 20
            }
            
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: volume
                onMoved: volume = value
            }
            
            Text {
                text: "🔊"
                font.pixelSize: 20
            }
            
            Text {
                text: volume + "%"
                font.pixelSize: 14
                color: settingsManager.darkMode ? "#999999" : "#666666"
                Layout.preferredWidth: 40
            }
        }
        
        // Voice Commands
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
            radius: 8
            
            Column {
                anchors.centerIn: parent
                spacing: 5
                
                Text {
                    text: "🎤 Voice Commands"
                    font.pixelSize: 12
                    font.bold: true
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "\"Play [song]\", \"Next track\", \"Volume up\""
                    font.pixelSize: 11
                    color: settingsManager.darkMode ? "#666666" : "#999999"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "\"Pause\", \"Resume\", \"Play radio\""
                    font.pixelSize: 11
                    color: settingsManager.darkMode ? "#666666" : "#999999"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        Item { Layout.fillHeight: true }
    }
    
    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60);
        var secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
}
