import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property var colors
    spacing: 6

    property string cpuUsage: "0%"
    property string gpuUsage: "0%"
    property string memUsage: "0%"

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }

    Process {
        id: statsProc
        command: [
            "bash", "-c",
            "cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}'); " +
            "ram=$(free -m | awk '/Mem:/ {print int($3/$2 * 100)}'); " +
            "gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo 0); " +
            "echo \"$cpu%|$gpu%|$ram%\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var stats = this.text.trim().split("|")
                if (stats.length === 3) {
                    root.cpuUsage = stats[0].trim() || "0%"
                    root.gpuUsage = stats[1].trim() || "0%"
                    root.memUsage = stats[2].trim() || "0%"
                }
            }
        }
    }

    // CPU Indicator
    Rectangle {
        implicitHeight: 28
        implicitWidth: cpuLayout.implicitWidth + 14
        radius: 8
        color: root.colors?.pillBg ?? "#a6060e18"
        border.color: root.colors?.pillBorder ?? "#4d00e5ff"
        border.width: 1

        RowLayout {
            id: cpuLayout
            anchors.centerIn: parent
            spacing: 4
            Text { text: "󰍛"; color: root.colors?.gold ?? "#FFE800"; font.pixelSize: 12 }
            Text { text: root.cpuUsage; color: root.colors?.text ?? "#cdd6f4"; font.pixelSize: 11; font.bold: true }
        }
    }

    // NVIDIA GPU Indicator
    Rectangle {
        implicitHeight: 28
        implicitWidth: gpuLayout.implicitWidth + 14
        radius: 8
        color: root.colors?.pillBg ?? "#a6060e18"
        border.color: root.colors?.pillBorder ?? "#4d00e5ff"
        border.width: 1

        RowLayout {
            id: gpuLayout
            anchors.centerIn: parent
            spacing: 4
            Text { text: "󰢮"; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 12 }
            Text { text: root.gpuUsage; color: root.colors?.text ?? "#cdd6f4"; font.pixelSize: 11; font.bold: true }
        }
    }

    // RAM Indicator
    Rectangle {
        implicitHeight: 28
        implicitWidth: memLayout.implicitWidth + 14
        radius: 8
        color: root.colors?.pillBg ?? "#a6060e18"
        border.color: root.colors?.pillBorder ?? "#4d00e5ff"
        border.width: 1

        RowLayout {
            id: memLayout
            anchors.centerIn: parent
            spacing: 4
            Text { text: "󰘚"; color: root.colors?.gold ?? "#FFE800"; font.pixelSize: 12 }
            Text { text: root.memUsage; color: root.colors?.text ?? "#cdd6f4"; font.pixelSize: 11; font.bold: true }
        }
    }
}