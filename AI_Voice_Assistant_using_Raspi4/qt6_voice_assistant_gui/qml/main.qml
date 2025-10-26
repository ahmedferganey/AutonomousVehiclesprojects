import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    title: "AI Voice Assistant"
    
    // Responsive sizing
    width: Screen.width > 1280 ? 1280 : (Screen.width > 800 ? 800 : 480)
    height: Screen.height > 720 ? 720 : (Screen.height > 480 ? 480 : 320)
    
    // Set minimum size
    minimumWidth: 480
    minimumHeight: 320
    
    color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
    
    MainWindow {
        anchors.fill: parent
    }
}

