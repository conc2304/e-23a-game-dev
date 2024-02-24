--[[
    GD50
    Super Mario Bros. Remake


    -- LevelMaker Class --


    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]


LevelMaker = Class {}


OBJECT_KEY_ID = 'KEY'
OBJECT_LOCK_BLOCK_ID = 'LOCK_BLOCK'


function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    local jumpBlocksQty = 0

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end


    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end


            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2


                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    local bushX = (x - 1) * TILE_SIZE
                    local bushY = (4 - 1) * TILE_SIZE
                    SpawnBush(bushX, bushY, objects)
                end


                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil


                -- chance to generate bushes
            elseif math.random(8) == 1 then
                local bushX = (x - 1) * TILE_SIZE
                local bushY = (6 - 1) * TILE_SIZE
                SpawnBush(bushX, bushY, objects)
            end


            -- chance to spawn a block
            if math.random(5) == 1 then
                local blockX = (x - 1) * TILE_SIZE
                local blockY = (blockHeight - 1) * TILE_SIZE
                SpawnBlock(blockX, blockY, objects)
                jumpBlocksQty = jumpBlocksQty + 1
            end
        end
    end


    local map = TileMap(width, height)
    map.tiles = tiles


    local keyId = math.random(#LOCKED_BOX_COMBOS)
    AddKeysToBlocks(keyId, objects)
    AddLockBlock(keyId, map.tiles, objects)

    return GameLevel(entities, objects, map)
end

function SpawnBlock(x, y, objects)
    local jumpBlock = GameObject {
        texture = 'jump-blocks',
        x = x,
        y = y,
        width = 16,
        height = 16,

        -- make it a random variant
        frame = math.random(#JUMP_BLOCKS),
        collidable = true,
        hit = false,
        solid = true,
        onCollide = function(obj)
            local blockContentY = y - 4
            HandleBlockCollision(x, blockContentY, obj, objects)
        end
    }

    table.insert(objects, jumpBlock)
end

function SpawnLockedBlock(x, y, keyId, objects)
    local frameId = keyId + #LOCKED_BOX_COMBOS
    local lockBlock = GameObject {
        texture = 'key-blocks',
        x = x,
        y = y,
        width = TILE_SIZE,
        height = TILE_SIZE,
        frame = frameId, -- locked block of corresponding color is on the second row, so we add the number of color options to get us on the next row
        collidable = true,
        hit = false,
        solid = true,
        consumable = true,
        onCollide = function(obj, player, objRefKey)
            -- on block collision, destroy the block, then spawn a flag near the end
            local hasMatchingKey = player:hasKey(keyId)

            if not hasMatchingKey then
                gSounds['missing-key']:play()
                return
            end

            Timer.every(0.1, function()
                obj.frame = math.random(5, 8)
            end
            ):limit(6):finish(function()
                gSounds['lock-box-unlock']:play()
                table.remove(objects, objRefKey)
                -- spawn a flag near the end of the game
            end)
        end
    }
    table.insert(objects, lockBlock)
end

function HandleBlockCollision(x, y, obj, objects)
    -- function HandleBlockCollision(obj, x, blockHeight, objects)
    -- spawn a gem if we haven't already hit the block
    if not obj.hit then
        -- chance to spawn gem, not guaranteed
        if math.random(5) == 1 then
            local gemX = x
            local gemY = y
            local gemYFinish = y - TILE_SIZE + 4
            SpawnGem(gemX, gemY, gemYFinish, objects)
        end
        obj.hit = true
    end
    gSounds['empty-block']:play()
end

function SpawnGem(x, y, gemYFinish, objects)
    local gem = GameObject {
        texture = 'gems',
        x = x,
        y = y,
        width = 16,
        height = 16,
        frame = math.random(#GEMS),
        collidable = true,
        consumable = true,
        solid = false,

        -- gem has its own function to add to the player's score
        onConsume = function(player, object)
            gSounds['pickup']:play()
            player.score = player.score + 100
        end
    }

    -- make the gem move up from the block and play a sound
    Timer.tween(0.1, {
        [gem] = { y = gemYFinish }
    })
    gSounds['powerup-reveal']:play()


    table.insert(objects, gem)
end

function SpawnBush(x, y, objects)
    local bush =
        GameObject {
            texture = 'bushes',
            x = x,
            y = y,
            width = 16,
            height = 16,
            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
            collidable = false
        }


    table.insert(objects, bush)
end

function SpawnKey(x, y, keyId, objects)
    local key = GameObject {
        texture = 'key-blocks',
        x = x,
        y = y - 2,
        width = TILE_SIZE,
        height = TILE_SIZE,
        frame = keyId,
        collidable = true,
        consumable = true,
        solid = false,

        -- key has its own function to add to the player's score and to add to inventory
        onConsume = function(player, self)
            gSounds['pickup-key']:play()
            player.score = player.score + 150

            -- lets move this key to the object items collection for rendering
            player.keys[keyId] = keyId
        end
    }

    -- animate in over collided block
    Timer.tween(0.1, {
        [key] = { y = key.y - TILE_SIZE + 4 }
    })

    gSounds['powerup-reveal']:play()

    table.insert(objects, key)
end

function AddKeysToBlocks(keyId, objects)
    -- lets have 3 chances for a key since some of these blocks are unreachable
    local blocksToGiveKeys = {
        math.floor(#objects * 0.30), -- one at the 30% mark,
        math.floor(#objects * 0.60), -- one at the 60% mark,
        #objects - 1,                -- the secdond to last brick
    }

    for _, objIndex in pairs(blocksToGiveKeys) do
        -- we only care about jump blocks
        if objects[objIndex].texture == 'jump-blocks' then
            -- update the block to spawn a key on hit
            objects[objIndex].onCollide = function(obj)
                if not obj.hit then
                    local keyX = objects[objIndex].x
                    local keyY = objects[objIndex].y
                    -- local lockColorId = math.random(#LOCKED_BOX_COMBOS)

                    SpawnKey(keyX, keyY, keyId, objects)
                    obj.hit = true
                end
                gSounds['empty-block']:play()
            end
        end
    end
end

function AddLockBlock(keyId, tiles, objects)
    -- put a lock block randomly over the ground between the 70%-100% of the game completion
    local levelWidth = #tiles[1]

    local groundPos = GetGroundBetweenXRange(math.floor(levelWidth * 0.7), levelWidth, tiles)
    local blockHeight = 3
    local x, y = groundPos.x, groundPos.y
    SpawnLockedBlock(x, y - (blockHeight * TILE_SIZE), keyId, objects)
end
