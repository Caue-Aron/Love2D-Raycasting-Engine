local misc      = require("misc")
local Object    = require("classic")

local World3D = Object:extend()

function World3D:new(winw,winh, world, raycaster)
    self.winw, self.winh = winw, winh
    self.world = world
    self.raycaster = raycaster
end

function World3D:draw()
    local lineh = (self.world.size*self.winh)
    local linew = 8
    local wshift = 530
    local lineoffs
    local final_lineh


    for i, v in ipairs(self.raycaster.rays_epos) do
        final_lineh = lineh/v.d
        if final_lineh > self.winh then
            final_lineh = self.winh - linew
        end
        lineoffs = (self.winh/2) - final_lineh/2

        love.graphics.setColor(misc.extractColors(v.c))

        love.graphics.setLineWidth(linew)
        love.graphics.line(
            i * linew - (linew/2),
            lineoffs - (linew/2),
            i * linew - (linew/2),
            final_lineh + lineoffs + (linew/2)
        )
    end
end

return World3D