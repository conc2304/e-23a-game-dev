Box = {}
Box.__index = Box

function Box.new(x, y, width, height)
    local self = setmetatable({}, Box)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.color = {0, 0, 1} -- blue color
    self.ySpeed = 50 -- speed of vertical movement
    self.direction = 1 -- moving direction (1 for up, -1 for down)

    -- Create a 1x1 white pixel image for particles
    local particleImage = love.graphics.newCanvas(1, 1)
    love.graphics.setCanvas(particleImage)
    love.graphics.clear(1, 1, 1, 1) -- Set the color to white
    love.graphics.setCanvas() -- Reset the canvas

    -- Initialize the particle system
    self.particleSystem = love.graphics.newParticleSystem(particleImage, 100)
    self.particleSystem:setParticleLifetime(1, 2) -- Particles live at least 1s and at most 2s.
    self.particleSystem:setEmissionRate(50) -- Increase the emission rate
    self.particleSystem:setSizeVariation(1)
    self.particleSystem:setSizes(4, 8) -- Make particles bigger
    self.particleSystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
    self.particleSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Start red, fade to transparent.

    return self
end

function Box:update(dt)
    self.y = self.y + self.direction * self.ySpeed * dt
    -- Change direction when reaching certain bounds
    if self.y < 50 or self.y > 300 then
        self.direction = self.direction * -1
    end

    -- Update the particle system
    self.particleSystem:setPosition(self.x + self.width / 2, self.y + self.height / 2)
    self.particleSystem:update(dt)
end

function Box:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw the particle system
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.particleSystem)
end
