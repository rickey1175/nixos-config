import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property var colors
    signal toggleCalendar()
    signal toggleNotifPanel()
    spacing: 6

    property string fullDateStr: Qt.formatDateTime(new Date(), "ddd, MMM d, yyyy")
    property string timeStr: Qt.formatTime(new Date(), "hh:mm AP")
    property int notifCount: 0

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.timeStr = Qt.formatTime(new Date(), "hh:mm AP")
            root.fullDateStr = Qt.formatDateTime(new Date(), "ddd, MMM d, yyyy")
            notifProc.running = true
        }
    }

    Process {
        id: notifProc
        command: ["bash", "-c", "dunstctl count waiting 2>/dev/null || makoctl list 2>/dev/null | grep -c '\"id\":' || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                var c = parseInt(this.text.trim())
                root.notifCount = isNaN(c) ? 0 : c
            }
        }
    }

    // 1. Notification Pill Button (Matching translucent island)
    Rectangle {
        implicitHeight: 28
        implicitWidth: notifContent.implicitWidth + 16
        radius: 10
        color: root.colors?.pillBg ?? "#a6060e18"
        border.color: (root.notifCount > 0) ? (root.colors?.gold ?? "#FFE800") : (root.colors?.pillBorder ?? "#4d00e5ff")
        border.width: 1

        RowLayout {
            id: notifContent
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: root.notifCount > 0 ? "󱅫" : "󰂚"
                color: root.notifCount > 0 ? (root.colors?.gold ?? "#FFE800") : (root.colors?.cyan ?? "#00E5FF")
                font.pixelSize: 12
            }

            Text {
                text: root.notifCount.toString()
                color: root.notifCount > 0 ? (root.colors?.gold ?? "#FFE800") : (root.colors?.text ?? "#cdd6f4")
                font.pixelSize: 11
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleNotifPanel()
        }
    }

    // 2. Active Track Pill
    MediaCalendar {
        colors: root.colors
    }

    // 3. Audio Visualizer Wave
    CavaVisualizer {
        colors: root.colors
    }

    // 4. Central Clock + Full Date Pill
    Rectangle {
        implicitHeight: 28
        implicitWidth: dateTimeLayout.implicitWidth + 16
        radius: 10
        color: root.colors?.pillBg ?? "#a6060e18"
        border.color: root.colors?.gold ?? "#FFE800"
        border.width: 1

        RowLayout {
            id: dateTimeLayout
            anchors.centerIn: parent
            spacing: 8

            RowLayout {
                spacing: 4
                Text { text: "󰸗"; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 11 }
                Text { text: root.fullDateStr; color: root.colors?.text ?? "#cdd6f4"; font.pixelSize: 11; font.bold: true }
            }

            Rectangle {
                width: 1
                height: 12
                color: "#4d00e5ff"
            }

            Text {
                text: root.timeStr
                color: root.colors?.gold ?? "#FFE800"
                font.pixelSize: 11
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleCalendar()
        }
    }
}