import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * User Profiles Panel - Multi-user personalization
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
    
    property int currentUserId: 0
    property string currentUserName: "Guest"
    
    ListModel {
        id: usersModel
        
        ListElement {
            userId: 1
            name: "Ahmed"
            avatar: "👨"
            voiceId: "voice_001"
            preferredLanguage: "English"
            temperaturePreference: 22.0
            seatPosition: 3
            totalDrives: 156
        }
        
        ListElement {
            userId: 2
            name: "Sara"
            avatar: "👩"
            voiceId: "voice_002"
            preferredLanguage: "Arabic"
            temperaturePreference: 24.0
            seatPosition: 2
            totalDrives: 89
        }
        
        ListElement {
            userId: 3
            name: "Guest"
            avatar: "👤"
            voiceId: ""
            preferredLanguage: "English"
            temperaturePreference: 22.0
            seatPosition: 0
            totalDrives: 0
        }
    }
    
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
                    text: "👥 User Profiles"
                    font.pixelSize: 18
                    font.bold: true
                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "+ Add Profile"
                    onClicked: addProfileDialog.open()
                    
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
        }
        
        // User List
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            GridView {
                id: userGrid
                anchors.fill: parent
                anchors.margins: 20
                cellWidth: 180
                cellHeight: 220
                model: usersModel
                
                delegate: Rectangle {
                    width: 160
                    height: 200
                    color: currentUserId === model.userId ? "#007aff" : (settingsManager.darkMode ? "#2d2d2d" : "#ffffff")
                    radius: 15
                    border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
                    border.width: currentUserId === model.userId ? 0 : 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentUserId = model.userId
                            currentUserName = model.name
                            // Load user preferences
                            settingsManager.language = model.preferredLanguage
                        }
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        // Avatar
                        Text {
                            text: model.avatar
                            font.pixelSize: 48
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        // Name
                        Text {
                            text: model.name
                            font.pixelSize: 16
                            font.bold: true
                            color: currentUserId === model.userId ? "#ffffff" : (settingsManager.darkMode ? "#ffffff" : "#333333")
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        // Voice ID Badge
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: voiceIdText.width + 12
                            height: 24
                            color: currentUserId === model.userId ? Qt.lighter("#007aff", 1.2) : (settingsManager.darkMode ? "#3d3d3d" : "#e0e0e0")
                            radius: 12
                            visible: model.voiceId.length > 0
                            
                            Text {
                                id: voiceIdText
                                anchors.centerIn: parent
                                text: "🎤 Voice ID"
                                font.pixelSize: 10
                                color: currentUserId === model.userId ? "#ffffff" : (settingsManager.darkMode ? "#999999" : "#666666")
                            }
                        }
                        
                        // Stats
                        Column {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Row {
                                width: parent.width
                                spacing: 5
                                
                                Text {
                                    text: "🌐"
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: model.preferredLanguage
                                    font.pixelSize: 11
                                    color: currentUserId === model.userId ? "#ffffff" : (settingsManager.darkMode ? "#999999" : "#666666")
                                }
                            }
                            
                            Row {
                                width: parent.width
                                spacing: 5
                                
                                Text {
                                    text: "🚗"
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: model.totalDrives + " drives"
                                    font.pixelSize: 11
                                    color: currentUserId === model.userId ? "#ffffff" : (settingsManager.darkMode ? "#999999" : "#666666")
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                    
                    // Edit button
                    Button {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        width: 32
                        height: 32
                        text: "⚙️"
                        font.pixelSize: 16
                        visible: model.userId !== 3 // Don't show edit for Guest
                        
                        onClicked: {
                            editUserId = model.userId
                            editUserDialog.open()
                        }
                        
                        background: Rectangle {
                            color: parent.hovered ? Qt.rgba(0, 0, 0, 0.2) : "transparent"
                            radius: 16
                        }
                    }
                }
            }
        }
        
        // Current User Info
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 15
                
                Text {
                    text: "Current User:"
                    font.pixelSize: 14
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                }
                
                Text {
                    text: currentUserName
                    font.pixelSize: 18
                    font.bold: true
                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "🎤 Voice Login"
                    onClicked: {
                        // Trigger voice biometric authentication
                        audioEngine.startListening()
                    }
                    
                    background: Rectangle {
                        color: parent.hovered ? "#34b948" : "#34c759"
                        radius: 20
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Logout"
                    visible: currentUserId !== 3
                    onClicked: {
                        currentUserId = 3
                        currentUserName = "Guest"
                    }
                    
                    background: Rectangle {
                        color: parent.hovered ? "#e63300" : "#ff3b30"
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
        }
    }
    
    // Add Profile Dialog
    Dialog {
        id: addProfileDialog
        title: "Add New Profile"
        modal: true
        anchors.centerIn: parent
        width: 400
        
        contentItem: ColumnLayout {
            spacing: 15
            
            TextField {
                id: newUserName
                Layout.fillWidth: true
                placeholderText: "Name"
            }
            
            ComboBox {
                id: newUserAvatar
                Layout.fillWidth: true
                model: ["👨", "👩", "👦", "👧", "👴", "👵"]
            }
            
            ComboBox {
                id: newUserLanguage
                Layout.fillWidth: true
                model: settingsManager.getAvailableLanguages()
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignRight
                
                Button {
                    text: "Cancel"
                    onClicked: addProfileDialog.close()
                }
                
                Button {
                    text: "Add"
                    onClicked: {
                        usersModel.append({
                            userId: usersModel.count + 1,
                            name: newUserName.text,
                            avatar: newUserAvatar.currentText,
                            voiceId: "",
                            preferredLanguage: newUserLanguage.currentText,
                            temperaturePreference: 22.0,
                            seatPosition: 0,
                            totalDrives: 0
                        })
                        addProfileDialog.close()
                    }
                }
            }
        }
    }
    
    // Edit User Dialog
    property int editUserId: 0
    
    Dialog {
        id: editUserDialog
        title: "Edit Profile"
        modal: true
        anchors.centerIn: parent
        width: 400
        
        contentItem: ColumnLayout {
            spacing: 15
            
            Text {
                text: "Profile settings for user ID: " + editUserId
                font.pixelSize: 12
                color: settingsManager.darkMode ? "#999999" : "#666666"
            }
            
            Button {
                text: "🗑️ Delete Profile"
                Layout.fillWidth: true
                onClicked: {
                    for (var i = 0; i < usersModel.count; i++) {
                        if (usersModel.get(i).userId === editUserId) {
                            usersModel.remove(i)
                            break
                        }
                    }
                    editUserDialog.close()
                }
                
                background: Rectangle {
                    color: parent.hovered ? "#e63300" : "#ff3b30"
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
    }
}

