--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class {}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

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
                -- SpawnBlock(x, blockHeight, objects)
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end

-- function SpawnBlock(x, blockHeight, objects)
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
            -- TODO NEED TO UPDATE this to not use block height
            local blockContentY = y - 4
            HandleBlockCollision(x, blockContentY, obj, objects)
            -- HandleBlockCollision(obj, x, blockHeight, objects)
        end
    }

    table.insert(objects, jumpBlock)
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
