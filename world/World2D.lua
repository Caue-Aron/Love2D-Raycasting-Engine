local misc      = require("misc")
local Object    = require("classic")

local World2D = Object:extend()

function World2D:new(map)
    self.w = map.w
    self.h = map.h
    self.size = 64

    self.map = {}
    for i = 0, #map do
        self.map[i] = {r = map[i].r, g = map[i].g, b = map[i].b}
    end

end

function World2D:draw()
    local mapx, mapy, maps = self.w, self.h, self.size
    local cell, xo, yo

    for y = 0, mapy - 1 do
        for x = 0, mapx - 1 do
            cell = self.map[y*mapx+x]
            love.graphics.setColor(misc.extractColors(cell))

            xo = x*maps
            yo = y*maps

            love.graphics.rectangle("fill", (xo + 1) /2, yo + 1, maps - 1, maps - 1)
        end
    end
end

function World2D:tileAt(x, y)
    local tilex = math.floor(x / self.size)
    local tiley = math.floor(y / self.size)

    -- tile index / tile x pos / tile y pos
    local cell = (tiley * self.x + tilex)
    return cell, tilex, tiley, self.map[cell]
end

return World2D