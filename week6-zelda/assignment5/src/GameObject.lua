--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class {}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states
    self.consumable = def.consumable
    self.liftable = def.liftable
    -- self.lifted = def.lifted or false   -
    self.health = def.health or false -- TODO was going to implement being able to hit pots to break them, but nah

    -- thrown item properties
    self.dx = 0
    self.dy = 0
    self.canDamage = def.canCamage or false
    self.throwDistance = def.throwDistance or 0 -- how far it can be throw
    self.distanceThrown = 0                     -- how far it has been thrown
    self.thrower = nil                          -- who did the throwing, so they dont get hurt by object thrown
    self.damageAmount = def.damageAmount or 0   -- how much damage it can do

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- default empty collision callback
    self.onCollide = def.onCollide or function() end
end

function GameObject:update(dt)
    -- if its not able to move then there is nothing to update
    if not self.liftable then return end

    self.distanceThrown = self.distanceThrown + math.abs((self.dx * dt) + (self.dy * dt))
    self.x = self.x + (self.dx * dt)
    self.y = self.y + (self.dy * dt)

    self:checkBoundaryCollsion(dt)

    if self.distanceThrown >= self.throwDistance then
        self:onBreak()
    end
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end

-- once lifted it shouldnt block entities
function GameObject:onLifted()
    self.solid = false
end

function GameObject:onRelease(x, y)
    self.solid = true
    self.x = x
    self.y = y
end

-- handle thrown object behavior
function GameObject:onThrown(throwSpeed, throwDirection, thrower)
    self.thrower = thrower
    self.canDamage = true
    self.solid = false
    local directionsDelta = {
        ['up'] = { dx = 0, dy = -throwSpeed },
        ['down'] = { dx = 0, dy = throwSpeed },
        ['left'] = { dx = -throwSpeed, dy = 0 },
        ['right'] = { dx = throwSpeed, dy = 0 }
    }

    local dx = directionsDelta[throwDirection].dx
    local dy = directionsDelta[throwDirection].dy

    self.dx = dx
    self.dy = dy
    self.throwDirection = throwDirection;

    --  handle adjusting the location of the item being thrown and when it can do damage
    if throwDirection == 'left' or throwDirection == 'right' then
        local padding = self.width * 1.2 -- a little space so it does not immediately do damage to player
        local time = (thrower.width + padding) / throwSpeed

        -- move it closer to chest level for a more realistic throw
        Timer.tween(time, {
            [self] = { y = self.y + (thrower.height / 2 + (self.height / 2)) },
        })
    end

    if throwDirection == 'down' then
        -- dont short change the throw by counting its distance crossing the body
        self.throwDistance = self.throwDistance + thrower.height
    end
end

-- modification of checkBoundaryCollision from class, not DRY too tired to refactor rn
function GameObject:checkBoundaryCollsion(dt)
    -- boundary checking on all sides, allowing us to avoid collision detection on tiles
    local velocity = self.dx + self.dy -- since we are throwing straight one of these deltas should always be 0
    local direction = 'down'

    -- we really only need to do this when the object is moving
    if velocity == 0 then
        return
    end

    -- get direction based on velocity vector
    if self.dx > 0 then
        direction = 'right'
    elseif self.dx < 0 then
        direction = 'left'
    elseif self.dy > 0 then
        direction = 'down'
    elseif self.dy < 0 then
        direction = 'up'
    end

    if direction == 'left' then
        local xNext = self.x - velocity * dt

        if xNext <= MAP_RENDER_OFFSET_X + TILE_SIZE then
            self.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.bumped = true
        end
    elseif direction == 'right' then
        local xNext = self.x + velocity * dt

        if xNext + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.width
            self.bumped = true
        end
    elseif direction == 'up' then
        local yNext = self.y - velocity * dt

        if yNext <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then
            self.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
            self.bumped = true
        end
    elseif direction == 'down' then
        local yNext = self.y + velocity * dt

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE)
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if yNext + self.height >= bottomEdge then
            self.y = bottomEdge - self.height
            self.bumped = true
        end
    end

    if self.bumped then
        self:onBreak()
    end
end

-- handle state change when an object gets broken
function GameObject:onBreak()
    self.state = 'broken'
    self.dx = 0
    self.dy = 0
    self.solid = false
    self.liftable = false
    self.damageAmount = 0
    self.canDamage = false
    self.thrower = nil

    gSounds['break']:stop()
    gSounds['break']:play()
end
