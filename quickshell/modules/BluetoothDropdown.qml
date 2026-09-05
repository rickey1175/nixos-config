import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    property var colors
    property bool isOpen: false
    property bool btPowered: false
    property bool isScanning: false
    property var pairedList: []
    property var availableList: []

    anchors {
        top: true
        right: true
    }
    margins {
        top: 46
        right: 80
    }

    implicitWidth: 340
    implicitHeight: 420
    visible: isOpen
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Query Power, Paired Devices, and Discovered Devices
    Process {
        id: scanProc
        command: [
            "bash", "-c",
            "p=$(bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo 'yes' || echo 'no'); " +
            "echo \"POWER|$p\"; " +
            "bluetoothctl devices Paired 2>/dev/null | while read -r _ mac name; do " +
            "  c=$(bluetoothctl info \"$mac\" 2>/dev/null | grep -q 'Connected: yes' && echo 'yes' || echo 'no'); " +
            "  echo \"PAIRED|$mac|$name|$c\"; " +
            "done; " +
            "bluetoothctl devices 2>/dev/null | while read -r _ mac name; do " +
            "  paired=$(bluetoothctl info \"$mac\" 2>/dev/null | grep -q 'Paired: yes' && echo 'yes' || echo 'no'); " +
            "  if [ \"$paired\" != \"yes\" ] && [ -n \"$name\" ]; then " +
            "    echo \"AVAIL|$mac|$name\"; " +
            "  fi; " +
            "done"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                var paired = []
                var avail = []
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("|")
                    if (parts[0] === "POWER") {
                        root.btPowered = (parts[1] === "yes")
                    } else if (parts[0] === "PAIRED" && parts.length >= 4) {
                        paired.push({
                            mac: parts[1],
                            name: parts[2],
                            connected: (parts[3] === "yes")
                        })
                    } else if (parts[0] === "AVAIL" && parts.length >= 3) {
                        avail.push({
                            mac: parts[1],
                            name: parts[2]
                        })
                    }
                }
                root.pairedList = paired
                root.availableList = avail
            }
        }
    }

    // Background Poll while open
    Timer {
        interval: root.isScanning ? 1500 : 2500
        running: root.isOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: scanProc.running = true
    }

    // Auto-stop scanning after 15 seconds
    Timer {
        id: scanTimeoutTimer
        interval: 15000
        running: false
        repeat: false
        onTriggered: root.stopScan()
    }

    onIsOpenChanged: {
        if (isOpen) {
            scanProc.running = true
        } else {
            root.stopScan()
        }
    }

    Process { id: actionProc }
    function execBt(cmd) {
        actionProc.command = ["bash", "-c", cmd]
        actionProc.running = false
        actionProc.running = true
        scanProc.running = true
    }

    Process { id: scanWorker }
    function startScan() {
        if (!root.btPowered) return
        root.isScanning = true
        scanWorker.command = ["bash", "-c", "bluetoothctl --timeout 15 scan on >/dev/null 2>&1 &"]
        scanWorker.running = false
        scanWorker.running = true
        scanTimeoutTimer.restart()
        scanProc.running = true
    }

    function stopScan() {
        root.isScanning = false
        scanTimeoutTimer.stop()
        actionProc.command = ["bash", "-c", "bluetoothctl scan off >/dev/null 2>&1 || true"]
        actionProc.running = false
        actionProc.running = true
        scanProc.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: "#d907111c"
        border.color: root.colors?.cyan ?? "#00E5FF"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // Top Header: Title, Scan Button, Power Pill
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "󰂯  BLUETOOTH"
                    color: root.colors?.cyan ?? "#00E5FF"
                    font.pixelSize: 12
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Scan / Refresh Pill
                Rectangle {
                    implicitWidth: 62
                    implicitHeight: 22
                    radius: 6
                    color: root.isScanning ? "#33ffe800" : "#1a16202c"
                    border.color: root.isScanning ? (root.colors?.gold ?? "#FFE800") : (root.colors?.pillBorder ?? "#4d00e5ff")
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: root.isScanning ? "SCANNING" : "󰑐 SCAN"
                        color: root.isScanning ? (root.colors?.gold ?? "#FFE800") : (root.colors?.text ?? "#cdd6f4")
                        font.pixelSize: 9
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.isScanning) {
                                root.stopScan()
                            } else {
                                root.startScan()
                            }
                        }
                    }
                }

                // Power Toggle Pill
                Rectangle {
                    implicitWidth: 54
                    implicitHeight: 22
                    radius: 6
                    color: root.btPowered ? "#2600e5ff" : "#1a16202c"
                    border.color: root.btPowered ? (root.colors?.cyan ?? "#00E5FF") : "#5d6371"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: root.btPowered ? "ON" : "OFF"
                        color: root.btPowered ? (root.colors?.cyan ?? "#00E5FF") : "#cdd6f4"
                        font.pixelSize: 9
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.btPowered) {
                                root.stopScan()
                                root.execBt("bluetoothctl power off")
                            } else {
                                root.execBt("bluetoothctl power on")
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#3300e5ff"
            }

            // Paired Devices Header
            Text {
                text: "PAIRED DEVICES"
                color: root.colors?.gold ?? "#FFE800"
                font.pixelSize: 9
                font.bold: true
            }

            // Paired Devices List
            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(root.pairedList.length * 44, 130)
                clip: true
                spacing: 4
                model: root.pairedList

                delegate: Rectangle {
                    required property var modelData
                    width: parent ? parent.width : 310
                    implicitHeight: 38
                    radius: 8
                    color: modelData.connected ? "#1affe800" : "#a6060e18"
                    border.color: modelData.connected ? (root.colors?.gold ?? "#FFE800") : (root.colors?.pillBorder ?? "#4d00e5ff")
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: modelData.connected ? "󰂱" : "󰂯"
                            color: modelData.connected ? (root.colors?.gold ?? "#FFE800") : (root.colors?.cyan ?? "#00E5FF")
                            font.pixelSize: 13
                        }

                        Text {
                            text: modelData.name
                            color: root.colors?.text ?? "#cdd6f4"
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.connected ? "DISCONNECT" : "CONNECT"
                            color: modelData.connected ? (root.colors?.gold ?? "#FFE800") : (root.colors?.cyan ?? "#00E5FF")
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var act = modelData.connected ? "disconnect" : "connect"
                            root.execBt("bluetoothctl " + act + " " + modelData.mac)
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2200e5ff"
            }

            // Available / Discovered Devices Header
            Text {
                text: root.isScanning ? "DISCOVERED DEVICES (SCANNING...)" : "DISCOVERED DEVICES"
                color: root.colors?.cyan ?? "#00E5FF"
                font.pixelSize: 9
                font.bold: true
            }

            // Available Devices List
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: root.availableList

                delegate: Rectangle {
                    required property var modelData
                    width: parent ? parent.width : 310
                    implicitHeight: 36
                    radius: 8
                    color: "#a6060e18"
                    border.color: root.colors?.pillBorder ?? "#4d00e5ff"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            text: "󰂰"
                            color: root.colors?.cyan ?? "#00E5FF"
                            font.pixelSize: 12
                        }

                        Text {
                            text: modelData.name
                            color: root.colors?.text ?? "#cdd6f4"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "PAIR"
                            color: root.colors?.cyan ?? "#00E5FF"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.execBt("bluetoothctl pair " + modelData.mac + " && bluetoothctl connect " + modelData.mac)
                        }
                    }
                }
            }
        }
    }
}
