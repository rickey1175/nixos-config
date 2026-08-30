import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    property var colors
    property bool isOpen: false

    anchors {
        top: true
    }
    margins {
        top: 46
    }
    
    implicitWidth: 320
    implicitHeight: 280
    visible: isOpen
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: "#d907111c"
        border.color: root.colors?.gold ?? "#FFE800"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Header: Month & Year
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: Qt.formatDate(new Date(), "MMMM yyyy").toUpperCase()
                    color: root.colors?.gold ?? "#FFE800"
                    font.pixelSize: 13
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: Qt.formatDate(new Date(), "dddd")
                    color: root.colors?.cyan ?? "#00E5FF"
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#3300e5ff"
            }

            // Day headers
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: root.colors?.inactiveText ?? "#6c7086"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            // Days Grid
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 4

                Repeater {
                    model: 35
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        property int currentDayNum: new Date().getDate()
                        property int cellDay: index - 2 // approximate grid offset for active month
                        
                        color: (cellDay === currentDayNum) ? (root.colors?.gold ?? "#FFE800") : "transparent"
                        border.color: (cellDay === currentDayNum) ? "transparent" : ((cellDay > 0 && cellDay <= 31) ? "#1a00e5ff" : "transparent")
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: (cellDay > 0 && cellDay <= 31) ? cellDay : ""
                            color: (cellDay === currentDayNum) ? "#07111c" : ((cellDay > 0 && cellDay <= 31) ? (root.colors?.text ?? "#cdd6f4") : "transparent")
                            font.pixelSize: 10
                            font.bold: cellDay === currentDayNum
                        }
                    }
                }
            }
        }
    }
}