local Object    = require("classic")
local bit       = require("bit")
local misc      = require("misc")

local rshift,lshift = bit.rshift,bit.lshift

local Raycast = Object:extend()

--[[
    HOW TO USE Raycast CLASS

    All the ray's end point's positions are stored into the
    `self.rays_epos` {x, y, d} as positions x and y and distance
]]

function Raycast:new(map)
    self.map = map
    self.rays_epos = nil
    self.ramount = 0
end

function Raycast:draw()
    for i, v in ipairs(self.rays_epos) do
        love.graphics.setColor(0, 1, 0.5, 1)
        local srad = 1
        love.graphics.setLineWidth(srad)
        love.graphics.line(
            self.px,self.py,
            v.x, v.y
        )
    end
end

function Raycast:cast(px,py, ang, ramount)
    local map = self.map
    self.px,self.py = px,py
    self.rays_epos = {}
    self.ramount = ramount

    local ra = misc.keepAngle(ang - DEG1 * 30)

    for r = 1, ramount do
        local function horizontaCast()
            -- horizontal lines
            local dof, xo,yo, mx,my,mp

            dof = 0
            local atan = -1/tan(ra)  -- math.atan wont work

            if ra > PI then -- ray looking up
                ry = lshift(rshift(math.floor(py), 6), 6) - 0.0001
                rx = (py-ry) * atan+px

                yo = -map.size
                xo = -yo * atan

            end
            if ra < PI then -- ray looking down
                ry = lshift(rshift(math.floor(py), 6), 6) + 64
                rx = (py-ry) * atan+px

                yo = map.size
                xo = -yo * atan

            end
            if ra==0 or ra==PI then
                rx,ry = px,py
                dof = 8
            end

            while dof < 8 do
                mx = rshift(math.floor(rx), 6)
                my = rshift(math.floor(ry), 6)
                mp = my*map.w+mx

                -- hit wall
                if mp < map.w*map.h and not misc.isColorBlack(map.map[mp]) then
                    dof = 8
                else
                    rx = rx+xo
                    ry = ry+yo
                    dof = dof + 1
                end
            end

            return rx, ry
        end

        local function verticalCast()
            local dof, rx,ry, xo,yo, mx,my,mp
            -- horizontal lines
            dof = 0
            local atan = -tan(ra)  -- math.atan wont work

            if ra > DEG90 and ra < DEG270 then -- ray looking left
                rx = lshift(rshift(math.floor(px), 6), 6) - 0.0001
                ry = (px-rx) * atan+py

                xo = -map.size
                yo = -xo * atan

            end
            if ra < DEG90 or ra > DEG270 then -- ray looking right
                rx = lshift(rshift(math.floor(px), 6), 6) + 64
                ry = (px-rx) * atan+py

                xo = map.size
                yo = -xo * atan

            end
            if ra==0 or ra==PI or ra == DEG90 then
                rx,ry = px,py
                dof = 8
            end

            while dof < 8 do
                mx = rshift(math.floor(rx), 6)
                my = rshift(math.floor(ry), 6)
                mp = my*map.w+mx

                -- hit wall
                if mp < map.w*map.h and not misc.isColorBlack(map.map[mp]) then
                    dof = 8
                else
                    rx = rx+xo
                    ry = ry+yo
                    dof = dof + 1
                end
            end

            return rx, ry
        end

        local hx, hy = horizontaCast()
        local vx, vy = verticalCast()

        local hd = misc.distance(px,py, hx,hy)
        local vd = misc.distance(px,py, vx,vy)

        local x,y
        local d = min(hd, vd)

        if d == hd then
            x = hx
            y = hy
            c = {r = .9, g = 0, b = 0}
        else
            x = vx
            y = vy
            c = {r = .7, g = 0, b = 0}
        end

        local cosa = misc.keepAngle(ang - ra)
        d = d * cos(cosa)

        table.insert(self.rays_epos, {x = x, y = y, d = d, c = c})

        ra = misc.keepAngle(ra + DEG1)
    end
end

return Raycast