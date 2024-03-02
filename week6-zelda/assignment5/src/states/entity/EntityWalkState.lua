--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

EntityWalkState = Class { __includes = BaseState }

function EntityWalkState:init(entity, dungeon)
    self.entity = entity

    self.entity:changeAnimation('walk-down')

    self.dungeon = dungeon

    -- used for AI control
    self.moveDuration = 0
    self.movementTimer = 0

    -- keeps track of whether we just hit a wall
    self.bumped = false
end

function EntityWalkState:update(dt)
    -- assume we didn't hit a wall
    self.bumped = false

    self:checkBoundaryCollsion(dt)
    self:checkObjectCollisions(dt)
end

function EntityWalkState:processAI(params, dt)
    local room = params.room
    local directions = { 'left', 'right', 'up', 'down' }

    if self.moveDuration == 0 or self.bumped then
        -- set an initial move duration and direction
        self.moveDuration = math.random(5)
        self.entity.direction = directions[math.random(#directions)]
        self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
    elseif self.movementTimer > self.moveDuration then
        self.movementTimer = 0

        -- chance to go idle
        if math.random(3) == 1 then
            self.entity:changeState('idle')
        else
            self.moveDuration = math.random(5)
            self.entity.direction = directions[math.random(#directions)]
            self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
        end
    end

    self.movementTimer = self.movementTimer + dt
end

function EntityWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    -- debug code
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end

function EntityWalkState:checkBoundaryCollsion(dt)
    -- boundary checking on all sides, allowing us to avoid collision detection on tiles
    if self.entity.direction == 'left' then
        self.entity.x = self.entity.x - self.entity.walkSpeed * dt

        if self.entity.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then
            self.entity.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.bumped = true
        end
    elseif self.entity.direction == 'right' then
        self.entity.x = self.entity.x + self.entity.walkSpeed * dt

        if self.entity.x + self.entity.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.entity.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.entity.width
            self.bumped = true
        end
    elseif self.entity.direction == 'up' then
        self.entity.y = self.entity.y - self.entity.walkSpeed * dt

        if self.entity.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2 then
            self.entity.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2
            self.bumped = true
        end
    elseif self.entity.direction == 'down' then
        self.entity.y = self.entity.y + self.entity.walkSpeed * dt

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE)
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.entity.y + self.entity.height >= bottomEdge then
            self.entity.y = bottomEdge - self.entity.height
            self.bumped = true
        end
    end
end

-- check for collision with solid objects and adjust entities position on collision
function EntityWalkState:checkObjectCollisions(dt)
    -- depending on who (entity vs. player) is making this call
    -- the access to the dungeon object differs, but we just need to objects
    local dungeon = self.dungeon.currentRoom or self.dungeon

    if dungeon == nil or dungeon.objects == nil then return {} end

    -- check for collision with solid game objects
    for _, object in pairs(dungeon.objects) do
        if object.solid and self.entity:collides(object) then
            -- set bump to true mainly for ai entities
            self.bumped = true

            -- readjust entity position
            if self.entity.direction == 'left' then
                self.entity.x = object.x + self.entity.width + (self.entity.walkSpeed * dt)
            elseif self.entity.direction == 'right' then
                self.entity.x = object.x - self.entity.width - (self.entity.walkSpeed * dt)
            elseif self.entity.direction == 'up' then
                -- we are allowing some overlap hereby so that it looks like there feet are at the base of the object
                self.entity.y = self.entity.y + (self.entity.walkSpeed * dt)
            elseif self.entity.direction == 'down' then
                self.entity.y = object.y - self.entity.height - (self.entity.walkSpeed * dt)
            end
        end
    end
end
