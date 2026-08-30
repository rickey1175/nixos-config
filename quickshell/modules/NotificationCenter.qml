import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var colors
    property int notifCount: 0

    implicitHeight: 28
    implicitWidth: notifLayout.implicitWidth + 14
    radius: 10
    color: (root.notifCount > 0) ? "#2600e5ff" : (root.colors?.pillBg ?? "#a6060e18")
    border.color: (root.notifCount > 0) ? (root.colors?.cyan ?? "#00E5FF") : (root.colors?.pillBorder ?? "#4d00e5ff")
    border.width: 1

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: notifCountProc.running = true
    }

    Process {
        id: notifCountProc
        command: ["bash", "-c", "swaync-client -c 2>/dev/null || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                var c = parseInt(this.text.trim())
                root.notifCount = isNaN(c) ? 0 : c
            }
        }
    }

    Process {
        id: toggleProc
        command: ["bash", "-c", "swaync-client -t -sw 2>/dev/null || true"]
    }

    RowLayout {
        id: notifLayout
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: (root.notifCount > 0) ? "󱅫" : "󰂚"
            color: (root.notifCount > 0) ? (root.colors?.cyan ?? "#00E5FF") : (root.colors?.inactiveText ?? "#6c7086")
            font.pixelSize: 12
        }

        Text {
            text: root.notifCount.toString()
            color: (root.notifCount > 0) ? (root.colors?.cyan ?? "#00E5FF") : (root.colors?.text ?? "#cdd6f4")
            font.pixelSize: 11
            font.bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggleProc.running = false
            toggleProc.running = true
        }
    }
}