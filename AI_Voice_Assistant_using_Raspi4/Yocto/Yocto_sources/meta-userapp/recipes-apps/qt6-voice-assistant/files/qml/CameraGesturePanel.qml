import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15

/**
 * Camera & Gesture Recognition Panel - Computer vision features
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
    
    property bool cameraActive: false
    property bool gestureRecognitionEnabled: true
    property bool driverMonitoringEnabled: true
    property string detectedGesture: ""
    property real drowsinessLevel: 0.0 // 0.0 - 1.0
    property int occupantCount: 0
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                
                Text {
                    text: "📷 Camera & Gestures"
                    font.pixelSize: 18
                    font.bold: true
                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                }
                
                Item { Layout.fillWidth: true }
                
                Switch {
                    text: "Camera"
                    checked: cameraActive
                    onToggled: cameraActive = checked
                }
            }
        }
        
        // Camera Feed
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Camera preview (placeholder)
            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                color: "#000000"
                radius: 10
                
                // Placeholder when camera is off
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    visible: !cameraActive
                    
                    Text {
                        text: "📷"
                        font.pixelSize: 80
                        color: "#666666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Camera is off"
                        font.pixelSize: 18
                        color: "#999999"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Button {
                        text: "Enable Camera"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: cameraActive = true
                        
                        background: Rectangle {
                            color: parent.hovered ? "#0066cc" : "#007aff"
                            radius: 20
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                
                // Camera feed placeholder when active
                Column {
                    anchors.centerIn: parent
                    spacing: 15
                    visible: cameraActive
                    
                    Text {
                        text: "📹 Camera Active"
                        font.pixelSize: 20
                        color: "#00ff00"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Rectangle {
                        width: 320
                        height: 240
                        color: "#1a1a1a"
                        border.color: "#00ff00"
                        border.width: 2
                        radius: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Camera Feed\n(Requires QtMultimedia Camera)"
                            color: "#666666"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                // Gesture Detection Overlay
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 20
                    width: 250
                    height: detectedGesture ? 80 : 0
                    color: Qt.rgba(0, 122, 255, 0.9)
                    radius: 10
                    visible: cameraActive && gestureRecognitionEnabled && detectedGesture
                    
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Text {
                            text: "Gesture Detected:"
                            font.pixelSize: 12
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: detectedGesture
                            font.pixelSize: 20
                            font.bold: true
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                
                // Driver Monitoring Alert
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 20
                    width: 200
                    height: drowsinessLevel > 0.5 ? 100 : 0
                    color: drowsinessLevel > 0.7 ? Qt.rgba(255, 59, 48, 0.9) : Qt.rgba(255, 149, 0, 0.9)
                    radius: 10
                    visible: cameraActive && driverMonitoringEnabled
                    
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "⚠️"
                            font.pixelSize: 32
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Driver Alert!"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Drowsiness detected"
                            font.pixelSize: 12
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                
                // Occupancy Counter
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 20
                    width: 150
                    height: 60
                    color: Qt.rgba(52, 199, 89, 0.8)
                    radius: 10
                    visible: cameraActive
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Text {
                            text: "👥 Occupants"
                            font.pixelSize: 12
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: occupantCount.toString()
                            font.pixelSize: 24
                            font.bold: true
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
        
        // Feature Controls
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            GridLayout {
                anchors.fill: parent
                anchors.margins: 20
                columns: 2
                rowSpacing: 15
                columnSpacing: 20
                
                // Gesture Recognition Toggle
                Row {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Switch {
                        id: gestureSwitch
                        checked: gestureRecognitionEnabled
                        onToggled: gestureRecognitionEnabled = checked
                    }
                    
                    Column {
                        spacing: 3
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: "Gesture Recognition"
                            font.pixelSize: 14
                            font.bold: true
                            color: settingsManager.darkMode ? "#ffffff" : "#333333"
                        }
                        
                        Text {
                            text: "Control with hand gestures"
                            font.pixelSize: 11
                            color: settingsManager.darkMode ? "#999999" : "#666666"
                        }
                    }
                }
                
                // Driver Monitoring Toggle
                Row {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Switch {
                        checked: driverMonitoringEnabled
                        onToggled: driverMonitoringEnabled = checked
                    }
                    
                    Column {
                        spacing: 3
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: "Driver Monitoring"
                            font.pixelSize: 14
                            font.bold: true
                            color: settingsManager.darkMode ? "#ffffff" : "#333333"
                        }
                        
                        Text {
                            text: "Drowsiness detection"
                            font.pixelSize: 11
                            color: settingsManager.darkMode ? "#999999" : "#666666"
                        }
                    }
                }
                
                // Supported Gestures Info
                Column {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: "Supported Gestures:"
                        font.pixelSize: 12
                        font.bold: true
                        color: settingsManager.darkMode ? "#999999" : "#666666"
                    }
                    
                    Flow {
                        width: parent.width
                        spacing: 5
                        
                        Repeater {
                            model: ["👍 Thumbs Up", "👎 Thumbs Down", "✋ Palm Stop", "👌 OK", "☝️ Point"]
                            
                            Rectangle {
                                width: gestureLabel.width + 16
                                height: 28
                                color: settingsManager.darkMode ? "#3d3d3d" : "#e0e0e0"
                                radius: 14
                                
                                Text {
                                    id: gestureLabel
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 11
                                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Test Gesture Function (for development)
    Timer {
        interval: 5000
        running: cameraActive && gestureRecognitionEnabled
        repeat: true
        onTriggered: {
            // Simulate gesture detection
            var gestures = ["Thumbs Up", "OK", "Palm Stop", ""]
            detectedGesture = gestures[Math.floor(Math.random() * gestures.length)]
            
            if (detectedGesture) {
                // Clear after 2 seconds
                clearGestureTimer.start()
            }
        }
    }
    
    Timer {
        id: clearGestureTimer
        interval: 2000
        onTriggered: detectedGesture = ""
    }
    
    // Simulate drowsiness level changes
    Timer {
        interval: 3000
        running: cameraActive && driverMonitoringEnabled
        repeat: true
        onTriggered: {
            drowsinessLevel = Math.random()
            occupantCount = Math.floor(Math.random() * 5) + 1
        }
    }
}

