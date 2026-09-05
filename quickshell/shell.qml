import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "modules"

ShellRoot {
    id: root

    property var colors: Theme

    // Helper to close any open header dropdowns
    function closeDropdowns() {
        globalCalendar.isOpen = false
        globalBluetooth.isOpen = false
        globalNotifPanel.isOpen = false
    }

    // IPC Targets for Hyprland Keybinds
    IpcHandler {
        target: "launcher"
        function toggle() {
            root.closeDropdowns()
            globalPowerMenu.isOpen = false
            globalWallSelector.isOpen = false
            globalLauncher.toggle()
        }
    }

    IpcHandler {
        target: "powermenu"
        function toggle() {
            root.closeDropdowns()
            globalLauncher.isOpen = false
            globalWallSelector.isOpen = false
            globalPowerMenu.isOpen = !globalPowerMenu.isOpen
        }
    }

    IpcHandler {
        target: "wallpapers"
        function toggle() {
            root.closeDropdowns()
            globalLauncher.isOpen = false
            globalPowerMenu.isOpen = false
            globalWallSelector.isOpen = !globalWallSelector.isOpen
        }
    }

    IpcHandler {
        target: "lock"
        function activate() {
            root.closeDropdowns()
            globalLauncher.isOpen = false
            globalPowerMenu.isOpen = false
            globalWallSelector.isOpen = false
            globalLockScreen.isLocked = true
        }
    }

    // Global Overlay Singletons
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

    BluetoothDropdown {
        id: globalBluetooth
        colors: root.colors
    }

    AppLauncher {
        id: globalLauncher
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
                        onToggleCalendar: {
                            globalBluetooth.isOpen = false
                            globalCalendar.isOpen = !globalCalendar.isOpen
                        }
                        onToggleNotifPanel: {
                            globalNotifPanel.isOpen = !globalNotifPanel.isOpen
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Right
                    SystemControls {
                        colors: root.colors
                        onRequestPowerMenu: {
                            root.closeDropdowns()
                            globalPowerMenu.isOpen = !globalPowerMenu.isOpen
                        }
                        onToggleBluetooth: {
                            globalCalendar.isOpen = false
                            globalBluetooth.isOpen = !globalBluetooth.isOpen
                        }
                    }
                }
            }
        }
    }
}
