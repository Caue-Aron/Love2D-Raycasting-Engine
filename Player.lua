local Object    = require("classic")
local Raycast   = require("physics.Raycast")
local misc      = require("misc")

local keyCheck = love.keyboard.isDown

local Player = Object:extend()

function Player:new(inix, iniy, spd, rotspd, c, rad, map)
    self.x,self.y = inix,iniy
    self.ang = DEG90
    self.dx = cos(self.ang) * 5
    self.dy = sin(self.ang) * 5

    self.spd = spd
    self.rotspd = rotspd

    self.color = c
    self.rad = rad

    self.map = map
    self.ray = Raycast(self.map, 1)
    self.ray:cast(self.x, self.y, self.ang, 1)
    self.raycast_amount = 60
end

function Player:update(dt)
    self:input(dt)
    self.ray:cast(self.x, self.y, self.ang, self.raycast_amount)
end

function Player:input(dt)
    if keyCheck("w") then
        self.x = self.x + self.dx * dt * self.spd
        self.y = self.y + self.dy * dt * self.spd

    end
    if keyCheck("s") then
        self.x = self.x - self.dx * dt * self.spd
        self.y = self.y - self.dy * dt * self.spd

    end
    if keyCheck("d") then
        self.ang = self.ang + self.rotspd
        if self.ang > DEG360 then
            self.ang = self.ang - DEG360
        end

        self.dx = cos(self.ang) * 5
        self.dy = sin(self.ang) * 5

    end
    if keyCheck("a") then
        self.ang = self.ang - self.rotspd
        if self.ang < 0 then
            self.ang = self.ang + DEG360
        end

        self.dx = cos(self.ang) * 5
        self.dy = sin(self.ang) * 5
    end
end

local function drawPlayer(self)
    love.graphics.setColor(misc.extractColors(self.color))
    love.graphics.setPointSize(self.rad)
    love.graphics.points({self.x, self.y})

    local srad = self.rad / 2
    local ld = 4
    love.graphics.setLineWidth(srad)
    love.graphics.line(
        self.x,self.y,
        self.x + self.dx * ld,
        self.y + self.dy * ld
    )
end

local function drawRay(self)
    self.ray:draw()
end

function Player:draw()
    drawRay(self)
    drawPlayer(self)
end

return Player