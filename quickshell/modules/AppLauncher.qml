import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    property var colors
    property bool isOpen: false

    function toggle() {
        isOpen = !isOpen
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: isOpen
    color: "#a6000000"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: root.isOpen = false
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.isOpen = false
    }

    property var allApps: []
    property var filteredApps: []

    Process {
        id: appScanner
        command: [
            "bash", "-c",
            "dirs=(\n" +
            "  \"$HOME/.local/share/applications\"\n" +
            "  \"$HOME/.nix-profile/share/applications\"\n" +
            "  \"/run/current-system/sw/share/applications\"\n" +
            "  \"/var/lib/flatpak/exports/share/applications\"\n" +
            "  \"$HOME/.local/share/flatpak/exports/share/applications\"\n" +
            ")\n" +
            "IFS=':' read -ra extra_dirs <<< \"$XDG_DATA_DIRS\"\n" +
            "for d in \"${extra_dirs[@]}\"; do\n" +
            "  [ -d \"$d/applications\" ] && dirs+=(\"$d/applications\")\n" +
            "done\n" +
            "valid_dirs=()\n" +
            "for d in \"${dirs[@]}\"; do\n" +
            "  [ -d \"$d\" ] && valid_dirs+=(\"$d\")\n" +
            "done\n" +
            "if [ ${#valid_dirs[@]} -gt 0 ]; then\n" +
            "  find -L \"${valid_dirs[@]}\" -maxdepth 2 -name '*.desktop' 2>/dev/null | while read -r f; do\n" +
            "    name=$(grep -m1 '^Name=' \"$f\" 2>/dev/null | cut -d= -f2-)\n" +
            "    exec_cmd=$(grep -m1 '^Exec=' \"$f\" 2>/dev/null | cut -d= -f2- | sed -E 's/%[a-zA-Z]//g')\n" +
            "    nodisplay=$(grep -m1 '^NoDisplay=' \"$f\" 2>/dev/null | cut -d= -f2)\n" +
            "    hidden=$(grep -m1 '^Hidden=' \"$f\" 2>/dev/null | cut -d= -f2)\n" +
            "    if [ \"$nodisplay\" != \"true\" ] && [ \"$hidden\" != \"true\" ] && [ -n \"$name\" ] && [ -n \"$exec_cmd\" ]; then\n" +
            "      echo \"$name|$exec_cmd\"\n" +
            "    fi\n" +
            "  done\n" +
            "fi | sort -u -t'|' -k1,1"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                var apps = []
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].split("|")
                    if (p.length >= 2 && p[0].trim().length > 0) {
                        apps.push({ name: p[0].trim(), exec: p.slice(1).join("|").trim() })
                    }
                }
                root.allApps = apps
                root.filteredApps = apps
            }
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            searchInput.text = ""
            appScanner.running = true
            searchInput.forceActiveFocus()
        }
    }

    Process { id: spawnExec }
    function launch(cmd) {
        root.isOpen = false
        spawnExec.command = ["bash", "-c", "nohup " + cmd + " >/dev/null 2>&1 &"]
        spawnExec.running = false
        spawnExec.running = true
    }

    Rectangle {
        anchors.centerIn: parent
        width: 540
        height: 440
        radius: 14
        color: "#f2060e18"
        border.color: root.colors?.cyan ?? "#00E5FF"
        border.width: 1.5

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰍉  UNSC DIRECTORY // APPLICATION LAUNCHER"
                    color: root.colors?.gold ?? "#FFE800"
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 8
                color: "#121a24"
                border.color: root.colors?.gold ?? "#FFE800"
                border.width: 1

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.bold: true
                    focus: true
                    clip: true

                    onTextChanged: {
                        var q = text.toLowerCase().trim()
                        if (q.length === 0) {
                            root.filteredApps = root.allApps
                        } else {
                            root.filteredApps = root.allApps.filter(a => a.name.toLowerCase().includes(q))
                        }
                    }

                    onAccepted: {
                        if (root.filteredApps.length > 0) {
                            root.launch(root.filteredApps[0].exec)
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#3300e5ff"
            }

            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: root.filteredApps

                delegate: Rectangle {
                    required property var modelData
                    width: appList.width
                    implicitHeight: 36
                    radius: 6
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: ""
                            color: root.colors?.cyan ?? "#00E5FF"
                            font.pixelSize: 12
                        }

                        Text {
                            text: modelData.name
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "EXEC"
                            color: root.colors?.gold ?? "#FFE800"
                            font.pixelSize: 9
                            font.bold: true
                            opacity: 0.6
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = "#2600e5ff"
                        onExited: parent.color = "transparent"
                        onClicked: root.launch(modelData.exec)
                    }
                }
            }
        }
    }
}
