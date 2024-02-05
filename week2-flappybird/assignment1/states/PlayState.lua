--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class { __includes = BaseState }

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24


function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
    self.difficulty = 'easy'

    local interval = self:getPipeIntervalRangeByDifficulty(self.difficulty)
    self.newPipeSpawnInterval = math.random(interval['min'], interval['max'])

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    -- on Pause send the current state to the pause state to hold onto for reinitialization
    if love.keyboard.wasPressed(PAUSE_KEY) then
        gStateMachine:change('pause', {
            bird = self.bird,
            pipePairs = self.pipePairs,
            timer = self.timer,
            score = self.score,
            lastY = self.lastY,
            difficulty = self.difficulty
        })
        -- if changing state then we don't need to do the rest
        return
    end

    -- update timer for pipe spawning
    self.timer = self.timer + dt

    -- generate new pipes at random intervals based on the difficulty


    -- spawn a new pipe pair every second and a half
    if self.timer > self.newPipeSpawnInterval then
        -- if self.timer > 2 then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        local y = math.max(-PIPE_HEIGHT + 10,
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - GAP_HEIGHT - PIPE_HEIGHT))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y, self.getDifficulty(self.score)))

        -- reset timer
        self.timer = 0

        -- update the spawn interval at each new spawning of pipes
        local interval = self:getPipeIntervalRangeByDifficulty(self.difficulty)
        self.newPipeSpawnInterval = math.random(interval['min'], interval['max'])
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()

        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    -- determin and render when the user gets to next level
    love.graphics.setFont(smallFont)
    local pos = { x = 8, y = 8 + flappyFont:getHeight() }
    if (self.score < GOLD_THRESHOLD) then
        -- determine where the next medal is threshold is at
        local medals = { BRONZE_THRESHOLD, SILVER_THRESHOLD, GOLD_THRESHOLD }
        local medalThreshold = nil
        table.sort(medals, function(a, b)
            return a > b
        end)
        for _, threshold in ipairs(medals) do
            if self.score < threshold then
                medalThreshold = threshold
            end
        end

        love.graphics.print('Next Medal at ' .. tostring(medalThreshold) .. 'pts', pos.x, pos.y)
    else
        love.graphics.print('Gold Medal Achieved', pos.x, pos.y)
    end
    love.graphics.setFont(smallFont)
    self.difficulty = self:getDifficulty(self.score)
    love.graphics.print('Diffuculty: ' .. self.difficulty, pos.x, pos.y + smallFont:getHeight())

    self.bird:render()
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter(params)
    -- if we are receiving a previous playstate then reinitialize with these values
    if params ~= nil and params.prevPlayState ~= nil then
        for key, value in pairs(params.prevPlayState) do
            self[key] = value
        end
    end

    -- if we're coming from death or Pause, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score/pause screen
    scrolling = false
end

-- Set get the difficulty state based on their points in relation to medal thresholds
function PlayState:getDifficulty(score)
    if score == nil or score < SILVER_THRESHOLD then
        return "easy"
    elseif score >= SILVER_THRESHOLD and score < GOLD_THRESHOLD then
        return "medium"
    else
        return "hard"
    end
end

-- Based on current diffuclty set the random interval min and max for spawning new PipePairs
function PlayState:getPipeIntervalRangeByDifficulty(difficulty)
    local gapMultiplierMap = {
        ['easy'] = { min = 3.5, max = 4.5 },
        ['medium'] = { min = 3, max = 3.5 },
        ['hard'] = { min = 2, max = 2.5 },
    }

    return gapMultiplierMap[difficulty]
end
