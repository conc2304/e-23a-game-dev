--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class {}

TILE_WIDTH = 32
TILE_HIGHT = 32

TILE_VARIETY_MAX = 6
TILE_VARIETY_MIN = 1

TILE_COLOR_MIN = 1
TILE_COLOR_MAX = 18

TILE_PUP_DESTORY_ROW = 1

TILE_POWERUPS = {
    TILE_PUP_DESTORY_ROW
}

function Tile:init(x, y, color, variety, powerupType)
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * TILE_WIDTH
    self.y = (self.gridY - 1) * TILE_HIGHT

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.powerupType = TILE_POWERUPS[powerupType] or nil

    self.psystem = self.powerupType ~= nil and self.initializePSystem()
end

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 1) -- alpha is from 0-1 not 255
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.powerupType ~= nil and self.psystem ~= nil then
        love.graphics.draw(self.psystem, self.x + x + (TILE_WIDTH / 2), self.y + y + (TILE_HIGHT / 2))
    end
end

function Tile:update(dt)
    if self.psystem then
        self.psystem:update(dt)
    end
end

function Tile:initializePSystem()
    -- Create a 1x1 white pixel image for particles
    local particleSystem = nil
    local particleImage = love.graphics.newCanvas(1, 1)
    love.graphics.setCanvas(particleImage)
    love.graphics.clear(1, 1, 1, 1) -- Set the color to white
    love.graphics.setCanvas()       -- Reset the canvas

    -- Initialize the particle system
    particleSystem = love.graphics.newParticleSystem(particleImage, 20)
    particleSystem:setParticleLifetime(1, 2)               -- Particles live at least 1s and at most 2s.
    particleSystem:setEmissionRate(20)                     -- Increase the emission rate
    particleSystem:setSizeVariation(1)
    particleSystem:setSizes(1, 3)                          -- Make particles bigger
    particleSystem:setLinearAcceleration(-10, -10, 10, 10) -- Random movement in all directions.
    particleSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0.5)     -- Start red, fade to transparent.

    return particleSystem
end
