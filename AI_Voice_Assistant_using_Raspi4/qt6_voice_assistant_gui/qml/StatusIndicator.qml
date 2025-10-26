import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 200
    height: 40
    
    property string statusText: "Ready"
    property color statusColor: "#34c759"
    
    RowLayout {
        anchors.centerIn: parent
        spacing: 10
        
        // Status LED
        Rectangle {
            width: 20
            height: 20
            radius: 10
            color: statusColor
            
            // Pulsing animation
            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                NumberAnimation { to: 0.5; duration: 1000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
            }
            
            // Glow effect
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 1.5
                height: parent.height * 1.5
                radius: width / 2
                color: "transparent"
                border.color: statusColor
                border.width: 2
                opacity: 0.3
            }
        }
        
        // Status text
        Text {
            text: statusText
            font.pixelSize: 18
            font.bold: true
            color: settingsManager.darkMode ? "#ffffff" : "#333333"
            
            Layout.alignment: Qt.AlignVCenter
        }
    }
}

