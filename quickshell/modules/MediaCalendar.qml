import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var colors
    implicitHeight: 28
    implicitWidth: Math.min(mediaLayout.implicitWidth + 24, 280)
    radius: 10
    color: colors?.pillBg ?? "#a6060e18"
    border.color: (root.mediaStatus === "Playing") ? (colors?.gold ?? "#FFE800") : (colors?.pillBorder ?? "#4d00e5ff")
    border.width: 1

    property string mediaTitle: "UNSC Standby"
    property string mediaStatus: "Stopped"

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: mediaProc.running = true
    }

    Process {
        id: mediaProc
        command: ["bash", "-c", "status=$(playerctl status 2>/dev/null || echo 'Stopped'); title=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null || echo ''); echo \"$status|$title\""]
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text.trim().split("|")
                if (raw.length >= 2 && raw[1].trim().length > 0) {
                    root.mediaStatus = raw[0].trim()
                    root.mediaTitle = raw[1].trim()
                } else {
                    root.mediaStatus = "Stopped"
                    root.mediaTitle = "No Media"
                }
            }
        }
    }

    Process {
        id: playPauseProc
        command: ["playerctl", "play-pause"]
    }

    RowLayout {
        id: mediaLayout
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: (root.mediaStatus === "Playing") ? "󰎈" : "󰏤"
            color: root.colors?.gold ?? "#FFE800"
            font.pixelSize: 12
        }

        Text {
            text: root.mediaTitle
            color: root.colors?.gold ?? "#FFE800"
            font.pixelSize: 11
            font.bold: true
            elide: Text.ElideRight
            Layout.maximumWidth: 230
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            playPauseProc.running = false
            playPauseProc.running = true
        }
    }
}