--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class { __includes = BaseState }

-- Medal Score Thresholds
BRONZE_THRESHOLD = 3
SILVER_THRESHOLD = 6
GOLD_THRESHOLD = 9

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score

    self.medal = self:getMedalByScore(self.score)
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 50, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 85, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 200, VIRTUAL_WIDTH, 'center')

    -- draw medal/achievement
    self:renderAchievement(self.medal)
end

-- Get text based on the medal the player earned
function ScoreState:getMessageByMedal(medal)
    if medal == nil then
        return "Losing Medal for you!"
    elseif medal == 'bronze' then
        return "Bronze Medal"
    elseif medal == 'silver' then
        return "Silver Medal!"
    elseif medal == 'gold' then
        return "Gold Medal Master!"
    end
end

-- get the medal based on the score
function ScoreState:getMedalByScore(score)
    if score == nil or score >= BRONZE_THRESHOLD and score < SILVER_THRESHOLD then
        return "bronze"
    elseif score >= SILVER_THRESHOLD and score < GOLD_THRESHOLD then
        return "silver"
    elseif score >= GOLD_THRESHOLD then
        return "gold"
    end
    return nil;
end

-- Based on the medal achieved, render the medal image and corresponding text
function ScoreState:renderAchievement(medal)
    local medalImg = nil
    if medal == 'bronze' then
        medalImg = love.graphics.newImage('medal-bronze.png')
    elseif medal == 'silver' then
        medalImg = love.graphics.newImage('medal-silver.png')
    elseif medal == 'gold' then
        medalImg = love.graphics.newImage('medal-gold.png')
    else
        medalImg = love.graphics.newImage('medal-losing.png')
    end

    -- Render text and medal image
    love.graphics.setFont(smallFont)
    love.graphics.printf(self:getMessageByMedal(medal), 0, 180, VIRTUAL_WIDTH, 'center')

    local scale = 0.75
    love.graphics.draw(medalImg, VIRTUAL_WIDTH / 2 - ((medalImg:getWidth() * scale) / 2), 100, 0, scale,
        scale)
end
