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
    self.lifted = def.lifted or false
    self.canDamage = def.canCamage or false

    self.dx = 0
    self.dy = 0
    self.throwDistance = def.throwDistance or 0

    self.damageAmount = def.damageAmount or 0

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height
    self.distanceThrown = 0



    -- default empty collision callback
    self.onCollide = def.onCollide or function() end
end

function GameObject:update(dt)
    if not self.liftable then return end

    self.distanceThrown = self.distanceThrown + math.abs((self.dx * dt) + (self.dy * dt))
    self.x = self.x + (self.dx * dt)
    self.y = self.y + (self.dy * dt)

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

function GameObject:onThrown(throwSpeed, throwDirection)
    self.canDamage = true
    self.solid = true
    local directionsDelta = {
        ['up'] = { dx = 0, dy = -throwSpeed },  -- up
        ['down'] = { dx = 0, dy = throwSpeed }, -- down
        ['left'] = { dx = -throwSpeed, dy = 0 },
        ['right'] = { dx = throwSpeed, dy = 0 }
    }

    local dx = directionsDelta[throwDirection].dx
    local dy = directionsDelta[throwDirection].dy

    self.dx = dx
    self.dy = dy
    self.throwDirection = throwDirection;

    if throwDirection == 'left' or throwDirection == 'right' then
        -- move it lower
        Timer.tween(0.01, {
            [self] = { y = self.y + 10 },
        })
    end
end

function GameObject:checkBoundaryCollsion(dt)
    -- boundary checking on all sides, allowing us to avoid collision detection on tiles
    local velocity = self.dx + self.dy -- since we are throwing straight one of these deltas should always be 0

    if self.direction == 'left' then
        self.x = self.x - velocity * dt

        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then
            self.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.bumped = true
        end
    elseif self.direction == 'right' then
        self.x = self.x + velocity * dt

        if self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.width
            self.bumped = true
        end
    elseif self.direction == 'up' then
        self.y = self.y - velocity * dt

        if self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then
            self.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
            self.bumped = true
        end
    elseif self.direction == 'down' then
        self.y = self.y + velocity * dt

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE)
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.y + self.height >= bottomEdge then
            self.y = bottomEdge - self.height
            self.bumped = true
        end
    end

    if self.bumped then
        self:onBreak()
    end
end

function GameObject:onBreak()
    self.state = 'broken'
    self.dx = 0
    self.dy = 0
    self.solid = false
    self.liftable = false
    self.damageAmount = 0
end
