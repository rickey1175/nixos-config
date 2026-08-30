import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "modules"

ShellRoot {
    id: root

    // Reference the singleton theme directly
    property var colors: Theme

    // Global Overlays
    WallpaperSelector {
        id: globalWallSelector
        colors: root.colors
        wallpaperDir: Quickshell.env("HOME") + "/Pictures/wallp"
    }

    PowerMenu {
        id: globalPowerMenu
        colors: root.colors
        onRequestLock: globalLockScreen.isLocked = true
    }

    CalendarDropdown {
        id: globalCalendar
        colors: root.colors
    }

    NotificationPanel {
        id: globalNotifPanel
        colors: root.colors
    }

    LockScreen {
        id: globalLockScreen
        colors: root.colors
        isLocked: false
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 40
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: 14
                color: root.colors.pillBg

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.colors.gold }
                    GradientStop { position: 0.5; color: root.colors.cyan }
                    GradientStop { position: 1.0; color: root.colors.gold }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1.2
                    radius: 13
                    color: root.colors.pillBg
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 6

                    // Left
                    Workspaces { colors: root.colors }
                    Taskbar { colors: root.colors }
                    HardwareStats { colors: root.colors }

                    Item { Layout.fillWidth: true }

                    // Center
                    CenterCluster {
                        colors: root.colors
                        onToggleCalendar: globalCalendar.isOpen = !globalCalendar.isOpen
                        onToggleNotifPanel: globalNotifPanel.isOpen = !globalNotifPanel.isOpen
                    }

                    Item { Layout.fillWidth: true }

                    // Right
                    SystemControls {
                        colors: root.colors
                        onRequestPowerMenu: globalPowerMenu.isOpen = !globalPowerMenu.isOpen
                    }
                }
            }
        }
    }
}