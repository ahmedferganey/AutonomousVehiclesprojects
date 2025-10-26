import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15

/**
 * Camera Panel - Computer vision and gesture recognition display
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
    
    property bool cameraActive: false
    property bool gestureDetectionEnabled: true
    property bool driverMonitoringEnabled: true
    property string currentGesture: ""
    property real driverAlertness: 0.85
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header with controls
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15
                
                Text {
                    text: "📹 Camera View"
                    font.pixelSize: 18
                    font.bold: true
                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                }
                
                Item { Layout.fillWidth: true }
                
                Switch {
                    text: "Gesture Detection"
                    checked: gestureDetectionEnabled
                    onToggled: gestureDetectionEnabled = checked
                }
                
                Switch {
                    text: "Driver Monitoring"
                    checked: driverMonitoringEnabled
                    onToggled: driverMonitoringEnabled = checked
                }
                
                Button {
                    text: cameraActive ? "Stop Camera" : "Start Camera"
                    onClicked: cameraActive = !cameraActive
                    
                    background: Rectangle {
                        color: cameraActive ? "#ff3b30" : "#007aff"
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
        }
        
        // Camera view
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Placeholder for camera feed
            Rectangle {
                anchors.fill: parent
                color: settingsManager.darkMode ? "#0d1117" : "#e1e4e8"
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    visible: !cameraActive
                    
                    Text {
                        text: "📷"
                        font.pixelSize: 64
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.3
                    }
                    
                    Text {
                        text: cameraActive ? "Camera Active" : "Camera Inactive"
                        font.pixelSize: 18
                        color: settingsManager.darkMode ? "#ffffff" : "#333333"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Click 'Start Camera' to enable\ncomputer vision features"
                        font.pixelSize: 14
                        color: settingsManager.darkMode ? "#999999" : "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                
                // Gesture recognition overlay
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 20
                    width: 250
                    height: 100
                    color: Qt.rgba(0, 0, 0, 0.7)
                    radius: 10
                    visible: cameraActive && gestureDetectionEnabled
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        Text {
                            text: "👋 Gesture Detected"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: currentGesture || "No gesture"
                            font.pixelSize: 14
                            color: "#34c759"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Swipe left/right, thumbs up/down"
                            font.pixelSize: 11
                            color: "#999999"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                
                // Driver monitoring overlay
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 20
                    width: 250
                    height: 150
                    color: Qt.rgba(0, 0, 0, 0.7)
                    radius: 10
                    visible: cameraActive && driverMonitoringEnabled
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: "👁️ Driver Monitoring"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#ffffff"
                        }
                        
                        RowLayout {
                            width: parent.width
                            spacing: 10
                            
                            Text {
                                text: "Alertness:"
                                font.pixelSize: 12
                                color: "#999999"
                            }
                            
                            ProgressBar {
                                Layout.fillWidth: true
                                from: 0
                                to: 1.0
                                value: driverAlertness
                                
                                background: Rectangle {
                                    implicitWidth: 200
                                    implicitHeight: 6
                                    color: "#3d3d3d"
                                    radius: 3
                                }
                                
                                contentItem: Item {
                                    implicitWidth: 200
                                    implicitHeight: 6
                                    
                                    Rectangle {
                                        width: parent.parent.visualPosition * parent.width
                                        height: parent.height
                                        radius: 3
                                        color: driverAlertness > 0.7 ? "#34c759" : (driverAlertness > 0.4 ? "#ff9500" : "#ff3b30")
                                    }
                                }
                            }
                            
                            Text {
                                text: Math.floor(driverAlertness * 100) + "%"
                                font.pixelSize: 12
                                color: driverAlertness > 0.7 ? "#34c759" : (driverAlertness > 0.4 ? "#ff9500" : "#ff3b30")
                            }
                        }
                        
                        Column {
                            spacing: 5
                            
                            StatusRow {
                                label: "Eyes on Road"
                                status: driverAlertness > 0.6
                            }
                            
                            StatusRow {
                                label: "Head Position"
                                status: driverAlertness > 0.5
                            }
                            
                            StatusRow {
                                label: "No Distraction"
                                status: driverAlertness > 0.7
                            }
                        }
                    }
                }
            }
        }
        
        // Info bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            GridLayout {
                anchors.fill: parent
                anchors.margins: 15
                columns: 4
                rowSpacing: 5
                columnSpacing: 20
                
                InfoBox {
                    icon: "👋"
                    label: "Gestures"
                    value: "5 detected"
                }
                
                InfoBox {
                    icon: "😴"
                    label: "Fatigue"
                    value: driverAlertness > 0.7 ? "Normal" : "Warning"
                    valueColor: driverAlertness > 0.7 ? "#34c759" : "#ff9500"
                }
                
                InfoBox {
                    icon: "👥"
                    label: "Occupants"
                    value: "1"
                }
                
                InfoBox {
                    icon: "🚗"
                    label: "Objects"
                    value: "None"
                }
            }
        }
    }
    
    // Status Row Component
    component StatusRow: RowLayout {
        property string label: ""
        property bool status: false
        
        spacing: 10
        
        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: status ? "#34c759" : "#ff3b30"
        }
        
        Text {
            text: label
            font.pixelSize: 11
            color: "#cccccc"
        }
    }
    
    // Info Box Component
    component InfoBox: Column {
        property string icon: ""
        property string label: ""
        property string value: ""
        property color valueColor: settingsManager.darkMode ? "#ffffff" : "#333333"
        
        spacing: 5
        
        Text {
            text: icon
            font.pixelSize: 24
        }
        
        Text {
            text: label
            font.pixelSize: 12
            color: settingsManager.darkMode ? "#999999" : "#666666"
        }
        
        Text {
            text: value
            font.pixelSize: 14
            font.bold: true
            color: valueColor
        }
    }
}

