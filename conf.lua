local loom_ver = "1.0"
local title = "LOOM " .. loom_ver
local widht, height = 480, 320

function love.conf(t)
	t.console = true
	t.version = "11.4"
	t.title = title
    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.width = widht
    t.window.height = height
end