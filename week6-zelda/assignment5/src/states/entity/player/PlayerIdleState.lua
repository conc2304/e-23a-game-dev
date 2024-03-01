--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class { __includes = EntityIdleState }

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
        love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    if self.entity.liftedItem == nil and love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        local objects = self.dungeon.currentRoom.objects or nil
        if not objects then return end
        self.entity:lift(objects)
    end
end
