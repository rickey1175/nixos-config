import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    property var colors
    property bool isOpen: false
    signal requestLock()

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    visible: isOpen
    color: "#80000000" // Backdrop dim

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // Dismiss on background click or Escape
    MouseArea {
        anchors.fill: parent
        onClicked: root.isOpen = false
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.isOpen = false
    }

    Process { id: pwrProc }

    function runPwr(cmd) {
        root.isOpen = false
        pwrProc.command = ["bash", "-c", cmd]
        pwrProc.running = false
        pwrProc.running = true
    }

    // Modal Card
    Rectangle {
        anchors.centerIn: parent
        width: 420
        height: 130
        radius: 16
        color: "#d907111c"
        border.color: root.colors?.red ?? "#FF2A2A"
        border.width: 1

        MouseArea {
            anchors.fill: parent // Prevent dismissal when clicking inside the card
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 20

            // Lock Action (Triggers native Quickshell LockScreen overlay)
            Rectangle {
                implicitWidth: 70
                implicitHeight: 70
                radius: 12
                color: "#1a00e5ff"
                border.color: root.colors?.cyan ?? "#00E5FF"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: ""; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Lock"; color: "#cdd6f4"; font.pixelSize: 11; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.isOpen = false
                        root.requestLock()
                    }
                }
            }

            // Logout Action
            Rectangle {
                implicitWidth: 70
                implicitHeight: 70
                radius: 12
                color: "#1affe800"
                border.color: root.colors?.gold ?? "#FFE800"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "󰍃"; color: root.colors?.gold ?? "#FFE800"; font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Exit"; color: "#cdd6f4"; font.pixelSize: 11; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runPwr("hyprctl dispatch exit")
                }
            }

            // Reboot Action
            Rectangle {
                implicitWidth: 70
                implicitHeight: 70
                radius: 12
                color: "#1a00e5ff"
                border.color: root.colors?.cyan ?? "#00E5FF"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "󰜉"; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Reboot"; color: "#cdd6f4"; font.pixelSize: 11; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runPwr("systemctl reboot")
                }
            }

            // Shutdown Action
            Rectangle {
                implicitWidth: 70
                implicitHeight: 70
                radius: 12
                color: "#26ff2a2a"
                border.color: root.colors?.red ?? "#FF2A2A"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "⏻"; color: root.colors?.red ?? "#FF2A2A"; font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Power Off"; color: "#cdd6f4"; font.pixelSize: 11; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runPwr("systemctl poweroff")
                }
            }
        }
    }
}