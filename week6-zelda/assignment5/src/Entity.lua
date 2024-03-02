--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Entity = Class {}

function Entity:init(def)
    -- in top-down games, there are four directions instead of two
    self.direction = 'down'

    self.animations = self:createAnimations(def.animations)
    self.type = def.type
    -- dimensions
    self.x = def.x
    self.y = def.y
    self.width = def.width
    self.height = def.height

    -- drawing offsets for padded sprites
    self.offsetX = def.offsetX or 0
    self.offsetY = def.offsetY or 0

    self.walkSpeed = def.walkSpeed

    self.health = def.health
    self.probOfExtraLife = def.probOfExtraLife or 0

    -- flags for flashing the entity when hit
    self.invulnerable = false
    self.invulnerableDuration = 0
    self.invulnerableTimer = 0

    -- like a hurtbox, but for ablility to lift things
    self.liftRange = def.liftRange or 4
    self.liftBox = self:getLiftBox(self.direction, self.liftRange)
    self.liftedItem = nil
    self.liftedItemKey = nil

    -- timer for turning transparency on and off, flashing
    self.flashTimer = 0

    self.dead = false
end

function Entity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture or 'entities',
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end

--[[
    AABB with some slight shrinkage of the box on the top side for perspective.
]]
function Entity:collides(target)
    return Collides(self, target)
end

function Entity:damage(dmg)
    self.health = self.health - dmg
end

-- store the object and the key, in case we need to delete iteme later
function Entity:onLift(object, key)
    object:onLifted()
    self.liftedItem = object
    self.liftedItemKey = key
end

function Entity:goInvulnerable(duration)
    self.invulnerable = true
    self.invulnerableDuration = duration
end

function Entity:changeState(name)
    self.stateMachine:change(name)
end

function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

function Entity:update(dt)
    if self.invulnerable then
        self.flashTimer = self.flashTimer + dt
        self.invulnerableTimer = self.invulnerableTimer + dt

        if self.invulnerableTimer > self.invulnerableDuration then
            self.invulnerable = false
            self.invulnerableTimer = 0
            self.invulnerableDuration = 0
            self.flashTimer = 0
        end
    end

    self.stateMachine:update(dt)

    if self.currentAnimation then
        self.currentAnimation:update(dt)
    end

    if self.liftedItem ~= nil then
        -- position lifted item centered over entity head
        -- local itemWidth = self.liftedItem.width
        self.liftedItem.x = self.x + ((self.liftedItem.width - self.width) / 2)
        self.liftedItem.y = self.y - self.liftedItem.height
    end

    self.liftBox = self:getLiftBox(self.direction, self.liftRange)
end

function Entity:processAI(params, dt)
    self.stateMachine:processAI(params, dt)
end

function Entity:render(adjacentOffsetX, adjacentOffsetY)
    -- draw sprite slightly transparent if invulnerable every 0.04 seconds
    if self.invulnerable and self.flashTimer > 0.06 then
        self.flashTimer = 0
        love.graphics.setColor(1, 1, 1, 64 / 255)
    end

    self.x, self.y = self.x + (adjacentOffsetX or 0), self.y + (adjacentOffsetY or 0)
    -- if self.stateMachine
    self.stateMachine:render()
    love.graphics.setColor(1, 1, 1, 1)
    self.x, self.y = self.x - (adjacentOffsetX or 0), self.y - (adjacentOffsetY or 0)


    love.graphics.setColor(255, 0, 255, 255)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.rectangle('line', self.liftBox.x, self.liftBox.y,
        self.liftBox.width, self.liftBox.height)
    love.graphics.setColor(255, 255, 255, 255)
end

function Entity:onDeath(gameObjects)
    self.dead = true
    -- spawn an extra life to pick up
    local chance = math.random(POWER_UP_PROB_MAX)
    if chance < self.probOfExtraLife then return end

    -- use object def and then add in a random drop position
    local lifeDef = GAME_OBJECT_DEFS['life']
    local lifePos = GetRandomInGameXY()

    local extraLife = GameObject(lifeDef, lifePos.x, lifePos.y)

    table.insert(gameObjects, extraLife)
end

-- check if our lift box collides with an liftable object and then lift bro
function Entity:lift(objects)
    if not objects then return false end

    for key, object in pairs(objects) do
        if object.liftable and Collides(self.liftBox, object) then
            self:onLift(object, key)
            return true
        end
    end
    return false
end

function Entity:dropItem()
    -- put object back infront of entity at their feet
    local direction = self.direction;
    local object = self.liftedItem
    local x, y

    if not object then return end

    -- TODO handle not dropping in into a wall - but out of scope for homework
    local offset = 0 -- 0 seems like it works here, but leaving here bc it could be useful for other things
    if direction == 'left' then
        x = self.x - object.width - offset
        y = self.y + (math.abs(object.height - self.height))
    elseif direction == 'right' then
        x = self.x + object.width + offset
        y = self.y + (math.abs(object.height - self.height))
    elseif direction == 'up' then
        y = self.y - object.height - offset
        x = self.x
    else
        y = self.y + self.height + offset
        x = self.x
    end

    object:onRelease(x, y)

    ::continue::
    self.liftedItem = nil
    self.liftedItemKey = nil
end

function Entity:handleLiftToggle(objects)
    if self.liftedItem == nil then
        self:lift(objects)
    else
        self:dropItem()
    end
end

-- make an area in which items are liftable
function Entity:getLiftBox(direction, range)
    local liftBoxX, liftBoxY, liftBoxWidth, liftBoxHeight
    local pickupRange = range or 4
    -- liftBox should be infront of player
    if direction == 'left' then
        liftBoxWidth = pickupRange
        liftBoxHeight = self.height
        liftBoxX = self.x - liftBoxWidth
        liftBoxY = self.y
    elseif direction == 'right' then
        liftBoxWidth = pickupRange
        liftBoxHeight = self.height
        liftBoxX = self.x + self.width
        liftBoxY = self.y
    elseif direction == 'up' then
        liftBoxWidth = self.width
        liftBoxHeight = pickupRange
        liftBoxX = self.x
        liftBoxY = self.y - liftBoxHeight
    else
        liftBoxWidth = self.width
        liftBoxHeight = pickupRange
        liftBoxX = self.x
        liftBoxY = self.y + self.height
    end


    local liftBox = Hitbox(liftBoxX, liftBoxY, liftBoxWidth, liftBoxHeight)

    self.liftBox = liftBox
    return liftBox
end

function Entity:throwItem()
    if self.liftedItem == nil then return end

    self:goInvulnerable(1) -- prevent player from being hit by pot

    local throwDirection = self.direction
    local throwSpeed = 150

    self.liftedItem:onThrown(throwSpeed, throwDirection)
    self.liftedItem = nil
    self.liftedItemKey = nil
end
