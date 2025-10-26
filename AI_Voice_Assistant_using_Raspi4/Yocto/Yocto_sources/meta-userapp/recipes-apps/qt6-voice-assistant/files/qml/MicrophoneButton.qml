import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 150
    height: 150
    
    property bool isListening: false
    property bool isProcessing: false
    
    signal clicked()
    
    // Pulsing animation for listening state
    SequentialAnimation on scale {
        running: isListening
        loops: Animation.Infinite
        NumberAnimation { to: 1.05; duration: 800; easing.type: Easing.InOutQuad }
        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
    }
    
    Rectangle {
        id: outerCircle
        anchors.centerIn: parent
        width: 150
        height: 150
        radius: 75
        
        color: {
            if (isProcessing) return "#ff9500"
            if (isListening) return "#007aff"
            return "#34c759"
        }
        
        Behavior on color {
            ColorAnimation { duration: 300 }
        }
        
        // Ripple effect
        Rectangle {
            id: ripple
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: parent.radius
            color: "transparent"
            border.color: parent.color
            border.width: 3
            opacity: 0
            
            SequentialAnimation on opacity {
                running: isListening
                loops: Animation.Infinite
                NumberAnimation { to: 0.7; duration: 1000 }
                NumberAnimation { to: 0; duration: 1000 }
            }
            
            SequentialAnimation on scale {
                running: isListening
                loops: Animation.Infinite
                NumberAnimation { to: 1.3; duration: 2000 }
                PropertyAction { target: ripple; property: "scale"; value: 1.0 }
            }
        }
        
        // Inner circle (button)
        Rectangle {
            id: innerCircle
            anchors.centerIn: parent
            width: 120
            height: 120
            radius: 60
            color: Qt.lighter(parent.color, 1.2)
            
            // Microphone icon
            Text {
                anchors.centerIn: parent
                text: {
                    if (isProcessing) return "⏳"
                    if (isListening) return "🎤"
                    return "🎙️"
                }
                font.pixelSize: 48
            }
            
            // Rotating animation for processing
            RotationAnimation on rotation {
                running: isProcessing
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 2000
            }
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
            
            // Press effect
            onPressed: {
                innerCircle.scale = 0.95
            }
            
            onReleased: {
                innerCircle.scale = 1.0
            }
        }
    }
    
    // Button label
    Text {
        anchors.top: outerCircle.bottom
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        text: {
            if (isProcessing) return "Processing..."
            if (isListening) return "Tap to Process"
            return "Tap to Start"
        }
        font.pixelSize: 16
        font.bold: true
        color: settingsManager.darkMode ? "#ffffff" : "#333333"
    }
}

