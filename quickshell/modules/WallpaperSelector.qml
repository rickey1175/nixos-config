import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: root
    property var colors
    property bool isOpen: false
    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: isOpen
    color: "#99000000"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: root.isOpen = false
    }

    // List wallpapers from directory
    property var wallpaperList: []
    Process {
        id: listWallpapersProc
        command: ["bash", "-c", "find '" + root.wallpaperDir + "' -maxdepth 2 -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.jpeg' \\) | head -n 30"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n").filter(function(l) { return l.length > 0; })
                root.wallpaperList = lines
            }
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            listWallpapersProc.running = true
        }
    }

    // Wallpaper Changer Process
    Process {
        id: changeThemeProc
        function applyWallpaper(path) {
            command = [Quickshell.env("HOME") + "/quickshell/scripts/set_theme.sh", path]
            running = false
            running = true
        }
    }

    // Carousel Window Container
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 1100)
        height: 480
        radius: 24
        color: "#d907111c"
        border.color: root.colors?.cyan ?? "#00E5FF"
        border.width: 1.5

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Header Controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "󰸉"
                    color: root.colors?.gold ?? "#FFE800"
                    font.pixelSize: 22
                }

                Text {
                    text: "WALLPAPER CAROUSEL"
                    color: root.colors?.text ?? "#cdd6f4"
                    font.pixelSize: 15
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.wallpaperList.length + " Wallpapers"
                    color: root.colors?.inactiveText ?? "#6c7086"
                    font.pixelSize: 12
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2600e5ff"
            }

            // 3D Angled Cover-Flow PathView
            PathView {
                id: coverFlow
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.wallpaperList
                clip: true
                pathItemCount: 7
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5

                path: Path {
                    startX: 0
                    startY: coverFlow.height / 2
                    PathPercent { value: 0.0 }
                    PathLine { x: coverFlow.width * 0.5; y: coverFlow.height / 2 }
                    PathPercent { value: 0.5 }
                    PathLine { x: coverFlow.width; y: coverFlow.height / 2 }
                    PathPercent { value: 1.0 }
                }

                delegate: Item {
                    id: delegateItem
                    width: 280
                    height: 320
                    z: PathView.isCurrentItem ? 100 : (50 - Math.abs(PathView.onPath ? (PathView.view.offset - index) : 0))
                    scale: PathView.isCurrentItem ? 1.0 : 0.78
                    opacity: PathView.isCurrentItem ? 1.0 : 0.55

                    transform: Rotation {
                        origin.x: delegateItem.width / 2
                        origin.y: delegateItem.height / 2
                        axis { x: 0; y: 1; z: 0 }
                        angle: PathView.isCurrentItem ? 0 : (delegateItem.x < coverFlow.width / 2 ? 35 : -35)
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: "#16202c"
                        border.color: PathView.isCurrentItem ? (root.colors?.gold ?? "#FFE800") : (root.colors?.cyan ?? "#00E5FF")
                        border.width: PathView.isCurrentItem ? 2.5 : 1
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        // Bottom Title Pill
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 38
                            color: "#cc07111c"

                            Text {
                                anchors.centerIn: parent
                                width: parent.width - 20
                                text: modelData.split("/").pop()
                                color: root.colors?.text ?? "#cdd6f4"
                                font.pixelSize: 10
                                font.bold: true
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (coverFlow.currentIndex === index) {
                                    changeThemeProc.applyWallpaper(modelData)
                                    root.isOpen = false
                                } else {
                                    coverFlow.currentIndex = index
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}