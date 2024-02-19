--[[
    GD50
    Match-3 Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions for writing Match-3.
]]

--[[
    Given an "atlas" (a texture with multiple sprites), generate all of the
    quads for the different tiles therein, divided into tables for each set
    of tiles, since each color has 6 varieties.
]]
function GenerateTileQuads(atlas)
    local tiles = {}

    local x = 0
    local y = 0

    local counter = 1

    -- 9 rows of tiles
    for row = 1, 9 do
        -- two sets of 6 cols, different tile varietes
        for i = 1, 2 do
            tiles[counter] = {}

            for col = 1, 6 do
                table.insert(tiles[counter], love.graphics.newQuad(
                    x, y, 32, 32, atlas:getDimensions()
                ))
                x = x + 32
            end

            counter = counter + 1
        end
        y = y + 32
        x = 0
    end

    return tiles
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

-- Stuff about this function
function IterateOverBoard(board, callback)
    for y, col_table in ipairs(board) do
        for x, tile in ipairs(col_table) do
            if callback ~= nil then
                local tilePos = { x = x, y = y }
                callback(tile, tilePos)
            end
        end
    end
end

function TableMerge(...)
    local arrays = { ... }
    local returnTable = {}

    for i, arr in ipairs(arrays) do
        if type(arr) == "table" then
            for _, value in ipairs(arr) do
                table.insert(returnTable, value)
            end
        else
            print(string.format("TableMerge expected a table at arg %d but received a %d.", i, type(arr)))
        end
    end

    return returnTable
end

-- currently just simplying level to difficulty range to just 1 level
-- but this allows for dynamic ranges
function GetDifficultyByLevel(level)
    if level >= 0 and level <= 1 then
        return LEVEL_EASY
    elseif level >= 2 and level <= 2 then
        return LEVEL_MEDIUM
    elseif level >= 3 and level <= 3 then
        return LEVEL_DIFFICULT
    else
        return LEVEL_EXPERT
    end
end

-- deprecated buy keeping around
-- revamped deep copy from :https://gist.github.com/tylerneylon/81333721109155b2d244
function DeepCopy(original)
    print("DeepCopy")
    local original_type = type(original)
    local copy
    if original_type == 'table' then
        copy = {}
        for original_key, original_value in next, original, nil do
            copy[DeepCopy(original_key)] = DeepCopy(original_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(original)))
    else -- number, string, boolean, etc dont have nesting to travers
        copy = original
    end
    return copy
end

-- deprecated but keeping around
function CheckPossibleMatches(boardOrig)
    print("--CheckPossibleMatches--")

    local possibleMatches = {}

    -- make a copy of the board that we can mutate it safely
    -- use Board class so taht we have access to cacluate matches
    -- clean out the initialized tiles
    local boardCopy = Board(VIRTUAL_WIDTH - 272, 16, 1) -- level doesnt matter

    -- doing a deep copy of the full self.board creates a stack overflow
    IterateOverBoard(boardOrig,
        -- add our real tiles to our copy of the board
        function(tile, tilePos)
            local x, y = tilePos.x, tilePos.y
            boardCopy.tiles[y][x] = {
                gridX = tile.gridX,
                gridY = tile.gridY,
                x = tile.x,
                y = tile.y,
                color = tile.color,
                variety = tile.variety,
            }
        end
    )

    local movingTile = nil
    local targetTile = nil

    local directions = { 'up', 'down', 'left', 'right' }
    local function callbackOuter(_, boardPosition)
        print("CALLBACK")
        -- bail out if we already have found 1 match
        if #possibleMatches > 0 then
            print("MATCH FOUND", #possibleMatches)
            for _, tile in pairs(possibleMatches[1]) do
                print("XY", tile.gridX, tile.gridY)
            end
            return
        end
        print("SEARCH ")

        local xA, yA = boardPosition.x, boardPosition.y

        local highlightedTile = boardCopy.tiles[yA][xA] -- stationary

        local boardHighlightY = highlightedTile.gridY   -- target that will move 1 in all direction from stationary
        local boardHighlightX = highlightedTile.gridX   -- target
        print("TILE A: ", xA, yA)

        -- move this tile in all of the available directions
        for _, dir in pairs(directions) do
            print("dir", dir)
            if dir == 'up' then
                boardHighlightY = math.max(1, boardHighlightY - 1)
            elseif dir == 'down' then
                boardHighlightY = math.min(BOARD_GRID_SIZE.y, boardHighlightY + 1)
            elseif dir == 'left' then
                boardHighlightX = math.max(1, boardHighlightX - 1)
            elseif dir == 'right' then
                boardHighlightX = math.min(BOARD_GRID_SIZE.x, boardHighlightX + 1)
            end

            local xB = boardHighlightX
            local yB = boardHighlightY


            if xA == xB and yA == yB then
                print("same tile, continueing: ", xA, yA, dir)
                goto continue
            end


            -- swap grid positions of tiles
            local tempX = highlightedTile.gridX -- the one first selected
            local tempY = highlightedTile.gridY

            local newTile = boardCopy.tiles[yB][xB] -- new tile selected to match

            print_r(newTile)
            highlightedTile.gridX = newTile.gridX
            highlightedTile.gridY = newTile.gridY
            newTile.gridX = tempX
            newTile.gridY = tempY

            -- swap tiles in the tiles table
            boardCopy.tiles[highlightedTile.gridY][highlightedTile.gridX] =
                highlightedTile

            boardCopy.tiles[newTile.gridY][newTile.gridX] = newTile

            -- possibleMatches = boardCopy:calculateMatches() or {}
            local results = boardCopy:calculateMatches() or {}

            possibleSwaps = results.possibleSwaps or {}

            movingTile = highlightedTile;
            targetTile = newTile
            if possibleSwaps ~= false and #possibleSwaps > 0 then
                print("Possible Match Found")
                return
            end
            -- if no matches undo the move and keep going

            tempX = highlightedTile.gridX
            tempY = highlightedTile.gridY

            highlightedTile.gridX = newTile.gridX
            highlightedTile.gridY = newTile.gridY
            newTile.gridX = tempX
            newTile.gridY = tempY
            boardCopy.tiles[highlightedTile.gridY][highlightedTile.gridX] = highlightedTile
            boardCopy.tiles[newTile.gridY][newTile.gridX] = newTile
            ::continue::
        end
    end


    IterateOverBoard(boardCopy.tiles, callbackOuter)


    print("END POSSIBLE CHECK")
    return {
        ['possibleMatches'] = possibleMatches,
        ['tile'] = movingTile,
        ['target'] = targetTile,
    }
end

function FindSwapMatch(tiles, x, y)
    local directions = {
        { dx = 0,  dy = -1 }, -- up
        { dx = 0,  dy = 1 },  -- down
        { dx = -1, dy = 0 },  -- left
        { dx = 1,  dy = 0 }   -- right
    }

    local function checkMatch(xA, yA, xB, yB)
        local tile = tiles[yA] and tiles[yA][xA]
        local swapTile = tiles[yB] and tiles[yB][xB]

        -- Simulate the swap for checking
        -- Swap current item with the simulated item position if they match the simulated swap positions
        local function getTile(cx, cy)
            if cx == xA and cy == yA then
                return swapTile
            elseif cx == xB and cy == yB then
                return tile
            else
                return tiles[cy] and tiles[cy][cx]
            end
        end

        -- check horizontal match
        if xA > 1 and xA < BOARD_GRID_SIZE.x then
            if getTile(xA - 1, yA).color == tile.color and getTile(xA + 1, yA).color == tile.color then
                return true
            end
        end
        -- check vertical match
        if yA > 1 and yA < BOARD_GRID_SIZE.y then
            if getTile(xA, yA - 1).color == tile.color and getTile(xA, yA + 1).color == tile.color then
                return true
            end
        end
        return false
    end
    -- END checkMatch

    for _, dir in ipairs(directions) do
        local swapX, swapY = x + dir.dx, y + dir.dy
        -- test the swap only if the target tile is in bounds
        if tiles[swapY] and tiles[swapY][swapX] then
            -- check for a match with a non mutating swap
            if checkMatch(x, y, swapX, swapY) then
                -- return tuple : true + positions of the items that would be swapped
                return true, { x = x, y = y },
                    { x = swapX, y = swapY }
            end
        end
    end

    return false -- no match found
end
