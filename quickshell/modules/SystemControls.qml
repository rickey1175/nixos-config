import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property var colors
    signal requestPowerMenu()
    spacing: 6

    property string volume: "50%"

    Process { id: spawnProc }

    function launchGui(app) {
        spawnProc.command = ["bash", "-c", "nohup " + app + " >/dev/null 2>&1 &"]
        spawnProc.running = false
        spawnProc.running = true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volProc.running = true
    }

    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)\"%\"}'"]
        stdout: StdioCollector {
            onStreamFinished: root.volume = this.text.trim() || "50%"
        }
    }

    // Audio Pill
    Rectangle {
        implicitHeight: 28
        implicitWidth: volLayout.implicitWidth + 14
        radius: 10
        color: root.colors?.pillBg ?? "#a6060e18"
        border.color: root.colors?.pillBorder ?? "#4d00e5ff"
        border.width: 1

        RowLayout {
            id: volLayout
            anchors.centerIn: parent
            spacing: 4
            Text { text: "󰕾"; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 11 }
            Text { text: root.volume; color: root.colors?.text ?? "#cdd6f4"; font.pixelSize: 11; font.bold: true }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.launchGui("pavucontrol")
        }
    }

    // Bluetooth Pill
    Rectangle {
        implicitHeight: 28
        implicitWidth: 28
        radius: 10
        color: root.colors?.pillBg ?? "#a6060e18"
        border.color: root.colors?.pillBorder ?? "#4d00e5ff"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "󰂯"
            color: root.colors?.cyan ?? "#00E5FF"
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.launchGui("blueman-manager")
        }
    }

    // Host Badge Pill
    Rectangle {
        implicitHeight: 28
        implicitWidth: hostLayout.implicitWidth + 14
        radius: 10
        color: root.colors?.pillBg ?? "#a6060e18"
        border.color: root.colors?.pillBorder ?? "#4d00e5ff"
        border.width: 1

        RowLayout {
            id: hostLayout
            anchors.centerIn: parent
            spacing: 4
            Text { text: "󱄅"; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 12 }
            Text { text: "NixOS"; color: root.colors?.text ?? "#cdd6f4"; font.pixelSize: 11; font.bold: true }
        }
    }

    // Notification Island
    NotificationCenter {
        colors: root.colors
    }

    // Native Power Button Pill
    Rectangle {
        implicitHeight: 28
        implicitWidth: 28
        radius: 10
        color: "#d9230a0f"
        border.color: root.colors?.red ?? "#FF2A2A"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "⏻"
            color: root.colors?.red ?? "#FF2A2A"
            font.pixelSize: 12
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.requestPowerMenu()
        }
    }
}