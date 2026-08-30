import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Text {
    property var colors
    text: Hyprland.activeWindow?.title ?? "Desktop"
    color: colors?.text ?? "#cdd6f4"
    font.pixelSize: 13
    font.bold: true
    elide: Text.ElideRight
    Layout.maximumWidth: 350
}