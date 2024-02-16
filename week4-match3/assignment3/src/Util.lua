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
    for _, col_table in ipairs(board) do
        for _, tile in ipairs(col_table) do
            if callback ~= nil then
                callback(tile)
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
