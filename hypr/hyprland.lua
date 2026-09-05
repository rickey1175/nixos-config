-- -----------------------------------------------------------------------------
-- HYPRLAND LUA CONFIGURATION (V9 - NATIVE QUICKSHELL + SCROLLER + DA-VINCI)
-- -----------------------------------------------------------------------------

------------------
---- MONITORS ----
------------------
hl.monitor({
   output   = "",
   mode     = "preferred",
   position = "auto",
   scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "dolphin"
local obsApp      = "env QT_QPA_PLATFORM=wayland obs"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function ()
   hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE &")
   hl.exec_cmd("systemctl --user start graphical-session.target &")
   hl.exec_cmd("fix-portal &")
   hl.exec_cmd("hyprctl plugin load " .. (os.getenv("HOME") or "/home/rickey") .. "/.nix-profile/lib/libhyprscroller.so || hyprctl plugin load /run/current-system/sw/lib/libhyprscroller.so &")
   hl.exec_cmd("quickshell &")
   hl.exec_cmd("swww-daemon &")
   hl.exec_cmd("wl-paste --type text --watch cliphist store &")
   hl.exec_cmd("wl-paste --type image --watch cliphist store &")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_DATA_DIRS", "/home/rickey/.nix-profile/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share:" .. (os.getenv("XDG_DATA_DIRS") or ""))

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
   general = {
       gaps_in  = 5,
       gaps_out = 10,
       border_size = 2,
       col = {
           active_border   = "0xeeffe135",
           inactive_border = "0xaa12263a",
       },
       resize_on_border = true,
       allow_tearing = false,
       layout = "scroller",
   },
   decoration = {
       rounding         = 12,
       active_opacity   = 0.78,
       inactive_opacity = 0.65,
       blur = {
           enabled   = true,
           size      = 10,
           passes    = 3,
           vibrancy  = 0.1696,
       },
   },
   animations = {
       enabled = true,
   },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

--------------
---- MISC ----
--------------
hl.config({
   misc = {
       force_default_wallpaper = -1,
       disable_hyprland_logo   = false,
   },
})

---------------
---- INPUT ----
---------------
hl.config({
   input = {
       kb_layout    = "us",
       kb_variant   = "",
       kb_model     = "",
       kb_options   = "",
       kb_rules     = "",
       follow_mouse = 1,
       sensitivity  = 0,
       touchpad     = {
           natural_scroll = false,
       },
   },
})
hl.gesture({
   fingers   = 3,
   direction = "horizontal",
   action    = "workspace"
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Core Application Binds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + O",      hl.dsp.exec_cmd(obsApp))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())

-- Quickshell Clean Wrapper Keybinds
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd("qs-launcher"))
hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd("qs-wallpapers"))
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd("quickshell ipc call lock activate"))

-- Super + Tab Overview (Task View)
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("hyprctl dispatch scroller:toggleoverview"))

-- Scroller Column Focus Movement (HJKL & Arrows)
hl.bind(mainMod .. " + left",  hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus l"))
hl.bind(mainMod .. " + right", hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus r"))
hl.bind(mainMod .. " + up",    hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus u"))
hl.bind(mainMod .. " + down",  hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus d"))
hl.bind(mainMod .. " + h",     hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus l"))
hl.bind(mainMod .. " + l",     hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus r"))
hl.bind(mainMod .. " + k",     hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus u"))
hl.bind(mainMod .. " + j",     hl.dsp.exec_cmd("hyprctl dispatch scroller:movefocus d"))

-- Scroller Move Window Between Columns
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.exec_cmd("hyprctl dispatch scroller:movewindow l"))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.exec_cmd("hyprctl dispatch scroller:movewindow r"))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.exec_cmd("hyprctl dispatch scroller:movewindow u"))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.exec_cmd("hyprctl dispatch scroller:movewindow d"))
hl.bind(mainMod .. " + SHIFT + h",     hl.dsp.exec_cmd("hyprctl dispatch scroller:movewindow l"))
hl.bind(mainMod .. " + SHIFT + l",     hl.dsp.exec_cmd("hyprctl dispatch scroller:movewindow r"))

-- Scroller Column Sizing Controls
hl.bind(mainMod .. " + bracketleft",  hl.dsp.exec_cmd("hyprctl dispatch scroller:cyclesize prev"))
hl.bind(mainMod .. " + bracketright", hl.dsp.exec_cmd("hyprctl dispatch scroller:cyclesize next"))
hl.bind(mainMod .. " + equal",        hl.dsp.exec_cmd("hyprctl dispatch scroller:fitsize visible"))

-- Screenshots & Annotations (Grim + Slurp + Swappy)
hl.bind("Print",         hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Workspaces Navigation & Moving Windows
for i = 1, 10 do
   local key = i % 10
   hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
   hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special Workspace (Scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse Workspaces & Window Drag/Resize
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Audio & Hardware Controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- App Opacity
hl.window_rule({ name = "kitty-opacity", match = { class = "kitty" }, opacity = 0.72 })
hl.window_rule({ name = "vscode-opacity", match = { class = "^(Code|code-url-handler|VSCode)$" }, opacity = 0.80 })
hl.window_rule({ name = "dolphin-opacity", match = { class = "org.kde.dolphin" }, opacity = 0.78 })
hl.window_rule({ name = "discord-opacity", match = { class = "discord" }, opacity = 0.80 })
hl.window_rule({ name = "gimp-opacity", match = { class = "^(Gimp|gimp-.*)$" }, opacity = 0.88 })
hl.window_rule({ name = "obs-opacity", match = { class = "com.obsproject.Studio" }, opacity = 0.85 })

-- Floating Dialogs
hl.window_rule({ name = "swappy-float", match = { class = "swappy" }, float = true })
hl.window_rule({ name = "piper-float", match = { class = "ratbag-piper|piper" }, float = true })
hl.window_rule({ name = "goverlay-float", match = { class = "goverlay" }, float = true })

-- DaVinci Resolve Window Handling
hl.window_rule({
    name = "resolve-suppress-maximize",
    match = { class = "^(resolve)$" },
    suppress_event = "maximize",
})
hl.window_rule({
    name = "resolve-project-manager-float",
    match = { class = "^(resolve)$", title = "^(Project Manager|Welcome to DaVinci Resolve)$" },
    float = true,
})

-- Hyprland Core Window Rules
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
hl.window_rule({
   name = "fix-xwayland-drags",
   match = {
       class      = "^$",
       title      = "^$",
       xwayland   = true,
       float      = true,
       fullscreen = false,
       pin        = false,
   },
   no_focus = true,
})
