import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * Climate Control Panel - Voice-controlled HVAC system
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
    radius: 10
    border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
    border.width: 2
    
    property real targetTemperature: 22.0
    property real currentTemperature: 20.0
    property int fanSpeed: 2 // 0-5
    property bool acEnabled: false
    property bool heatingEnabled: false
    property bool autoMode: true
    property bool recirculation: false
    property bool defrostFront: false
    property bool defrostRear: false
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Header
        Text {
            text: "❄️ Climate Control"
            font.pixelSize: 20
            font.bold: true
            color: settingsManager.darkMode ? "#ffffff" : "#333333"
            Layout.alignment: Qt.AlignHCenter
        }
        
        // Temperature Control
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            spacing: 20
            
            // Decrease button
            Button {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                text: "−"
                font.pixelSize: 32
                
                onClicked: {
                    targetTemperature = Math.max(16, targetTemperature - 0.5)
                }
                
                background: Rectangle {
                    color: parent.pressed ? "#005cbf" : (parent.hovered ? "#0066cc" : "#007aff")
                    radius: 30
                }
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            // Temperature display
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: targetTemperature.toFixed(1) + "°C"
                        font.pixelSize: 48
                        font.bold: true
                        color: settingsManager.darkMode ? "#ffffff" : "#333333"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Target Temperature"
                        font.pixelSize: 14
                        color: settingsManager.darkMode ? "#999999" : "#666666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Current: " + currentTemperature.toFixed(1) + "°C"
                        font.pixelSize: 12
                        color: settingsManager.darkMode ? "#666666" : "#999999"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            // Increase button
            Button {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                text: "+"
                font.pixelSize: 32
                
                onClicked: {
                    targetTemperature = Math.min(30, targetTemperature + 0.5)
                }
                
                background: Rectangle {
                    color: parent.pressed ? "#cc2900" : (parent.hovered ? "#e63300" : "#ff3b30")
                    radius: 30
                }
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        // Fan Speed Control
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "Fan Speed: " + fanSpeed
                font.pixelSize: 16
                color: settingsManager.darkMode ? "#ffffff" : "#333333"
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                
                Repeater {
                    model: 6
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: index <= fanSpeed ? "#007aff" : (settingsManager.darkMode ? "#3d3d3d" : "#e0e0e0")
                        radius: 5
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: fanSpeed = index
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: index === 0 ? "OFF" : index.toString()
                            color: index <= fanSpeed ? "#ffffff" : (settingsManager.darkMode ? "#666666" : "#999999")
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
        }
        
        // Mode Buttons
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 10
            columnSpacing: 10
            
            ClimateButton {
                text: "AUTO"
                icon: "🔄"
                active: autoMode
                onClicked: autoMode = !autoMode
            }
            
            ClimateButton {
                text: "A/C"
                icon: "❄️"
                active: acEnabled
                onClicked: acEnabled = !acEnabled
            }
            
            ClimateButton {
                text: "HEAT"
                icon: "🔥"
                active: heatingEnabled
                onClicked: heatingEnabled = !heatingEnabled
            }
            
            ClimateButton {
                text: "RECIRC"
                icon: "🔁"
                active: recirculation
                onClicked: recirculation = !recirculation
            }
            
            ClimateButton {
                text: "DEFROST"
                icon: "🪟"
                active: defrostFront
                onClicked: defrostFront = !defrostFront
            }
            
            ClimateButton {
                text: "REAR"
                icon: "🔙"
                active: defrostRear
                onClicked: defrostRear = !defrostRear
            }
        }
        
        // Voice Command Hints
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
            radius: 8
            
            Column {
                anchors.centerIn: parent
                spacing: 5
                
                Text {
                    text: "🎤 Voice Commands"
                    font.pixelSize: 12
                    font.bold: true
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "\"Set temperature to 22\", \"Turn on AC\", \"Increase fan speed\""
                    font.pixelSize: 11
                    color: settingsManager.darkMode ? "#666666" : "#999999"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        Item { Layout.fillHeight: true }
    }
    
    // Climate Button Component
    component ClimateButton: Button {
        property string icon: ""
        property bool active: false
        
        Layout.fillWidth: true
        Layout.preferredHeight: 60
        
        contentItem: Column {
            spacing: 5
            
            Text {
                text: icon
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: parent.parent.text
                font.pixelSize: 11
                font.bold: true
                color: active ? "#ffffff" : (settingsManager.darkMode ? "#ffffff" : "#333333")
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        
        background: Rectangle {
            color: active ? "#007aff" : (parent.hovered ? (settingsManager.darkMode ? "#3d3d3d" : "#f0f0f0") : (settingsManager.darkMode ? "#2d2d2d" : "#ffffff"))
            radius: 10
            border.color: settingsManager.darkMode ? "#404040" : "#e0e0e0"
            border.width: active ? 0 : 1
        }
    }
}

