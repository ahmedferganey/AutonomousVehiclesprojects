import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * Voice Response Panel - Shows TTS voice responses with animation
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
    radius: 10
    border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
    border.width: 2
    
    property alias ttsEngine: root.ttsEngine
    property var ttsEngine: null
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        // Header
        Row {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "🔊 Voice Response"
                font.pixelSize: 16
                font.bold: true
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Item { Layout.fillWidth: true }
            
            // Volume control
            Row {
                spacing: 5
                
                Text {
                    text: "🔉"
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Slider {
                    width: 100
                    from: 0.0
                    to: 1.0
                    value: ttsEngine ? ttsEngine.volume : 1.0
                    onMoved: if (ttsEngine) ttsEngine.volume = value
                }
            }
            
            // Enable/Disable toggle
            Switch {
                checked: ttsEngine ? ttsEngine.enabled : true
                onToggled: if (ttsEngine) ttsEngine.enabled = checked
            }
        }
        
        // Speaking indicator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: ttsEngine && ttsEngine.isSpeaking ? "#007aff" : "transparent"
            radius: 25
            visible: ttsEngine && ttsEngine.isSpeaking
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 10
                
                // Animated speaking icon
                Text {
                    text: "🗣️"
                    font.pixelSize: 24
                    
                    SequentialAnimation on scale {
                        running: ttsEngine && ttsEngine.isSpeaking
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.2; duration: 500 }
                        NumberAnimation { to: 1.0; duration: 500 }
                    }
                }
                
                Text {
                    text: "Speaking..."
                    font.pixelSize: 16
                    font.bold: true
                    color: "#ffffff"
                }
                
                // Animated dots
                Row {
                    spacing: 3
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: "#ffffff"
                            
                            SequentialAnimation on opacity {
                                running: ttsEngine && ttsEngine.isSpeaking
                                loops: Animation.Infinite
                                PauseAnimation { duration: index * 200 }
                                NumberAnimation { to: 0.3; duration: 400 }
                                NumberAnimation { to: 1.0; duration: 400 }
                            }
                        }
                    }
                }
            }
        }
        
        // Response text display
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            TextArea {
                text: ttsEngine ? ttsEngine.currentText : ""
                wrapMode: Text.WordWrap
                readOnly: true
                font.pixelSize: 14
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
                
                background: Rectangle {
                    color: "transparent"
                }
                
                // Highlight current word being spoken
                // This would be implemented with word boundary events
            }
        }
        
        // Controls
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            
            Button {
                text: "⏸️"
                enabled: ttsEngine && ttsEngine.isSpeaking
                onClicked: if (ttsEngine) ttsEngine.pause()
                
                ToolTip.visible: hovered
                ToolTip.text: "Pause"
            }
            
            Button {
                text: "▶️"
                enabled: ttsEngine && ttsEngine.isSpeaking
                onClicked: if (ttsEngine) ttsEngine.resume()
                
                ToolTip.visible: hovered
                ToolTip.text: "Resume"
            }
            
            Button {
                text: "⏹️"
                enabled: ttsEngine && ttsEngine.isSpeaking
                onClicked: if (ttsEngine) ttsEngine.stop()
                
                ToolTip.visible: hovered
                ToolTip.text: "Stop"
            }
        }
        
        // Voice settings
        Row {
            Layout.fillWidth: true
            spacing: 15
            
            Column {
                spacing: 5
                
                Text {
                    text: "Voice:"
                    font.pixelSize: 12
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                }
                
                ComboBox {
                    width: 150
                    model: ttsEngine ? ttsEngine.getAvailableVoices() : []
                    currentIndex: model.indexOf(ttsEngine ? ttsEngine.voice : "default")
                    onActivated: if (ttsEngine) ttsEngine.voice = currentText
                }
            }
            
            Column {
                spacing: 5
                
                Text {
                    text: "Speed: " + (ttsEngine ? ttsEngine.rate.toFixed(1) : "1.0") + "x"
                    font.pixelSize: 12
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                }
                
                Slider {
                    width: 150
                    from: 0.5
                    to: 2.0
                    stepSize: 0.1
                    value: ttsEngine ? ttsEngine.rate : 1.0
                    onMoved: if (ttsEngine) ttsEngine.rate = value
                }
            }
        }
    }
    
    // Empty state
    Column {
        anchors.centerIn: parent
        spacing: 15
        visible: !ttsEngine || (!ttsEngine.isSpeaking && !ttsEngine.currentText)
        
        Text {
            text: "🔇"
            font.pixelSize: 48
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0.5
        }
        
        Text {
            text: "Voice responses will appear here"
            font.pixelSize: 14
            color: settingsManager.darkMode ? "#999999" : "#666666"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}

