import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
    radius: 10
    border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
    border.width: 2
    
    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        // Header
        Row {
            width: parent.width
            spacing: 10
            
            Text {
                text: "📝 Current Transcription"
                font.pixelSize: 16
                font.bold: true
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Item { Layout.fillWidth: true }
        }
        
        // Transcription text area
        ScrollView {
            width: parent.width
            height: parent.height - 40
            clip: true
            
            TextArea {
                id: transcriptionText
                text: audioEngine.currentTranscription || "Your transcription will appear here..."
                wrapMode: Text.WordWrap
                readOnly: true
                selectByMouse: true
                font.pixelSize: 16
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
                
                background: Rectangle {
                    color: "transparent"
                }
                
                placeholderText: "Waiting for speech input..."
                placeholderTextColor: settingsManager.darkMode ? "#666666" : "#999999"
            }
        }
    }
    
    // Empty state
    Column {
        anchors.centerIn: parent
        spacing: 15
        visible: !audioEngine.currentTranscription
        
        Text {
            text: "🎤"
            font.pixelSize: 48
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            text: "Start speaking to see transcription"
            font.pixelSize: 14
            color: settingsManager.darkMode ? "#999999" : "#666666"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}

