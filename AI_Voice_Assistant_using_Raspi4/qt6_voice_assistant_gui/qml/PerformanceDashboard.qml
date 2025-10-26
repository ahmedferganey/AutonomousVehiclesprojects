import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15

/**
 * Performance Dashboard - System analytics and monitoring
 */
Rectangle {
    id: root
    
    color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
    
    property real cpuUsage: 45.5
    property real memoryUsage: 62.3
    property real audioLatency: 150
    property real transcriptionAccuracy: 87.5
    property int transcriptionCount: 42
    
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
                anchors.margins: 15
                
                Text {
                    text: "📊 Performance Dashboard"
                    font.pixelSize: 20
                    font.bold: true
                    color: settingsManager.darkMode ? "#ffffff" : "#333333"
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Export Report"
                    
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
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 15
                
                // System Metrics Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.margins: 15
                    columns: 2
                    rowSpacing: 15
                    columnSpacing: 15
                    
                    MetricCard {
                        Layout.fillWidth: true
                        title: "CPU Usage"
                        value: cpuUsage.toFixed(1) + "%"
                        icon: "💻"
                        progress: cpuUsage / 100
                        warningLevel: 0.8
                    }
                    
                    MetricCard {
                        Layout.fillWidth: true
                        title: "Memory Usage"
                        value: memoryUsage.toFixed(1) + "%"
                        icon: "🧠"
                        progress: memoryUsage / 100
                        warningLevel: 0.85
                    }
                    
                    MetricCard {
                        Layout.fillWidth: true
                        title: "Audio Latency"
                        value: audioLatency.toFixed(0) + " ms"
                        icon: "⏱️"
                        progress: audioLatency / 1000
                        warningLevel: 0.5
                        inverted: true
                    }
                    
                    MetricCard {
                        Layout.fillWidth: true
                        title: "Transcription Accuracy"
                        value: transcriptionAccuracy.toFixed(1) + "%"
                        icon: "🎯"
                        progress: transcriptionAccuracy / 100
                        warningLevel: 0.7
                    }
                }
                
                // Charts section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    Layout.margins: 15
                    color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
                    radius: 10
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: "📈 Performance Trends"
                            font.pixelSize: 16
                            font.bold: true
                            color: settingsManager.darkMode ? "#ffffff" : "#333333"
                        }
                        
                        // Placeholder for chart
                        Rectangle {
                            width: parent.width
                            height: parent.height - 40
                            color: settingsManager.darkMode ? "#1a1a1a" : "#f5f5f5"
                            radius: 5
                            
                            Text {
                                anchors.centerIn: parent
                                text: "CPU & Memory Usage Over Time\n(QtCharts integration)"
                                font.pixelSize: 14
                                color: settingsManager.darkMode ? "#666666" : "#999999"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
                
                // Statistics
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    Layout.margins: 15
                    color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
                    radius: 10
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: "📊 Session Statistics"
                            font.pixelSize: 16
                            font.bold: true
                            color: settingsManager.darkMode ? "#ffffff" : "#333333"
                        }
                        
                        GridLayout {
                            width: parent.width
                            columns: 3
                            rowSpacing: 10
                            columnSpacing: 20
                            
                            StatItem {
                                label: "Transcriptions"
                                value: transcriptionCount.toString()
                            }
                            
                            StatItem {
                                label: "Uptime"
                                value: "2h 34m"
                            }
                            
                            StatItem {
                                label: "Errors"
                                value: "3"
                            }
                            
                            StatItem {
                                label: "Avg Response"
                                value: "1.8s"
                            }
                            
                            StatItem {
                                label: "Success Rate"
                                value: "94%"
                            }
                            
                            StatItem {
                                label: "Commands"
                                value: "127"
                            }
                        }
                    }
                }
                
                // Performance Targets
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    Layout.margins: 15
                    color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
                    radius: 10
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: "🎯 Performance Targets"
                            font.pixelSize: 16
                            font.bold: true
                            color: settingsManager.darkMode ? "#ffffff" : "#333333"
                        }
                        
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            TargetRow {
                                label: "Speech Recognition Latency"
                                current: "~2s"
                                target: "<1s"
                                achieved: false
                            }
                            
                            TargetRow {
                                label: "Memory Usage (Idle)"
                                current: "~800MB"
                                target: "<600MB"
                                achieved: false
                            }
                            
                            TargetRow {
                                label: "Transcription Accuracy"
                                current: "~85%"
                                target: ">95%"
                                achieved: false
                            }
                            
                            TargetRow {
                                label: "Code Coverage"
                                current: "~20%"
                                target: ">80%"
                                achieved: false
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Metric Card Component
    component MetricCard: Rectangle {
        property string title: ""
        property string value: ""
        property string icon: ""
        property real progress: 0.0
        property real warningLevel: 0.8
        property bool inverted: false
        
        height: 120
        color: settingsManager.darkMode ? "#2d2d2d" : "#ffffff"
        radius: 10
        
        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            
            Row {
                spacing: 10
                
                Text {
                    text: icon
                    font.pixelSize: 24
                }
                
                Text {
                    text: title
                    font.pixelSize: 14
                    color: settingsManager.darkMode ? "#999999" : "#666666"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            Text {
                text: value
                font.pixelSize: 28
                font.bold: true
                color: {
                    var isWarning = inverted ? progress < warningLevel : progress > warningLevel;
                    return isWarning ? "#ff9500" : (settingsManager.darkMode ? "#ffffff" : "#333333");
                }
            }
            
            ProgressBar {
                width: parent.width
                from: 0
                to: 1.0
                value: progress
                
                background: Rectangle {
                    implicitHeight: 6
                    color: settingsManager.darkMode ? "#3d3d3d" : "#e0e0e0"
                    radius: 3
                }
                
                contentItem: Item {
                    implicitHeight: 6
                    
                    Rectangle {
                        width: parent.parent.visualPosition * parent.width
                        height: parent.height
                        radius: 3
                        color: {
                            var isWarning = inverted ? progress < warningLevel : progress > warningLevel;
                            return isWarning ? "#ff9500" : "#34c759";
                        }
                    }
                }
            }
        }
    }
    
    // Stat Item Component
    component StatItem: Column {
        property string label: ""
        property string value: ""
        
        spacing: 5
        
        Text {
            text: label
            font.pixelSize: 12
            color: settingsManager.darkMode ? "#999999" : "#666666"
        }
        
        Text {
            text: value
            font.pixelSize: 18
            font.bold: true
            color: settingsManager.darkMode ? "#ffffff" : "#333333"
        }
    }
    
    // Target Row Component
    component TargetRow: RowLayout {
        property string label: ""
        property string current: ""
        property string target: ""
        property bool achieved: false
        
        width: parent.width
        spacing: 10
        
        Text {
            text: label
            font.pixelSize: 12
            color: settingsManager.darkMode ? "#ffffff" : "#333333"
            Layout.fillWidth: true
        }
        
        Text {
            text: current
            font.pixelSize: 12
            color: settingsManager.darkMode ? "#999999" : "#666666"
        }
        
        Text {
            text: "→"
            font.pixelSize: 12
            color: settingsManager.darkMode ? "#666666" : "#999999"
        }
        
        Text {
            text: target
            font.pixelSize: 12
            font.bold: true
            color: achieved ? "#34c759" : "#ff9500"
        }
        
        Text {
            text: achieved ? "✓" : "○"
            font.pixelSize: 14
            color: achieved ? "#34c759" : "#ff9500"
        }
    }
}
