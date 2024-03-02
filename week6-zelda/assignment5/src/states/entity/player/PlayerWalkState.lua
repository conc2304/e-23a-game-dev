--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerWalkState = Class { __includes = EntityWalkState }

function PlayerWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerWalkState:update(dt)
    self:handleKeyboardInput()

    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)

    -- if we bumped something when checking collision, check any object collisions
    if self.bumped then
        if self.entity.direction == 'left' then
            -- temporarily adjust position into the wall, since bumping pushes outward
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt

            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-left')
                end
            end

            -- readjust
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'right' then
            -- temporarily adjust position
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt

            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-right')
                end
            end

            -- readjust
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'up' then
            -- temporarily adjust position
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt

            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-up')
                end
            end

            -- readjust
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
        else
            -- temporarily adjust position
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt

            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-down')
                end
            end

            -- readjust
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
        end
    end
end

function PlayerWalkState:handleKeyboardInput()
    local statePrefix = self.entity.liftedItem ~= nil and 'carry-' or ''

    local keyboarDirections = { 'up', 'down', 'left', 'right' }
    local dirPressed = false
    for _, keyDir in pairs(keyboarDirections) do
        if love.keyboard.isDown(keyDir) then
            self.entity.direction = keyDir
            local animationKey = statePrefix .. 'walk-' .. keyDir
            self.entity:changeAnimation(animationKey)
            dirPressed = true
        end
    end

    -- handle attempting to lift an item
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        local objects = self.dungeon.currentRoom.objects or nil
        if objects then
            local isLifting = self.entity:lift(objects)
            if isLifting then
                self.entity:changeState('carry-item-walk')
            end
        end
    end

    if not dirPressed then
        local animationKey = statePrefix .. 'idle-' .. self.entity.direction
        self.entity:changeState('idle')
        self.entity:changeAnimation(animationKey)
    end

    -- play can only swing if they are not carrying anything
    if self.entity.liftedItem == nil and love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end
end
