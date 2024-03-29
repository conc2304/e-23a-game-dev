--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1     -- all colors the same in this row
ALTERNATE = 2 -- alternate colors
SKIP = 3      -- skip every other block
NONE = 4      -- no blocks this row

LevelMaker = Class {}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(1, 5)

    -- randomly choose the number of columns, ensuring odd
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- highest possible spawned brick color in this level; ensure we
    -- don't go above 3
    local highestTier = math.min(3, math.floor(level / 5))

    -- highest color of the highest tier, no higher than 5
    local highestColor = math.min(5, level % 5 + 3)

    local highestTierBrickCount = 0;

    -- lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do
        -- whether we want to enable skipping for this row
        local skipPattern = math.random(1, 2) == 1 and true or false

        -- whether we want to enable alternating colors for this row
        local alternatePattern = math.random(1, 2) == 1 and true or false

        -- choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        -- used only when we want to skip a block, for skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        -- used only when we want to alternate a block, for alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false

        -- solid color we'll use if we're not skipping or alternating
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            -- if skipping is turned on and we're on a skip iteration...
            if skipPattern and skipFlag then
                -- turn skipping off for the next iteration
                skipFlag = not skipFlag

                -- Lua doesn't have a continue statement, so this is the workaround
                goto continue
            else
                -- flip the flag to true on an iteration we don't use it
                skipFlag = not skipFlag
            end

            -- x-coordinate
            local xPos =
                (x - 1)               -- decrement x by 1 because tables are 1-indexed, coords are 0
                * 32                  -- multiply by 32, the brick width
                + 8                   -- the screen should have 8 pixels of padding; we can fit 13 cols + 16 pixels total
                + (13 - numCols) * 16 -- left-side padding for when there are fewer than 13 columns
            -- y-coordinate
            local yPos = y * 16       -- just use y * 16, since we need top padding anyway

            local b = Brick(xPos, yPos)

            -- if we're alternating, figure out which color/tier we're on
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end


            -- if not alternating and we made it here, use the solid color/tier
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end

            -- if brick is of highest tier, the give it the power up ability randomly
            -- the lower the level, the higher ratio of powerups in the level
            if b.tier == highestTier then
                -- probability threshold inversely scales with the level number
                local threshold = 100 - (level * math.random(1, 2)) * 10
                threshold = math.min(threshold, 80) -- Ensure a no more than a 80% chance
                threshold = math.max(threshold, 10) -- Ensure at least a 10% chance

                -- power-up up the brick if the random chance is within the threshold
                if math.random(100) <= threshold then
                    b.hasPowerUp = true
                    b.powerUpType = math.random(PUP_MIN_INDEX, PUP_MAX_INDEX)
                end
            end

            -- make the some of the heighest tiered bricks have power ups

            table.insert(bricks, b)

            -- Lua's version of the 'continue' statement
            ::continue::
        end
    end

    -- each level should have increasingly more locked bricks
    local lockedBricksQty = math.random(level, level * 2)
    local lockedBricks = {}
    for i = 1, lockedBricksQty do
        local totalBricks = #bricks;
        local selectedIndex = math.random(1, totalBricks)

        --  make sure we arent doing the same brick as we have already done
        while ValueInArray(selectedIndex, lockedBricks) do
            selectedIndex = math.random(1, totalBricks)
        end

        -- add to lookup table
        table.insert(lockedBricks, selectedIndex)

        -- apply special lock features
        bricks[selectedIndex].specialType = SPECIAL_BRICK_LOCKED
        bricks[selectedIndex].color = 0
        bricks[selectedIndex].tier = 0
    end

    -- in the event we didn't generate any bricks, try again
    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end
