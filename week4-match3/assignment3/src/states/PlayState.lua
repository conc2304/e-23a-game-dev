--[[
    GD50
    Match-3 Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    State in which we can actually play, moving around a grid cursor that
    can swap two tiles; when two tiles make a legal swap (a swap that results
    in a valid match), perform the swap and destroy all matched tiles, adding
    their values to the player's point score. The player can continue playing
    until they exceed the number of points needed to get to the next level
    or until the time runs out, at which point they are brought back to the
    main menu or the score entry menu if they made the top 10.
]]

PlayState = Class { __includes = BaseState }

function PlayState:init()
    -- start our transition alpha at full, so we fade in
    self.transitionAlpha = 1

    -- position in the grid which we're highlighting
    self.boardHighlightX = 1
    self.boardHighlightY = 1

    -- timer used to switch the highlight rect's color
    self.rectHighlighted = false

    -- flag to show whether we're able to process input (not swapping or clearing)
    self.canInput = true

    -- tile we're currently highlighting (preparing to swap)
    self.highlightedTile = nil

    self.score = 0
    self.timer = 60

    self.possibleSwaps = {}

    -- set our Timer class to turn cursor highlight on and off
    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    -- subtract 1 from timer every second
    Timer.every(1, function()
        self.timer = self.timer - 1

        -- play warning sound on timer if we get low
        if self.timer <= 5 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)
    -- grab level # from the params we're passed
    self.level = params.level

    -- spawn a board and place it toward the right
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16, self.level)

    -- grab score from params if it was passed
    self.score = params.score or 0

    -- score we have to reach to get to the next level
    self.scoreGoal = self.level * 1.25 * 1000
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- go back to start if time runs out
    if self.timer <= 0 then
        -- clear timers from prior PlayStates
        Timer.clear()

        gSounds['game-over']:play()

        gStateMachine:change('game-over', {
            score = self.score
        })
    end

    -- go to next level if we surpass score goal
    if self.score >= self.scoreGoal then
        -- clear timers from prior PlayStates
        -- always clear before you change state, else next state's timers
        -- will also clear!
        Timer.clear()

        gSounds['next-level']:play()

        -- change to begin game state with new level (incremented)
        gStateMachine:change('begin-game', {
            level = self.level + 1,
            score = self.score
        })
    end

    -- monolith
    if self.canInput then
        -- move cursor around based on bounds of grid, playing sounds
        if love.keyboard.wasPressed('up') then
            self.boardHighlightY = math.max(1, self.boardHighlightY - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('down') then
            self.boardHighlightY = math.min(BOARD_GRID_SIZE.y, self.boardHighlightY + 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('left') then
            self.boardHighlightX = math.max(1, self.boardHighlightX - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('right') then
            self.boardHighlightX = math.min(BOARD_GRID_SIZE.x, self.boardHighlightX + 1)
            gSounds['select']:play()
        end

        -- if we've pressed enter, to select or deselect a tile...
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            -- if same tile as currently highlighted, deselect
            local x = self.boardHighlightX
            local y = self.boardHighlightY

            -- if nothing is highlighted, highlight current tile
            if not self.highlightedTile then
                self.highlightedTile = self.board.tiles[y][x]

                -- if we select the position already highlighted, remove highlight
            elseif self.highlightedTile == self.board.tiles[y][x] then
                self.highlightedTile = nil

                -- if the difference between X and Y combined of this highlighted tile
                -- vs the previous is not equal to 1, also remove highlight
            elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
                gSounds['error']:play()
                self.highlightedTile = nil
            else
                -- swap grid positions of tiles
                local tempX = self.highlightedTile.gridX -- the one first selected
                local tempY = self.highlightedTile.gridY

                local newTile = self.board.tiles[y][x] -- new tile selected to match

                self.highlightedTile.gridX = newTile.gridX
                self.highlightedTile.gridY = newTile.gridY
                newTile.gridX = tempX
                newTile.gridY = tempY

                -- swap tiles in the tiles table
                self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] =
                    self.highlightedTile

                self.board.tiles[newTile.gridY][newTile.gridX] = newTile

                -- tween coordinates between the two so they swap
                Timer.tween(0.1, {
                    [self.highlightedTile] = { x = newTile.x, y = newTile.y },
                    [newTile] = { x = self.highlightedTile.x, y = self.highlightedTile.y }
                })

                -- once the swap is finished, we can tween falling blocks as needed
                    :finish(
                        function()
                            -- post user swap : check if this move creates a match

                            local results = self.board:calculateMatches()
                            local matches = results.matches


                            self.possibleSwaps = results.possibleSwaps
                            if not self.possibleSwaps or #self.possibleSwaps == 0 then
                                -- spawn a new board if there are no possibleSwaps
                                gSounds['shuffle-board']:stop()
                                gSounds['shuffle-board']:play()
                                self.board = Board(VIRTUAL_WIDTH - 272, 16, self.level)
                            end

                            -- if this move does not create a match then
                            -- tween/swap the visual tiles back to their original position and the data
                            if matches == false then
                                self:handleBadSwap(newTile, { x = tempX, y = tempY })
                            else
                                -- else proceed as normal
                                self:calculateMatches()
                            end
                        end -- end of anonymous function in Finish
                    )       -- end of Timer:Finish()
            end
        end                 -- End user pressed enter
    end                     -- End check user input

    self.board:update(dt)
    Timer.update(dt)
end

--[[
    Calculates whether any matches were found on the board and tweens the needed
    tiles to their new destinations if so. Also removes tiles from the board that
    have matched and replaces them with new randomized tiles, deferring most of this
    to the Board class.
]]
function PlayState:calculateMatches()
    self.highlightedTile = nil

    local bonusAmount = 25 -- per level

    -- if we have any matches, remove them and tween the falling blocks that result
    local results = self.board:calculateMatches()
    local matches = results.matches

    if matches then
        gSounds['match']:stop()
        gSounds['match']:play()

        -- add score for each match
        local matchesHasRowDestoyer = false
        for k, match in pairs(matches) do
            self.score = self.score + #match * 50

            --
            for _, tile in pairs(match) do
                local tileVariety = tile.variety

                -- check the matches for bonus point tiles
                -- for any tile above variety 1 assign extra points
                -- if variety is 1 then multiply by 0 to assign no extra points
                self.score = self.score + (bonusAmount * (tileVariety - 1))

                -- check for the row destoyer
                if tile.powerupType == TILE_POWERUPS[TILE_PUP_DESTORY_ROW] then
                    matchesHasRowDestoyer = true
                end
            end

            -- scoring a match extends the timer by 1 second per tile in a match.
            self.timer = self.timer + #match
        end

        -- remove any tiles that matched from the board, making empty spaces
        -- check if matches had a row destoyer and play its sound
        if matchesHasRowDestoyer then
            gSounds['row-destruction']:stop()
            gSounds['row-destruction']:play()
        end

        self.board:removeMatches()

        -- gets a table with tween values for tiles that should now fall
        local tilesToFall = self.board:getFallingTiles()

        -- tween new tiles that spawn from the ceiling over 0.25s to fill in
        -- the new upper gaps that exist
        Timer.tween(0.25, tilesToFall):finish(function()
            -- recursively call function in case new matches have been created
            -- as a result of falling blocks once new blocks have finished falling
            self:calculateMatches()
        end)

        -- if no matches, we can continue playing
    else
        self.canInput = true
    end

    self.possibleSwaps = results.possibleSwaps

    if not self.possibleSwaps or #self.possibleSwaps == 0 then
        -- spawn a new board if there are no possibleSwaps
        gSounds['shuffle-board']:stop()
        gSounds['shuffle-board']:play()
        self.board = Board(VIRTUAL_WIDTH - 272, 16, self.level)
    end
end

function PlayState:render()
    -- render board of tiles
    self.board:render()

    -- render highlighted tile if it exists
    if self.highlightedTile then
        -- multiply so drawing white rect makes it brighter
        love.graphics.setBlendMode('add')

        love.graphics.setColor(1, 1, 1, 96 / 255)
        love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
            (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)

        -- back to alpha
        love.graphics.setBlendMode('alpha')
    end

    -- render highlight rect color based on timer
    if self.rectHighlighted then
        love.graphics.setColor(217 / 255, 87 / 255, 99 / 255, 1)
    else
        love.graphics.setColor(172 / 255, 50 / 255, 50 / 255, 1)
    end

    -- draw actual cursor rect
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', (self.boardHighlightX - 1) * TILE_WIDTH + (VIRTUAL_WIDTH - 272),
        (self.boardHighlightY - 1) * TILE_HEIGHT + 16, TILE_WIDTH, TILE_HEIGHT, 4)

    -- GUI text
    love.graphics.setColor(56 / 255, 56 / 255, 56 / 255, 234 / 255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(99 / 255, 155 / 255, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end

function PlayState:handleBadSwap(tile, oldPos)
    local tempX, tempY = oldPos.x, oldPos.y
    local newTile = tile

    Timer.tween(0.1, {
        [self.highlightedTile] = { x = newTile.x, y = newTile.y },
        [newTile] = { x = self.highlightedTile.x, y = self.highlightedTile.y }
    })

    -- put board highlight back where it
    self.boardHighlightX = tempX
    self.boardHighlightY = tempY

    -- swap the board tiles back to their original data position
    tempX = self.highlightedTile.gridX
    tempY = self.highlightedTile.gridY

    self.highlightedTile.gridX = newTile.gridX
    self.highlightedTile.gridY = newTile.gridY
    newTile.gridX = tempX
    newTile.gridY = tempY
    self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self
        .highlightedTile
    self.board.tiles[newTile.gridY][newTile.gridX] = newTile

    -- unselect highlighted tile
    self.highlightedTile = nil

    -- give user feedback
    gSounds['error']:play()
end
