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
    local statePrefix = self.entity.liftedItem ~= nil and 'carry-' or ''
    local animationKey = statePrefix .. 'idle-' .. self.entity.direction

    self.entity:changeAnimation(animationKey)
end

function PlayerIdleState:update(dt)
    local statePrefix = self.entity.liftedItem ~= nil and 'carry-' or ''
    -- local statePrefix = self.entity.liftedItem ~= nil and 'carry-' or ''
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
        love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        local animationKey = statePrefix .. 'walk-' .. self.entity.direction
        self.entity:changeState('walk')
        self.entity:changeAnimation(animationKey)
    end

    if self.entity.liftedItem == nil and love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        local objects = self.dungeon.currentRoom.objects or nil
        if objects then
            if self.entity.liftedItem == nil then
                local isLifting = self.entity:lift(objects)
                if isLifting then
                    self.entity:changeState('lift-item')
                end
            else
                self.entity:dropItem()
                self.entity:changeState('carry-item-idle')
            end
        end
    end
end
