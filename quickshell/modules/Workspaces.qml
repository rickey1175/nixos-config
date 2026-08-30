import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var colors
    implicitHeight: 30
    implicitWidth: wsLayout.implicitWidth + 8
    radius: 12
    color: colors?.pillBg ?? "rgba(0, 0, 0, 0.70)"
    border.color: colors?.pillBorder ?? "rgba(0, 180, 216, 0.40)"
    border.width: 1

    RowLayout {
        id: wsLayout
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: 5

            Rectangle {
                required property int index
                readonly property int wsId: index + 1
                readonly property bool isFocused: (Hyprland.focusedWorkspace?.id ?? 1) === wsId

                implicitWidth: isFocused ? 24 : 18
                implicitHeight: 22
                radius: 8
                color: isFocused ? "rgba(0, 229, 255, 0.25)" : "transparent"
                border.color: isFocused ? (root.colors?.cyan ?? "#00E5FF") : "transparent"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: parent.wsId
                    color: parent.isFocused ? (root.colors?.cyan ?? "#00E5FF") : (root.colors?.red ?? "#FF2A2A")
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + parent.wsId)
                }
            }
        }
    }
}