import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
    
    // Slide-in animation
    transform: Translate {
        id: slideTransform
        x: 0
    }
    
    states: [
        State {
            name: "hidden"
            when: !root.visible
            PropertyChanges { target: slideTransform; x: root.width }
        },
        State {
            name: "visible"
            when: root.visible
            PropertyChanges { target: slideTransform; x: 0 }
        }
    ]
    
    transitions: Transition {
        NumberAnimation { properties: "x"; duration: 300; easing.type: Easing.OutQuad }
    }
    
    // Shadow
    Rectangle {
        anchors.right: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 20
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "#80000000" }
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
                    text: "📜 History (" + transcriptionModel.count + ")"
                    font.pixelSize: 22
                    font.bold: true
                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                    Layout.fillWidth: true
                }
                
                Button {
                    text: "✕"
                    font.pixelSize: 20
                    flat: true
                    onClicked: root.visible = false
                    
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                }
            }
        }
        
        // Search bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 10
                
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "🔍 Search transcriptions..."
                    font.pixelSize: 14
                    
                    background: Rectangle {
                        color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
                        radius: 20
                        border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
                        border.width: 1
                    }
                }
            }
        }
        
        // Transcription list
        ListView {
            id: historyListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            
            model: transcriptionModel
            
            delegate: Rectangle {
                width: historyListView.width - 20
                height: contentColumn.height + 20
                x: 10
                color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
                radius: 10
                border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
                border.width: 1
                
                // Filter by search
                visible: searchField.text === "" || model.text.toLowerCase().includes(searchField.text.toLowerCase())
                
                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: model.timeString
                            font.pixelSize: 12
                            color: settingsManager.darkMode ? "#999999" : "#666666"
                            Layout.fillWidth: true
                        }
                        
                        Button {
                            text: "🗑️"
                            font.pixelSize: 16
                            flat: true
                            onClicked: transcriptionModel.removeTranscription(model.transcriptionId)
                            
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            
                            background: Rectangle {
                                color: parent.hovered ? "#ff3b30" : "transparent"
                                radius: 15
                            }
                        }
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: model.text
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                        color: settingsManager.darkMode ? "#ffffff" : "#333333"
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = settingsManager.darkMode ? "#3d3d3d" : "#f0f0f0"
                    onExited: parent.color = settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
                }
            }
            
            // Empty state
            Item {
                anchors.centerIn: parent
                visible: transcriptionModel.count === 0
                
                Column {
                    anchors.centerIn: parent
                    spacing: 15
                    
                    Text {
                        text: "📜"
                        font.pixelSize: 64
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "No transcriptions yet"
                        font.pixelSize: 18
                        color: settingsManager.darkMode ? "#999999" : "#666666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Start recording to build your history"
                        font.pixelSize: 14
                        color: settingsManager.darkMode ? "#666666" : "#999999"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
        
        // Footer buttons
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 15
                
                Button {
                    text: "Clear All"
                    enabled: transcriptionModel.count > 0
                    onClicked: confirmDialog.open()
                    
                    background: Rectangle {
                        color: parent.enabled ? (parent.hovered ? "#ff3b30" : Qt.lighter("#ff3b30", 1.2)) : "#666666"
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
                    text: "Export"
                    enabled: transcriptionModel.count > 0
                    onClicked: fileDialog.open()
                    
                    background: Rectangle {
                        color: parent.enabled ? (parent.hovered ? Qt.lighter("#007aff", 1.2) : "#007aff") : "#666666"
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
    
    // Confirmation dialog
    Dialog {
        id: confirmDialog
        title: "Clear History"
        modal: true
        anchors.centerIn: parent
        
        contentItem: ColumnLayout {
            spacing: 20
            
            Text {
                text: "Are you sure you want to delete all " + transcriptionModel.count + " transcriptions?\nThis action cannot be undone."
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 300
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10
                
                Button {
                    text: "Cancel"
                    onClicked: confirmDialog.close()
                    
                    background: Rectangle {
                        color: parent.hovered ? "#666666" : "#999999"
                        radius: 15
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Delete All"
                    onClicked: {
                        transcriptionModel.clear()
                        confirmDialog.close()
                    }
                    
                    background: Rectangle {
                        color: parent.hovered ? "#ff3b30" : Qt.lighter("#ff3b30", 1.2)
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
        
        background: Rectangle {
            color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
            radius: 10
        }
    }
    
    // File dialog for export
    FileDialog {
        id: fileDialog
        title: "Export Transcriptions"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "txt"
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        onAccepted: {
            transcriptionModel.exportToFile(selectedFile)
        }
    }
    
    // Export notification
    Connections {
        target: transcriptionModel
        function onExportCompleted(success, message) {
            exportNotification.text = message
            exportNotification.color = success ? "#34c759" : "#ff3b30"
            exportNotification.visible = true
            exportNotificationTimer.start()
        }
    }
    
    Rectangle {
        id: exportNotification
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        width: 250
        height: 50
        radius: 25
        visible: false
        
        property alias text: notificationText.text
        
        Text {
            id: notificationText
            anchors.centerIn: parent
            color: "#ffffff"
            font.pixelSize: 14
            font.bold: true
        }
        
        Timer {
            id: exportNotificationTimer
            interval: 3000
            onTriggered: exportNotification.visible = false
        }
    }
}

