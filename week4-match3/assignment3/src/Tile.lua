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
end

function Tile:render(x, y)
    -- if self.powerupType ~= nil then
    --     self.renderParticles(self)
    -- end


    -- draw shadow

    love.graphics.setColor(34, 32, 52, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself


    love.graphics.setColor(255, 255, 255, 1) -- alpha is from 0-1 not 255
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- TODO FIGURE OUT WHY THE PSYSTEM NOT WORKING
    if self.powerupType ~= nil then
        -- do the power up render
        love.graphics.setColor(255, 1, 1, 1)
        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf('X', self.x + x + 1, self.y + TILE_HIGHT - 8, TILE_WIDTH, 'center')
    end
end

function Tile:update(dt)
    print("Tile Update", dt)
end
