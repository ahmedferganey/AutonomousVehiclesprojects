import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: mainWindow
    
    property bool isDarkMode: settingsManager.darkMode
    property color backgroundColor: isDarkMode ? "#1a1a1a" : "#f5f5f5"
    property color cardColor: isDarkMode ? "#2d2d2d" : "#ffffff"
    property color textColor: isDarkMode ? "#ffffff" : "#333333"
    property color accentColor: "#007aff"
    property color errorColor: "#ff3b30"
    property color successColor: "#34c759"
    
    // State management
    state: audioEngine.status
    
    states: [
        State {
            name: "Ready"
            PropertyChanges { target: statusIndicator; statusText: "Ready"; statusColor: mainWindow.successColor }
        },
        State {
            name: "Listening"
            PropertyChanges { target: statusIndicator; statusText: "Listening..."; statusColor: mainWindow.accentColor }
        },
        State {
            name: "Processing"
            PropertyChanges { target: statusIndicator; statusText: "Processing..."; statusColor: "#ff9500" }
        },
        State {
            name: "Error"
            PropertyChanges { target: statusIndicator; statusText: "Error"; statusColor: mainWindow.errorColor }
        }
    ]
    
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: cardColor
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 15
                    
                    Text {
                        text: "🎙️ AI Voice Assistant"
                        font.pixelSize: 24
                        font.bold: true
                        color: textColor
                        Layout.fillWidth: true
                    }
                    
                    // Settings button
                    Button {
                        id: settingsButton
                        text: "⚙"
                        font.pixelSize: 24
                        flat: true
                        
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        
                        onClicked: settingsPanel.visible = !settingsPanel.visible
                        
                        background: Rectangle {
                            color: settingsButton.hovered ? Qt.lighter(cardColor, 1.1) : "transparent"
                            radius: 25
                        }
                    }
                    
                    // History button
                    Button {
                        id: historyButton
                        text: "📜"
                        font.pixelSize: 24
                        flat: true
                        
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        
                        onClicked: historyView.visible = !historyView.visible
                        
                        background: Rectangle {
                            color: historyButton.hovered ? Qt.lighter(cardColor, 1.1) : "transparent"
                            radius: 25
                        }
                    }
                }
            }
            
            // Main content area
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.9, 600)
                    spacing: 30
                    
                    // Status Indicator
                    StatusIndicator {
                        id: statusIndicator
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    // Waveform Visualization
                    WaveformVisualization {
                        id: waveform
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        audioLevel: audioEngine.audioLevel
                        isActive: audioEngine.isListening
                    }
                    
                    // Transcription Display
                    TranscriptionView {
                        id: transcriptionView
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                    }
                    
                    // Microphone Button
                    MicrophoneButton {
                        id: micButton
                        Layout.alignment: Qt.AlignHCenter
                        isListening: audioEngine.isListening
                        isProcessing: audioEngine.isProcessing
                        
                        onClicked: {
                            if (audioEngine.isProcessing) {
                                audioEngine.cancelProcessing()
                            } else if (audioEngine.isListening) {
                                audioEngine.processAudio()
                            } else {
                                audioEngine.startListening()
                            }
                        }
                    }
                    
                    // Control buttons
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20
                        
                        Button {
                            text: audioEngine.isListening ? "Stop" : "Start"
                            enabled: !audioEngine.isProcessing
                            font.pixelSize: 16
                            
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 40
                            
                            onClicked: audioEngine.toggleListening()
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? Qt.lighter(accentColor, 1.2) : accentColor) : Qt.lighter(cardColor, 1.1)
                                radius: 20
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: parent.enabled ? "#ffffff" : Qt.darker(textColor, 1.5)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Button {
                            text: "Process"
                            enabled: audioEngine.isListening && !audioEngine.isProcessing
                            font.pixelSize: 16
                            
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 40
                            
                            onClicked: audioEngine.processAudio()
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? Qt.lighter(successColor, 1.2) : successColor) : Qt.lighter(cardColor, 1.1)
                                radius: 20
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: parent.enabled ? "#ffffff" : Qt.darker(textColor, 1.5)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
            
            // Footer
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: cardColor
                
                Text {
                    anchors.centerIn: parent
                    text: "Transcriptions: " + transcriptionModel.count
                    font.pixelSize: 14
                    color: Qt.darker(textColor, 1.3)
                }
            }
        }
        
        // Settings Panel (overlay)
        SettingsPanel {
            id: settingsPanel
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.min(parent.width * 0.8, 400)
            visible: false
            z: 10
        }
        
        // History View (overlay)
        HistoryView {
            id: historyView
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.min(parent.width * 0.8, 500)
            visible: false
            z: 10
        }
    }
    
    // Error handling
    Connections {
        target: audioEngine
        function onErrorOccurred(error) {
            errorDialog.text = error
            errorDialog.open()
        }
    }
    
    // Error Dialog
    Dialog {
        id: errorDialog
        title: "Error"
        modal: true
        anchors.centerIn: parent
        
        property alias text: errorText.text
        
        contentItem: ColumnLayout {
            spacing: 20
            
            Text {
                id: errorText
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: mainWindow.textColor
            }
            
            Button {
                text: "OK"
                Layout.alignment: Qt.AlignRight
                onClicked: errorDialog.close()
                
                background: Rectangle {
                    color: parent.hovered ? Qt.lighter(mainWindow.accentColor, 1.2) : mainWindow.accentColor
                    radius: 15
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        background: Rectangle {
            color: mainWindow.cardColor
            radius: 10
        }
    }
}

