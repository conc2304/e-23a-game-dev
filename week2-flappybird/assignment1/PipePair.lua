--[[
    PipePair Class

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Used to represent a pair of pipes that stick together as they scroll, providing an opening
    for the player to jump through in order to score a point.
]]

PipePair = Class {}

-- size of the gap between pipes
GAP_HEIGHT = 90

function PipePair:init(y, difficulty)
    -- flag to hold whether this pair has been scored (jumped through)
    self.scored = false


    -- initialize pipes past the end of the screen
    self.x = VIRTUAL_WIDTH + 32

    -- y value is for the topmost pipe; gap is a vertical shift of the second lower pipe
    self.y = y

    local gapRange = self:getGapSizeRangeByDifficulty(difficulty)

    -- instantiate two pipes that belong to this pair
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom',
            self.y + PIPE_HEIGHT + math.random(GAP_HEIGHT * gapRange['min'], GAP_HEIGHT * gapRange['max']))
    }

    -- whether this pipe pair is ready to be removed from the scene
    self.remove = false
end

function PipePair:update(dt)
    -- remove the pipe from the scene if it's beyond the left edge of the screen,
    -- else move it from right to left
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for l, pipe in pairs(self.pipes) do
        pipe:render()
    end
end

-- Based on current diffuclty set the random gap size min and max for spawning new PipePairs
function PipePair:getGapSizeRangeByDifficulty(difficulty)
    local gapMultiplierMap = {
        ['easy'] = { min = 1.4, max = 1.6 },
        ['medium'] = { min = 1, max = 1 },
        ['hard'] = { min = 0.75, max = 0.75 },
    }

    return gapMultiplierMap[difficulty]
end
