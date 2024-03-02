--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class {}

DOOR_LOCATIONS = { 'top', 'bottom', 'left', 'right' }

function Room:init(player)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    self.tiles = {}
    self:generateWallsAndFloors()

    -- entities in the room
    self.entities = {}
    self:generateEntities()

    -- reference to player for collisions, etc.
    self.player = player

    -- game objects in the room
    -- depends on player already having been created so we dont spawn
    --   a game with entities inside of objects
    self.objects = {}
    self:generateObjects()

    -- doorways that lead to other dungeon rooms
    self.doorways = {}

    for _, location in ipairs(DOOR_LOCATIONS) do
        table.insert(self.doorways, Doorway(location, false, self))
    end

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = { 'skeleton', 'slime', 'bat', 'ghost', 'spider' }

    for i = 1, 10 do
        local type = types[math.random(#types)]

        local entityPos = GetRandomInGameXY()
        local entityDef = ENTITY_DEFS[type]
        entityDef.type = type
        entityDef.x = entityPos.x
        entityDef.y = entityPos.y

        table.insert(self.entities, Entity(entityDef))

        local dungeon = self
        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i], dungeon) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }

        self.entities[i]:changeState('walk')
    end
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    local switchPos = GetRandomInGameXY()
    local switch = GameObject(
        GAME_OBJECT_DEFS['switch'],
        switchPos.x,
        switchPos.y
    )

    -- add to list of objects in scene (only one switch for now)
    table.insert(self.objects, switch)

    self:generatePots(switch, self.objects)
end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER

                -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end

            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

function Room:update(dt)
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    self.player:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        -- skip to end if entity is dead
        if entity.dead then goto continue end

        if entity.health <= 0 then
            -- do onDeath from the game if died
            if entity.onDeath ~= nil and not entity.dead then
                entity:onDeath(self.objects)
                goto continue
            end
        end

        for _, obj in ipairs(self.objects) do
            local collides = entity:collides(obj)
            if obj.solid and collides then
                entity.bumped = true
            end

            -- this is where we handle pots that are thrown,
            -- or any object that can do damage
            if obj.canDamage and obj.thrower ~= entity and collides then
                print_r(entity, 1)
                entity:damage(obj.damageAmount)
                obj:onBreak()
            end
        end

        entity:processAI({ room = self }, dt)
        entity:update(dt)

        -- collision between the player and entities in the room
        if self.player:collides(entity) and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)

            if self.player.health == 0 then
                gStateMachine:change('game-over')
            end
        end

        ::continue::
    end


    for k, object in pairs(self.objects) do
        object:update(dt)

        -- trigger collision callback on object
        if self.player:collides(object) then
            if object.solid then self.player.bumped = true end
            object:onCollide(self, k)
        end
    end
end

function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX,
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)

        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)

        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)

        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)

    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()

    --
    -- DEBUG DRAWING OF STENCIL RECTANGLES
    --

    -- love.graphics.setColor(255, 0, 0, 100)

    -- -- left
    -- love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
    -- TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- -- right
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
    --     MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- -- top
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)

    -- --bottom
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)

    -- love.graphics.setColor(255, 255, 255, 255)
end

function Room:generatePots(switch, entities)
    -- generate some pots and put them in places
    local potsQty = math.random(3, 10)

    for i = 1, potsQty do
        local potPos = GetRandomInGameXY()

        -- test collision instead of x and y so objects dont get stuck inside of solids
        local collisionPadding = 10;
        local testPot = {
            x = potPos.x - (collisionPadding / 2),
            y = potPos.y - (collisionPadding / 2),
            width = GAME_OBJECT_DEFS['pot'].width + collisionPadding,
            height = GAME_OBJECT_DEFS['pot'].height + collisionPadding
        }

        local objectOnPLayer = self.player:collides(testPot)
        local objectOnSwitch = Collides(testPot, switch)
        local objectOnEntity = true

        -- make sure we dont put a pot on top of the switch
        while objectOnSwitch or objectOnEntity or objectOnPLayer do
            potPos = GetRandomInGameXY()

            testPot.x = potPos.x
            testPot.y = potPos.y

            objectOnSwitch = not not Collides(testPot, switch)
            objectOnPLayer = Collides(testPot, self.player)

            for _, entity in pairs(entities) do
                local collides = Collides(testPot, entity)
                objectOnEntity = not not collides
                if objectOnEntity then break end
            end
        end


        local pot = GameObject(
            GAME_OBJECT_DEFS['pot'],
            potPos.x,
            potPos.y
        )
        table.insert(self.objects, pot)
    end
end
