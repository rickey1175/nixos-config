import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var colors
    implicitHeight: 30
    implicitWidth: Math.max(taskLayout.implicitWidth + 12, 10)
    visible: root.openWindows.length > 0
    radius: 12
    color: colors?.pillBg ?? "rgba(0, 0, 0, 0.70)"
    border.color: colors?.pillBorder ?? "rgba(0, 180, 216, 0.40)"
    border.width: 1

    property var openWindows: []

    // Helper process to focus windows cleanly
    Process {
        id: focusProc
    }

    function focusWindow(addr) {
        focusProc.command = ["hyprctl", "dispatch", "focuswindow", "address:" + addr]
        focusProc.running = false
        focusProc.running = true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clientProc.running = true
    }

    Process {
        id: clientProc
        command: ["bash", "-c", "hyprctl clients -j 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var clients = JSON.parse(this.text)
                    var activeWs = Hyprland.focusedWorkspace?.id ?? 1
                    var filtered = clients.filter(c => c.workspace.id === activeWs)
                    root.openWindows = filtered.slice(0, 6)
                } catch (e) {
                    root.openWindows = []
                }
            }
        }
    }

    RowLayout {
        id: taskLayout
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.openWindows

            Rectangle {
                id: windowPill
                required property var modelData
                readonly property bool isFocused: modelData.address === (Hyprland.activeWindow?.address ?? "")

                implicitWidth: 24
                implicitHeight: 22
                radius: 6
                color: isFocused ? "rgba(0, 229, 255, 0.2)" : "transparent"

                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 13
                    text: {
                        var cls = (windowPill.modelData.initialClass || windowPill.modelData.class || "").toLowerCase()
                        if (cls.includes("brave")) return "🦁"
                        if (cls.includes("spotify")) return ""
                        if (cls.includes("code") || cls.includes("vscode")) return "󰨞"
                        if (cls.includes("kitty") || cls.includes("terminal")) return ""
                        if (cls.includes("dolphin")) return ""
                        if (cls.includes("discord")) return "󰙯"
                        if (cls.includes("obs")) return "󰑋"
                        return ""
                    }
                    color: windowPill.isFocused ? (root.colors?.gold ?? "#FFE800") : (root.colors?.text ?? "#cdd6f4")
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.focusWindow(windowPill.modelData.address)
                }
            }
        }
    }
}