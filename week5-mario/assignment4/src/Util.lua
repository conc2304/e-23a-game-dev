--[[
    GD50
    Super Mario Bros. Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions for writing Match-3.
]]

--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                    tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

function GenerateFlagPoleQuads(atlas, flagPoleWidth, flagPoleHeight)
    return table.slice(GenerateQuads(atlas, flagPoleWidth, flagPoleHeight), 1, 6)
end

function GenerateFlagQuads(atlas, flagWidth, flagHeight)
    local flagPoleWidth = 16
    local totalFlagPoleTypes = 6

    local xOffset = flagPoleWidth * totalFlagPoleTypes
    local yOffset = 0

    local quads = {}
    local totalFlagTypes = 4
    local totalFlagFrames = 3
    for col = 1, totalFlagTypes do
        for row = 1, totalFlagFrames do
            local x = xOffset + ((row - 1) * flagWidth)
            local y = yOffset + ((col - 1) * flagHeight)

            table.insert(quads, love.graphics.newQuad(x, y, flagWidth, flagHeight, atlas:getDimensions()))
        end
    end

    return quads
end

function GenerateFlagsetQuads(atlas)
    --     ['flag-poles'] = GenerateFlagPoleQuads(gTextures['flags'], 16, 48),
    local poleW, poleH = 16, 48
    local poleVarieties = 6
    local flagW, flagH = 16, 16

    -- add flag poles to quad sheet
    local quads = table.slice(GenerateQuads(atlas, poleW, poleH), 1, poleVarieties)

    local xOffset = poleW * poleVarieties
    local yOffset = 0

    local totalFlagTypes = 4
    local totalFlagFrames = 3
    -- add flags to quad sheet
    for col = 1, totalFlagTypes do
        for row = 1, totalFlagFrames do
            local x = xOffset + ((row - 1) * flagW)
            local y = yOffset + ((col - 1) * flagH)

            table.insert(quads, love.graphics.newQuad(x, y, flagW, flagH, atlas:getDimensions()))
        end
    end

    return quads
end

function GenerateFlagSets(quads, setsX, setsY, sizeX, sizeY)

end

--[[
    Divides quads we've generated via slicing our tile sheet into separate tile sets.
]]
function GenerateTileSets(quads, setsX, setsY, sizeX, sizeY)
    local tilesets = {}
    local tableCounter = 0
    local sheetWidth = setsX * sizeX
    local sheetHeight = setsY * sizeY

    -- for each tile set on the X and Y
    for tilesetY = 1, setsY do
        for tilesetX = 1, setsX do
            -- tileset table
            table.insert(tilesets, {})
            tableCounter = tableCounter + 1

            for y = sizeY * (tilesetY - 1) + 1, sizeY * (tilesetY - 1) + 1 + sizeY do
                for x = sizeX * (tilesetX - 1) + 1, sizeX * (tilesetX - 1) + 1 + sizeX do
                    table.insert(tilesets[tableCounter], quads[sheetWidth * (y - 1) + x])
                end
            end
        end
    end

    return tilesets
end

--[[
    Recursive table printing function.
    https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
]]
function print_r(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end
    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

function GetFirstGroundX(tileMap)
    for x = 1, tileMap.width do
        for y = 1, tileMap.height do
            if tileMap.tiles[y][x].id == TILE_ID_GROUND then
                --  we have the first sighting of land
                return (x - 1) * TILE_SIZE
            end
        end
    end
end

function GetLastGroundX(tiles)
    local tilesWide = #tiles[1]
    local tileTall = #tiles
    for x = tilesWide, 1, -1 do
        for y = 1, tileTall do
            if tiles.tiles[y][x].id == TILE_ID_GROUND then
                --  we have the last sighting of land
                return { x = (x - 1) * TILE_SIZE, y = y }
            end
        end
    end
    -- we should have found someting, but if not just retun the 4th to last tile space at our 6th height
    return {
        x = (#tiles[0] - 4) * TILE_SIZE,
        y = 6 * TILE_SIZE
    }
end

function GetGroundBetweenXRange(xStart, xEnd, tiles)
    local tilesWide = #tiles[1]
    local tileTall = #tiles
    -- if our given range is not valid bail out with the last Ground Available
    if xStart < 1 or xEnd > tilesWide then return GetLastGroundX(tiles) end


    -- we dont want to forever get stuck finding a random position, so create a bail out system
    local maxAttempts = xEnd - xStart;
    local totalAttempts = 0
    while totalAttempts < maxAttempts do
        local randomX = math.random(xStart, xEnd)
        totalAttempts = totalAttempts + 1
        for y = 1, tileTall, 1 do
            -- print(randomX, y)
            if tiles[y][randomX].id == TILE_ID_GROUND then
                --  we have the first sighting of land
                return {
                    x = (randomX - 1) * TILE_SIZE,
                    y = (y - 1) * TILE_SIZE
                }
            end
        end
    end

    -- if searching randomly didnt work then just go from finish to start to find ground
    return GetLastGroundX(tiles)
end

--[[
    Utility function for slicing tables, a la Python.

    https://stackoverflow.com/questions/24821045/does-lua-have-something-like-pythons-slice
]]
function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end

    return sliced
end
