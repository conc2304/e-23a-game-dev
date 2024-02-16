--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class {}

BOARD_GRID_SIZE = { x = 8, y = 8 }

MIN_MATCH_QTY = 3

EASY_DIFFICULTY_COLOR_TILES = { 1, 5, 6, 9, 10, 13, 15, 18 }                       -- 8 hand picked easy to distinguish tiles
MEDIUM_DIFFICULTY_COLOR_TILES = ArrayMerge(EASY_DIFFICULTY_COLOR_TILES, { 3, 14 }) -- add more colors till we have them all
HARD_DIFFICULTY_COLOR_TILES = ArrayMerge(MEDIUM_DIFFICULTY_COLOR_TILES, { 7, 16 })
EXPERT_DIFFICULTY_COLOR_TILES = ArrayMerge(MEDIUM_DIFFICULTY_COLOR_TILES, { 2, 9 })

LEVEL_EASY = 'EASY'
LEVEL_MEDIUM = 'MEDIUM'
LEVEL_DIFFICULT = 'DIFFICULT'
LEVEL_EXPERT = 'EXPERT'

TILE_DIFFICULTY_COLOR_MAP = {
    [LEVEL_EASY] = EASY_DIFFICULTY_COLOR_TILES,
    [LEVEL_MEDIUM] = MEDIUM_DIFFICULTY_COLOR_TILES,
    [LEVEL_DIFFICULT] = HARD_DIFFICULTY_COLOR_TILES,
    [LEVEL_EXPERT] = EXPERT_DIFFICULTY_COLOR_TILES -- every color
}

TILE_DIFFICULTY_VARIETY_MAP = {
    [LEVEL_EASY] = 1,
    [LEVEL_MEDIUM] = math.floor(TILE_VARIETY_MAX / 3),
    [LEVEL_DIFFICULT] = math.floor(TILE_VARIETY_MAX / 2),
    [LEVEL_EXPERT] = TILE_VARIETY_MAX -- every color
}


function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.level = level or 1
    self.matches = {}
    self.difficulty = GetDifficultyByLevel(self.level)

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}


    for tileY = 1, BOARD_GRID_SIZE.y do
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, BOARD_GRID_SIZE.x do
            -- create a new tile at X,Y with a random color and variety
            local colorOptions = TILE_DIFFICULTY_COLOR_MAP[self.difficulty] -- a table of the colors
            local tileColor = colorOptions[math.random(#colorOptions)]
            local tileVarietyMaxIndex = TILE_DIFFICULTY_VARIETY_MAP[self.difficulty]

            local hasPup = math.random(1, 100) <= 10
            local powerupType = nil
            if hasPup then
                powerupType = math.random(#TILE_POWERUPS)
            end

            table.insert(self.tiles[tileY],
                Tile(tileX, tileY, tileColor, math.random(tileVarietyMaxIndex), powerupType))
        end
    end

    while self:calculateMatches(true) do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the
    last two haven't been a match.
]]
function Board:calculateMatches(isInitialization)
    isInitialization = isInitialization or false

    print("--calculateMatches--")
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, BOARD_GRID_SIZE.y do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1

        -- every horizontal tile
        for x = 2, BOARD_GRID_SIZE.x do
            local currentTile = self.tiles[y][x]


            -- if this is the same color as the one we're trying to match...
            if currentTile.color == colorToMatch then
                matchNum = matchNum + 1
            else
                -- set this as the new color we want to watch for
                colorToMatch = currentTile.color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= MIN_MATCH_QTY then
                    local match = {}

                    -- first check if we have an Oppenheimer Tile
                    -- then we will either add the individual tile, or the whole row
                    local isDestroyerOfRows = false;

                    for x2 = x - 1, x - matchNum, -1 do
                        if self.tiles[y][x2].powerupType == TILE_POWERUPS[TILE_PUP_DESTORY_ROW] then
                            isDestroyerOfRows = true
                            -- we dont need to know anything else, break out
                            break
                        end
                    end

                    -- For Horizontal Matches, if our match has a row destoyer
                    --   then add the entire row to this match table and thats its
                    if isDestroyerOfRows == true then
                        -- add entire row to matches
                        for xR = 0, BOARD_GRID_SIZE.x, 1 do
                            table.insert(match, self.tiles[y][xR])
                        end

                        -- dont play sound on initialization, its annoying and you don't see it happend anyway
                        if isInitialization ~= nil then
                            -- play row desctruction sound
                            gSounds['row-destruction']:stop()
                            gSounds['row-destruction']:play()
                        end
                    else
                        -- Match does not have a row destoyer, add individual tiles
                        -- go backwards from here by matchNum

                        for x2 = x - 1, x - matchNum, -1 do
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end
                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= MIN_MATCH_QTY then
            local match = {}

            -- check if row has row destoyer
            local isDestroyerOfRows = false;
            for x = BOARD_GRID_SIZE.x, BOARD_GRID_SIZE.x - matchNum + 1, -1 do
                if self.tiles[y][x].powerupType == TILE_POWERUPS[TILE_PUP_DESTORY_ROW] then
                    isDestroyerOfRows = true
                    -- we dont need to know anything else, break out
                    break
                end
            end

            -- For Horizontal Matches, if our match has a row destoyer
            --   then add the entire row to this match table and thats its
            if isDestroyerOfRows == true then
                -- add entire row to matches
                for xR = 0, BOARD_GRID_SIZE.x, 1 do
                    table.insert(match, self.tiles[y][xR])
                end

                -- dont play sound on initialization, its annoying and you don't see it happend anyway
                if isInitialization ~= nil then
                    -- play row desctruction sound
                    gSounds['row-destruction']:stop()
                    gSounds['row-destruction']:play()
                end
            else
                -- Match does not have a row destoyer, add individual tiles
                -- go backwards from end of last row by matchNum
                for x = BOARD_GRID_SIZE.x, BOARD_GRID_SIZE.x - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
        -- END Y LOOP
    end
    -- END HORIZONTAL CHECK

    -- vertical matches
    for x = 1, BOARD_GRID_SIZE.x do
        print("VERTICAL")
        local colorToMatch = self.tiles[1][x].color
        matchNum = 1

        -- every vertical tile
        for y = 2, BOARD_GRID_SIZE.y do
            local currentTile = self.tiles[y][x]

            if currentTile.color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = currentTile.color

                if matchNum >= MIN_MATCH_QTY then
                    local match = {}

                    -- first check if we have an Oppenheimer Tile
                    -- then we will either add the individual tile, or the whole row
                    local isDestroyerOfRows = false;
                    for y2 = y - 1, y - matchNum, -1 do
                        if self.tiles[y2][x].powerupType == TILE_POWERUPS[TILE_PUP_DESTORY_ROW] then
                            isDestroyerOfRows = true
                            break
                        end
                    end


                    -- For Vertical Matches, Destroy the shiny boy rows, but not the dull boy's rows
                    if isDestroyerOfRows == true then
                        for y2 = y - 1, y - matchNum, -1 do
                            -- tile is shiny boy, destroy that row
                            if self.tiles[y2][x].powerupType == TILE_POWERUPS[TILE_PUP_DESTORY_ROW] then
                                print("Vert X:", x, y2)
                                -- add entire row
                                for xR = 0, BOARD_GRID_SIZE.x, 1 do
                                    table.insert(match, self.tiles[y2][xR])
                                end
                            else
                                -- add single tile
                                table.insert(match, self.tiles[y2][x])
                            end
                        end

                        -- dont play sound on initialization, its annoying and you don't see it happend
                        if isInitialization ~= nil then
                            -- play row desctruction sound
                            gSounds['row-destruction']:stop()
                            gSounds['row-destruction']:play()
                        end
                    else
                        -- match set does not have row destoyer, add individual tiles
                        for y2 = y - 1, y - matchNum, -1 do
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= MIN_MATCH_QTY then
            local match = {}

            -- first check if we have an Oppenheimer Tile
            -- then we will either add the individual tile, or the whole row
            local isDestroyerOfRows = false;
            for y = BOARD_GRID_SIZE.y, BOARD_GRID_SIZE.y - matchNum + 1, -1 do
                if self.tiles[y][x].powerupType == TILE_POWERUPS[TILE_PUP_DESTORY_ROW] then
                    isDestroyerOfRows = true
                    break
                end
            end



            -- For Vertical Matches, Destroy the shiny boy rows, but not the dull boy's rows
            if isDestroyerOfRows == true then
                for y = BOARD_GRID_SIZE.y, BOARD_GRID_SIZE.y - matchNum + 1, -1 do
                    -- tile is shiny boy, destroy that row
                    if self.tiles[y][x].powerupType == TILE_POWERUPS[TILE_PUP_DESTORY_ROW] then
                        print("Vert X:", x, y)
                        -- add entire row
                        for xR = 0, BOARD_GRID_SIZE.x, 1 do
                            table.insert(match, self.tiles[y][xR])
                        end
                    else
                        -- add single tile
                        table.insert(match, self.tiles[y][x])
                    end
                end

                -- dont play sound on initialization, its annoying and you don't see it happend
                if isInitialization ~= nil then
                    -- play row desctruction sound
                    gSounds['row-destruction']:stop()
                    gSounds['row-destruction']:play()
                end
            else
                -- match set does not have row destoyer, add individual tiles
                -- go backwards from end of last row by matchNum
                for y = BOARD_GRID_SIZE.y, BOARD_GRID_SIZE.y - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end
    -- END VERTICAL CHECK LOOP

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

-- END CALCULATEMATCHES

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, BOARD_GRID_SIZE.x do
        local space = false
        local spaceY = 0

        local y = BOARD_GRID_SIZE.y
        while y >= 1 do
            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * TILE_HIGHT
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, BOARD_GRID_SIZE.x do
        for y = BOARD_GRID_SIZE.y, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then
                -- new tile with random color and variety

                -- get a random color that is within the colors selected for the difficulty
                local colorOptions = TILE_DIFFICULTY_COLOR_MAP[self.difficulty] -- a table of the colors
                local tileColor = colorOptions[math.random(#colorOptions)]
                local tileVarietyMaxIndex = TILE_DIFFICULTY_VARIETY_MAP[self.difficulty]

                local tile = Tile(x, y, tileColor, math.random(tileVarietyMaxIndex))
                tile.y = -TILE_HIGHT
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * TILE_HIGHT
                }
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end

-- function Board:update(dt)
--     for y = 1, #self.tiles do
--         for x = 1, #self.tiles[1] do
--             self.tiles[y][x]:update(dt)
--         end
--     end
-- end
