----------------
--- KEYBINDS ---
----------------

local mod = "SUPER"

hl.bind(mod .. " + W", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + R", hl.dsp.exec_cmd("hyprlauncher"))
hl.bind(mod .. " + T", hl.dsp.exec_cmd("kitty"))

hl.bind(mod .. " + A", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + S", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + D", hl.dsp.focus({ direction = "right"}))
hl.bind(mod .. " + F", hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

hl.bind(mod .. " + Z", hl.dsp.layout("swapwithmaster"))
local closeWindow = hl.bind(mod .. " + C", hl.dsp.window.close())

hl.bind(mod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,	    hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key,    hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
