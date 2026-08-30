import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Scope {
    id: root
    property var colors
    property bool isLocked: true
    property bool authFailed: false

    // Shared Date / Time Strings
    property string currentTimeStr: Qt.formatTime(new Date(), "hh:mm AP")
    property string currentDateStr: Qt.formatDate(new Date(), "dddd, MMMM d")

    // Reliable PAM / Password Verification
    Process {
        id: pamCheckProc

        function verify(pwd) {
            command = ["bash", "-c", "echo -n '" + pwd + "' | /run/wrappers/bin/unix_chkpwd $USER nullok 2>/dev/null || echo -n '" + pwd + "' | sudo -S -k true 2>/dev/null"]
            running = false
            running = true
        }

        onExited: (code) => {
            if (code === 0) {
                root.isLocked = false
                root.authFailed = false
            } else {
                root.authFailed = true
            }
        }
    }

    // MPRIS Media Status Tracker
    property string artUrl: ""
    property string trackTitle: "Join Me In Death"
    property string trackArtist: "HIM"
    property string playbackStatus: "PLAYING"

    Timer {
        interval: 1000
        running: root.isLocked
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.currentTimeStr = Qt.formatTime(new Date(), "hh:mm AP")
            root.currentDateStr = Qt.formatDate(new Date(), "dddd, MMMM d")
            mediaProc.running = true
        }
    }

    Process {
        id: mediaProc
        command: ["bash", "-c", "echo \"$(playerctl metadata mpris:artUrl 2>/dev/null)|$(playerctl metadata title 2>/dev/null)|$(playerctl metadata artist 2>/dev/null)|$(playerctl status 2>/dev/null)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = this.text.trim().split("|")
                if (p.length >= 4 && p[1].length > 0) {
                    root.artUrl = p[0].trim()
                    root.trackTitle = p[1].trim()
                    root.trackArtist = p[2].trim()
                    root.playbackStatus = p[3].trim().toUpperCase()
                }
            }
        }
    }

    Process { id: mprisControl }
    function sendMedia(cmd) {
        mprisControl.command = ["playerctl", cmd]
        mprisControl.running = false
        mprisControl.running = true
    }

    // Multi-Monitor Window Generator
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: lockWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            visible: root.isLocked
            color: "#0a0f16"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.isLocked ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            RowLayout {
                anchors.centerIn: parent
                spacing: 24

                // -------------------------------------------------------------
                // CARD 1: MEDIA PLAYER (Left)
                // -------------------------------------------------------------
                Rectangle {
                    implicitWidth: 260
                    implicitHeight: 390
                    radius: 18
                    color: "#b307111c"
                    border.color: root.colors?.cyan ?? "#00E5FF"
                    border.width: 1.5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 170
                            implicitHeight: 170
                            radius: 14
                            color: "#16202c"
                            border.color: root.colors?.gold ?? "#FFE800"
                            border.width: 1
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: root.artUrl.length > 0 ? root.artUrl : ""
                                fillMode: Image.PreserveAspectCrop
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: root.artUrl.length === 0
                                text: "󰎈"
                                color: root.colors?.gold ?? "#FFE800"
                                font.pixelSize: 42
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2
                            Text {
                                text: root.trackTitle
                                color: root.colors?.gold ?? "#FFE800"
                                font.pixelSize: 13
                                font.bold: true
                                Layout.maximumWidth: 210
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: root.trackArtist
                                color: root.colors?.text ?? "#cdd6f4"
                                font.pixelSize: 11
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 110
                            implicitHeight: 22
                            radius: 6
                            color: "#1a00e5ff"

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: "󰎈"; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 10 }
                                Text { text: root.playbackStatus; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 16

                            Text {
                                text: "󰒮 PREV"
                                color: root.colors?.text ?? "#cdd6f4"
                                font.pixelSize: 9
                                font.bold: true
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.sendMedia("previous") }
                            }
                            Text {
                                text: "PLAY"
                                color: root.colors?.gold ?? "#FFE800"
                                font.pixelSize: 9
                                font.bold: true
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.sendMedia("play-pause") }
                            }
                            Text {
                                text: "NEXT 󰒭"
                                color: root.colors?.text ?? "#cdd6f4"
                                font.pixelSize: 9
                                font.bold: true
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.sendMedia("next") }
                            }
                        }
                    }
                }

                // -------------------------------------------------------------
                // CARD 2: CLOCK & AUTHENTICATION (Center)
                // -------------------------------------------------------------
                Rectangle {
                    implicitWidth: 280
                    implicitHeight: 390
                    radius: 18
                    color: "#b307111c"
                    border.color: root.colors?.cyan ?? "#00E5FF"
                    border.width: 1.5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 10

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 6
                            Text { text: "󱄅"; color: root.colors?.cyan ?? "#00E5FF"; font.pixelSize: 22 }
                            Text { text: "NixOS"; color: root.colors?.text ?? "#cdd6f4"; font.pixelSize: 16; font.bold: true }
                        }

                        Item { Layout.preferredHeight: 12 }

                        Text {
                            text: root.currentTimeStr
                            color: root.colors?.gold ?? "#FFE800"
                            font.pixelSize: 32
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: root.currentDateStr
                            color: root.colors?.cyan ?? "#00E5FF"
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "+"
                            color: root.colors?.text ?? "#cdd6f4"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Item { Layout.preferredHeight: 10 }

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 200
                            implicitHeight: 34
                            radius: 10
                            color: root.authFailed ? "#33ff2a2a" : "#1a00e5ff"
                            border.color: root.authFailed ? (root.colors?.red ?? "#FF2A2A") : (root.colors?.cyan ?? "#00E5FF")
                            border.width: 1

                            TextInput {
                                id: pwdInput
                                anchors.fill: parent
                                anchors.margins: 6
                                echoMode: TextInput.Password
                                passwordCharacter: "●"
                                color: root.colors?.gold ?? "#FFE800"
                                font.pixelSize: 14
                                horizontalAlignment: TextInput.AlignHCenter
                                verticalAlignment: TextInput.AlignVCenter
                                focus: true

                                onVisibleChanged: {
                                    if (visible) forceActiveFocus()
                                }

                                onAccepted: {
                                    if (text.length > 0) {
                                        pamCheckProc.verify(text)
                                        text = ""
                                    }
                                }
                            }
                        }

                        Text {
                            text: root.authFailed ? "Authentication Failed" : "Enter Password"
                            color: root.authFailed ? (root.colors?.red ?? "#FF2A2A") : (root.colors?.inactiveText ?? "#6c7086")
                            font.pixelSize: 10
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // -------------------------------------------------------------
                // CARD 3: SCRIPTURE CARD (Right)
                // -------------------------------------------------------------
                Rectangle {
                    implicitWidth: 260
                    implicitHeight: 390
                    radius: 18
                    color: "#b307111c"
                    border.color: root.colors?.gold ?? "#FFE800"
                    border.width: 1.5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        RowLayout {
                            spacing: 6
                            Text { text: "󰗡"; color: root.colors?.gold ?? "#FFE800"; font.pixelSize: 14 }
                            Text { text: "SCRIPTURE"; color: root.colors?.gold ?? "#FFE800"; font.pixelSize: 12; font.bold: true }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#33ffe800"
                        }

                        Text {
                            text: "\"For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.\""
                            color: root.colors?.cyan ?? "#00E5FF"
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "— John 3:16"
                            color: root.colors?.gold ?? "#FFE800"
                            font.pixelSize: 9
                            font.bold: true
                            Layout.alignment: Qt.AlignRight
                        }

                        Text {
                            text: "\"Put on the whole armour of God, that ye may be able to stand against the wiles of the devil.\""
                            color: root.colors?.cyan ?? "#00E5FF"
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "— Ephesians 6:11"
                            color: root.colors?.gold ?? "#FFE800"
                            font.pixelSize: 9
                            font.bold: true
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
        }
    }
}