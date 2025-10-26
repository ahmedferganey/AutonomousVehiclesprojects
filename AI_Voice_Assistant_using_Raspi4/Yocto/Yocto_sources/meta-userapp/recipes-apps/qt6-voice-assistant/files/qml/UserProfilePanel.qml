import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * User Profile Panel - User management and personalization
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
    radius: 10
    
    property var currentUser: null
    property var users: [
        {id: 1, name: "Driver 1", avatar: "👤", preferences: {temp: 22, volume: 50}},
        {id: 2, name: "Driver 2", avatar: "👥", preferences: {temp: 20, volume: 40}},
        {id: 3, name: "Guest", avatar: "🚗", preferences: {temp: 21, volume: 45}}
    ]
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Header
        Text {
            text: "👤 User Profiles"
            font.pixelSize: 20
            font.bold: true
            color: settingsManager.darkMode ? "#ffffff" : "#333333"
            Layout.alignment: Qt.AlignHCenter
        }
        
        // Current user display
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
            radius: 10
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                Text {
                    text: currentUser ? currentUser.avatar : "👤"
                    font.pixelSize: 48
                }
                
                Column {
                    spacing: 5
                    Layout.fillWidth: true
                    
                    Text {
                        text: currentUser ? currentUser.name : "No user selected"
                        font.pixelSize: 18
                        font.bold: true
                        color: settingsManager.darkMode ? "#ffffff" : "#333333"
                    }
                    
                    Text {
                        text: currentUser ? "Profile loaded" : "Select or add a profile"
                        font.pixelSize: 12
                        color: settingsManager.darkMode ? "#999999" : "#666666"
                    }
                }
                
                Button {
                    text: "Edit"
                    visible: currentUser !== null
                    
                    background: Rectangle {
                        color: parent.hovered ? "#0066cc" : "#007aff"
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
        
        // User list
        Text {
            text: "Available Profiles"
            font.pixelSize: 16
            font.bold: true
            color: settingsManager.darkMode ? "#ffffff" : "#333333"
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            Column {
                width: parent.width
                spacing: 10
                
                Repeater {
                    model: users
                    
                    Rectangle {
                        width: parent.width
                        height: 80
                        color: currentUser && currentUser.id === modelData.id ? "#007aff" : (settingsManager.darkMode ? "#3d3d3d" : "#ffffff")
                        radius: 10
                        border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
                        border.width: 1
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentUser = modelData
                                // Load user preferences
                            }
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15
                            
                            Text {
                                text: modelData.avatar
                                font.pixelSize: 36
                            }
                            
                            Column {
                                spacing: 3
                                Layout.fillWidth: true
                                
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: currentUser && currentUser.id === modelData.id ? "#ffffff" : (settingsManager.darkMode ? "#ffffff" : "#333333")
                                }
                                
                                Text {
                                    text: "Temp: " + modelData.preferences.temp + "°C, Vol: " + modelData.preferences.volume + "%"
                                    font.pixelSize: 12
                                    color: currentUser && currentUser.id === modelData.id ? "#cccccc" : (settingsManager.darkMode ? "#999999" : "#666666")
                                }
                            }
                            
                            Text {
                                text: "✓"
                                font.pixelSize: 24
                                color: "#ffffff"
                                visible: currentUser && currentUser.id === modelData.id
                            }
                        }
                    }
                }
            }
        }
        
        // Add new user button
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            text: "+ Add New Profile"
            
            onClicked: {
                // Open add user dialog
            }
            
            background: Rectangle {
                color: parent.hovered ? "#f0f0f0" : "transparent"
                radius: 10
                border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
                border.width: 2
                border.style: BorderImage.Dashed
            }
            
            contentItem: Text {
                text: parent.text
                font.pixelSize: 14
                font.bold: true
                color: "#007aff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        // Voice biometrics info
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
            radius: 8
            
            Column {
                anchors.centerIn: parent
                spacing: 10
                
                Text {
                    text: "🎤 Voice Biometrics"
                    font.pixelSize: 14
                    font.bold: true
                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Automatically detect and switch profiles\nbased on voice recognition"
                    font.pixelSize: 12
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Switch {
                    text: "Enable Voice Recognition"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}

