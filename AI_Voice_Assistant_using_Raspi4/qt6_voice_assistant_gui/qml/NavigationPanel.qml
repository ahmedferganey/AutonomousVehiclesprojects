import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15

/**
 * Navigation Panel - Map display and voice-controlled navigation
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
    
    property string currentDestination: ""
    property real currentLatitude: 0.0
    property real currentLongitude: 0.0
    property bool navigationActive: false
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header with search
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                // Title and controls
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "🗺️ Navigation"
                        font.pixelSize: 18
                        font.bold: true
                        color: settingsManager.darkMode ? "#ffffff" : "#333333"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: navigationActive ? "Stop Navigation" : "Start"
                        onClicked: {
                            navigationActive = !navigationActive
                            if (!navigationActive) {
                                currentDestination = ""
                            }
                        }
                        
                        background: Rectangle {
                            color: navigationActive ? "#ff3b30" : "#007aff"
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
                
                // Search bar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "🔍 Search destination or say 'Navigate to...'"
                        font.pixelSize: 14
                        
                        background: Rectangle {
                            color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
                            radius: 20
                            border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
                            border.width: 1
                        }
                        
                        onAccepted: {
                            if (text.length > 0) {
                                currentDestination = text
                                navigationActive = true
                                // Trigger geocoding and routing
                            }
                        }
                    }
                    
                    Button {
                        text: "🎤"
                        onClicked: {
                            // Voice search activation
                            audioEngine.startListening()
                        }
                        
                        ToolTip.visible: hovered
                        ToolTip.text: "Voice Search"
                    }
                }
            }
        }
        
        // Map display
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Placeholder for map (requires QtLocation module)
            Rectangle {
                anchors.fill: parent
                color: settingsManager.darkMode ? "#0d1117" : "#e1e4e8"
                
                // Map would go here - QtLocation.Map
                // For now, showing placeholder with basic info
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Text {
                        text: "🗺️"
                        font.pixelSize: 64
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.3
                    }
                    
                    Text {
                        text: navigationActive ? "Navigating to:\n" + currentDestination : "No active navigation"
                        font.pixelSize: 18
                        font.bold: true
                        color: settingsManager.darkMode ? "#ffffff" : "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Voice commands:\n• Navigate to [destination]\n• Show nearby [POI]\n• Cancel navigation"
                        font.pixelSize: 14
                        color: settingsManager.darkMode ? "#999999" : "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                
                // Mock route indicator
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 100
                    color: settingsManager.darkMode ? Qt.rgba(0, 0, 0, 0.7) : Qt.rgba(255, 255, 255, 0.9)
                    visible: navigationActive
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        
                        Column {
                            spacing: 5
                            
                            Text {
                                text: "Distance"
                                font.pixelSize: 12
                                color: settingsManager.darkMode ? "#999999" : "#666666"
                            }
                            
                            Text {
                                text: "5.2 km"
                                font.pixelSize: 20
                                font.bold: true
                                color: settingsManager.darkMode ? "#ffffff" : "#333333"
                            }
                        }
                        
                        Rectangle {
                            width: 1
                            height: 60
                            color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
                        }
                        
                        Column {
                            spacing: 5
                            
                            Text {
                                text: "ETA"
                                font.pixelSize: 12
                                color: settingsManager.darkMode ? "#999999" : "#666666"
                            }
                            
                            Text {
                                text: "12 min"
                                font.pixelSize: 20
                                font.bold: true
                                color: settingsManager.darkMode ? "#ffffff" : "#333333"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Column {
                            spacing: 5
                            
                            Text {
                                text: "Next turn"
                                font.pixelSize: 12
                                color: settingsManager.darkMode ? "#999999" : "#666666"
                            }
                            
                            Row {
                                spacing: 5
                                
                                Text {
                                    text: "↰"
                                    font.pixelSize: 24
                                    color: "#007aff"
                                }
                                
                                Text {
                                    text: "500 m"
                                    font.pixelSize: 16
                                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Quick actions
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            Row {
                anchors.centerIn: parent
                spacing: 20
                
                QuickActionButton {
                    icon: "⛽"
                    label: "Gas Stations"
                    onClicked: searchField.text = "nearby gas stations"
                }
                
                QuickActionButton {
                    icon: "🍽️"
                    label: "Restaurants"
                    onClicked: searchField.text = "nearby restaurants"
                }
                
                QuickActionButton {
                    icon: "🏨"
                    label: "Hotels"
                    onClicked: searchField.text = "nearby hotels"
                }
                
                QuickActionButton {
                    icon: "🅿️"
                    label: "Parking"
                    onClicked: searchField.text = "nearby parking"
                }
            }
        }
    }
    
    // Quick Action Button Component
    component QuickActionButton: Button {
        property string icon: ""
        property string label: ""
        
        width: 80
        height: 50
        
        contentItem: Column {
            spacing: 2
            
            Text {
                text: icon
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: label
                font.pixelSize: 10
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        
        background: Rectangle {
            color: parent.hovered ? (settingsManager.darkMode ? "#3d3d3d" : "#f0f0f0") : "transparent"
            radius: 10
        }
    }
}

