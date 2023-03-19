local misc          = require("misc")
local Player        = require("Player")
local World2D       = require("world.World2D")
local World3D       = require("world.World3D")

function love.load()
    local maps = table.load("maps/converter/maps.lua")

    world = World2D(maps[2])

    player = Player(
        128-32,128-32, 25, DEG3, {r=1, g=1, b=0}, 8,
        world
    )

    map3d = World3D(160,320, world, player.ray)
end
function love.update(dt)
    player:update(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
    -- world:draw()
    -- player:draw()
    map3d:draw()

    love.graphics.print(love.timer.getFPS())
end