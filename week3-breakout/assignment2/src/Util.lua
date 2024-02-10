--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions for writing games.
]]

ROW_HEIGHT = 16

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

--[[
    This function is specifically made to piece out the bricks from the
    sprite sheet. Since the sprite sheet has non-uniform sprites within,
    we have to return a subset of GenerateQuads.
]]
function GenerateQuadsBricks(atlas)
    return table.slice(GenerateQuads(atlas, 32, 16), 1, 21)
end

--[[
    This function is specifically made to piece out the paddles from the
    sprite sheet. For this, we have to piece out the paddles a little more
    manually, since they are all different sizes.
]]
function GenerateQuadsPaddles(atlas)
    local x = 0
    local y = 64

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        -- smallest
        quads[counter] = love.graphics.newQuad(x, y, PADDLE_SM_WIDTH, PADDLE_DEFAULT_HEIGHT,
            atlas:getDimensions())
        counter = counter + 1
        -- medium
        quads[counter] = love.graphics.newQuad(x + 32, y, PADDLE_MD_WIDTH, PADDLE_DEFAULT_HEIGHT,
            atlas:getDimensions())
        counter = counter + 1
        -- large
        quads[counter] = love.graphics.newQuad(x + 96, y, PADDLE_LG_WIDTH, PADDLE_DEFAULT_HEIGHT,
            atlas:getDimensions())
        counter = counter + 1
        -- huge
        quads[counter] = love.graphics.newQuad(x, y + 16, PADDLE_XL_WIDTH, PADDLE_DEFAULT_HEIGHT,
            atlas:getDimensions())
        counter = counter + 1

        -- prepare X and Y for the next set of paddles
        x = 0
        y = y + 32
    end

    return quads
end

--[[
    This function is specifically made to piece out the balls from the
    sprite sheet. For this, we have to piece out the balls a little more
    manually, since they are in an awkward part of the sheet and small.
]]
function GenerateQuadsBalls(atlas)
    local x = 96
    local y = 48

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    x = 96
    y = 56

    for i = 0, 2 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    return quads
end

function GenerateQuadPowerUps(atlas)
    local h = PUP_WIDTH
    local w = PUP_HEIGHT
    local powerUpsQty = 10
    local powerUpRow = 13

    local x = 0
    local y = (powerUpRow * ROW_HEIGHT) - ROW_HEIGHT

    local quads = {}
    local counter = 1


    -- power ups are located on the 13th row of the atlas

    for i = 1, powerUpsQty do
        quads[counter] = love.graphics.newQuad(x, y, w, h, atlas:getDimensions())
        x = x + w
        counter = counter + 1
    end

    return quads
end

--[[
    This function is specifically made to piece out the key brick from the
    sprite sheet. ]]
function GenerateQuadLockedBrick(atlas)
    local rowIndex = 4
    local x = atlas:getWidth() - BRICK_WIDTH
    local y = (rowIndex * ROW_HEIGHT) - ROW_HEIGHT

    return {
        [SPECIAL_BRICK_LOCKED] = love.graphics.newQuad(x, y, BRICK_WIDTH, BRICK_HEIGHT, atlas:getDimensions()),
        [SPECIAL_BRICK_UNLOCKED] = table.slice(GenerateQuads(atlas, 32, 16), 21, 21)[1]
    }
end

function Collides(a, target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if a == nil or a.x == nil or a.y == nil or a.width == nil or a.height == nil then
        print("Warning - Invalid Collision Object: a")
        return
    end
    if target == nil or target.x == nil or target.y == nil or target.width == nil or target.height == nil then
        print("Warning - Invalid Collision Object: target")
        return
    end
    if a.x > target.x + target.width or target.x > a.x + a.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if a.y > target.y + target.height or target.y > a.y + a.height then
        return false
    end

    -- if the above aren't true, they're overlapping
    return true
end

function ValueInArray(value, array)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end
