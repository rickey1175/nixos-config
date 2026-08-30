import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    property var colors
    property bool isOpen: false
    property var notifications: []

    anchors {
        top: true
        right: true
    }
    margins {
        top: 48
        right: 18
    }

    implicitWidth: 360
    implicitHeight: Math.min(notifCol.implicitHeight + 30, 480)
    visible: isOpen
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Process { id: clearProc; command: ["bash", "-c", "dunstctl close-all 2>/dev/null || makoctl dismiss -a 2>/dev/null || true"] }

    // Outer Glass Panel with Cyan Glow
    Rectangle {
        anchors.fill: parent
        radius: 14
        color: "#d907111c"
        border.color: root.colors?.cyan ?? "#00E5FF"
        border.width: 1

        ColumnLayout {
            id: notifCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Header: Title + Clear All Button
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰂚  NOTIFICATIONS"
                    color: root.colors?.cyan ?? "#00E5FF"
                    font.pixelSize: 12
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: 68
                    implicitHeight: 22
                    radius: 6
                    color: "#1affe800"
                    border.color: root.colors?.gold ?? "#FFE800"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Clear All"
                        color: root.colors?.gold ?? "#FFE800"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            clearProc.running = false
                            clearProc.running = true
                            root.notifications = []
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#3300e5ff"
            }

            // Notification List or Empty State
            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(contentHeight, 80)
                clip: true
                spacing: 6
                model: root.notifications.length > 0 ? root.notifications : ["No recent notifications"]

                delegate: Rectangle {
                    required property var modelData
                    width: parent ? parent.width : 330
                    implicitHeight: 46
                    radius: 8
                    color: "#a6060e18"
                    border.color: root.colors?.pillBorder ?? "#4d00e5ff"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: "󱅫"
                            color: root.colors?.gold ?? "#FFE800"
                            font.pixelSize: 14
                        }

                        Text {
                            text: modelData
                            color: root.colors?.text ?? "#cdd6f4"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}