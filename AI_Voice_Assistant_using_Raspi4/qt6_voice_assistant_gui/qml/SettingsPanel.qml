import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
                    text: "⚙️ Settings"
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
        
        // Settings content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 20
                
                // Dark Mode
                SettingItem {
                    Layout.fillWidth: true
                    title: "Dark Mode"
                    description: "Use dark color scheme"
                    
                    Switch {
                        checked: settingsManager.darkMode
                        onToggled: settingsManager.darkMode = checked
                    }
                }
                
                // Language
                SettingItem {
                    Layout.fillWidth: true
                    title: "Language"
                    description: "Recognition language"
                    
                    ComboBox {
                        width: 150
                        model: settingsManager.getAvailableLanguages()
                        currentIndex: model.indexOf(settingsManager.language)
                        onActivated: settingsManager.language = currentText
                    }
                }
                
                // Whisper Model
                SettingItem {
                    Layout.fillWidth: true
                    title: "Whisper Model"
                    description: "AI model size (larger = more accurate)"
                    
                    ComboBox {
                        width: 150
                        model: settingsManager.getAvailableModels()
                        currentIndex: model.indexOf(settingsManager.whisperModel)
                        onActivated: settingsManager.whisperModel = currentText
                    }
                }
                
                // Audio Device
                SettingItem {
                    Layout.fillWidth: true
                    title: "Audio Device"
                    description: "Input microphone"
                    
                    ComboBox {
                        width: 200
                        model: settingsManager.getAvailableAudioDevices()
                        currentIndex: settingsManager.audioDevice
                        onActivated: settingsManager.audioDevice = currentIndex
                    }
                }
                
                // Silence Threshold
                SettingItem {
                    Layout.fillWidth: true
                    title: "Silence Threshold"
                    description: "Audio level detection threshold: " + settingsManager.silenceThreshold.toFixed(3)
                    
                    Slider {
                        width: 200
                        from: 0.001
                        to: 0.1
                        value: settingsManager.silenceThreshold
                        onMoved: settingsManager.silenceThreshold = value
                    }
                }
                
                // Max Recording Time
                SettingItem {
                    Layout.fillWidth: true
                    title: "Max Recording Time"
                    description: "Maximum recording duration: " + settingsManager.maxRecordingSeconds + "s"
                    
                    Slider {
                        width: 200
                        from: 10
                        to: 300
                        stepSize: 10
                        value: settingsManager.maxRecordingSeconds
                        onMoved: settingsManager.maxRecordingSeconds = value
                    }
                }
                
                Item { Layout.preferredHeight: 20 }
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
                    text: "Reset Defaults"
                    onClicked: settingsManager.resetToDefaults()
                    
                    background: Rectangle {
                        color: parent.hovered ? "#ff3b30" : Qt.lighter("#ff3b30", 1.2)
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
                    text: "Save Settings"
                    onClicked: {
                        settingsManager.saveSettings()
                        saveNotification.visible = true
                        saveNotificationTimer.start()
                    }
                    
                    background: Rectangle {
                        color: parent.hovered ? Qt.lighter("#007aff", 1.2) : "#007aff"
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
    
    // Save notification
    Rectangle {
        id: saveNotification
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        width: 200
        height: 50
        radius: 25
        color: "#34c759"
        visible: false
        
        Text {
            anchors.centerIn: parent
            text: "✓ Settings Saved"
            color: "#ffffff"
            font.pixelSize: 16
            font.bold: true
        }
        
        Timer {
            id: saveNotificationTimer
            interval: 2000
            onTriggered: saveNotification.visible = false
        }
    }
    
    // Settings item component
    component SettingItem: Rectangle {
        property alias title: titleText.text
        property alias description: descText.text
        default property alias content: contentContainer.children
        
        height: 80
        color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 15
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    id: titleText
                    font.pixelSize: 16
                    font.bold: true
                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                }
                
                Text {
                    id: descText
                    font.pixelSize: 13
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                }
            }
            
            Item {
                id: contentContainer
                Layout.preferredWidth: childrenRect.width
                Layout.preferredHeight: childrenRect.height
            }
        }
    }
}

