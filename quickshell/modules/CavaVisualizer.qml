import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var colors
    implicitHeight: 30
    implicitWidth: 160
    radius: 12
    color: colors?.pillBg ?? "rgba(0, 0, 0, 0.70)"
    border.color: colors?.cyan ?? "#00E5FF"
    border.width: 1

    property var barHeights: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    // Read raw binary/ascii heights from CAVA fifo or stdout
    Process {
        id: cavaProc
        running: true
        command: ["bash", "-c", "cava -p <(echo '[general]\nbars = 12\n[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = 10\nbar_delimiter = 59') 2>/dev/null"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var values = data.trim().split(";")
                if (values.length >= 12) {
                    var newHeights = []
                    for (var i = 0; i < 12; i++) {
                        newHeights.push(Math.min(Math.max(parseInt(values[i]) || 0, 0), 10) / 10.0)
                    }
                    root.barHeights = newHeights
                }
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: 12

            Rectangle {
                required property int index
                implicitWidth: 6
                implicitHeight: Math.max(parent.parent.barHeights[index] * 18, 3)
                radius: 2
                color: root.colors?.cyan ?? "#00E5FF"

                Behavior on implicitHeight {
                    NumberAnimation { duration: 60 }
                }
            }
        }
    }
}