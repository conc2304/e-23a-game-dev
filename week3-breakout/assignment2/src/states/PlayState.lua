--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class { __includes = BaseState }

PADDLE_RESIZER_PT_INTERVAL = 500

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.scoreMultiplier = params.scoreMultiplier or 1
    self.highScores = params.highScores
    -- self.ball = params.ball
    self.balls = params.balls
    self.level = params.level
    self.powerUps = params.powerUps

    self.recoverPoints = 5000

    -- give ball random starting velocity
    for _, ball in pairs(self.balls) do
        if ball.inPlay == false then
            ::continue::
        end
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end


    -- update positions based on velocity
    self.paddle:update(dt)

    local ballsInPlay = 0;
    -- get an initial count of how many balls are in play
    for _, ball in pairs(self.balls) do
        if ball.inPlay then
            ballsInPlay = ballsInPlay + 1
            ball:update(dt)
        end
    end

    -- Check all balls for collision with Paddle
    for _, ball in pairs(self.balls) do
        if ball.inPlay == false then
            ::continue::
        end
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

                -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        -- only check collision if we're in play
        for _, ball in pairs(self.balls) do
            if ball.inPlay == false then
                ::continue::
            end

            if brick.inPlay and ball:collides(brick) then
                -- add to score
                self.score = self.score + (self.scoreMultiplier * (brick.tier * 200 + brick.color * 25))

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- if brick has just been taken out of play and it contains a power up,
                -- release the powerup in the center of the brick
                if brick.inPlay == false and brick.hasPowerUp == true then
                    local brickCenterX = brick.x + (brick.height * 0.5)
                    local brickCenterY = brick.y + (brick.width * 0.5)
                    -- currently only power up available should be extra balls

                    local p = PowerUp(brickCenterX, brickCenterY, PUP_EXTRA_BALL)

                    table.insert(self.powerUps, p)
                end

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                -- for _, ball in pairs(self.balls) do
                --     if ball.inPlay == false then
                --         ::continue::
                --     end
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8

                    -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32

                    -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8

                    -- bottom edge if no X collisions or top collision, last possibility
                else
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
                -- end
            end
        end
        -- go to our victory screen if there are no more bricks left
        if self:checkVictory() then
            gSounds['victory']:play()

            local _balls = {}
            local defaultBall = Ball()

            table.insert(_balls, Ball())
            return gStateMachine:change('victory', {
                level = self.level,
                paddle = self.paddle,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                balls = _balls, -- only send one to the victory state
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- if score is past threshold then give them bigger paddles
    if self.score > PADDLE_RESIZER_PT_INTERVAL then
        -- grow paddle up to the max size
        self.paddle:SetSize(math.min(self.paddle.size + 1, PADDLE_SIZE_MAX))
        PADDLE_RESIZER_PT_INTERVAL = PADDLE_RESIZER_PT_INTERVAL + PADDLE_RESIZER_PT_INTERVAL
    end


    for _, ball in pairs(self.balls) do
        if ball.inPlay == false then
            ::continue::
        end

        -- if this is the last ball in play and it is over the line then round ends
        if ball.y >= VIRTUAL_HEIGHT then
            -- if this was the last ball in play then end current round
            if ballsInPlay == 0 then
                self.health = self.health - 1
                gSounds['hurt']:play()

                if self.health == 0 then
                    print("Game Over")
                    return gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    print("LIFE LOST")
                    -- shrink the paddle size, but no lower than the min
                    self.paddle:SetSize(math.max(PADDLE_SIZE_MIN, self.paddle.size - 1))

                    return gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
            ball.inPlay = false
            -- ballsInPlay = ballsInPlay - 1
            -- end if last ball in play
        end
        -- end if end of round
    end
    -- end of balls loop bottom test


    -- detect collision across all powerupse and apply power up if power up touches paddle
    for _, powerUp in pairs(self.powerUps) do
        if powerUp.inPlay and powerUp:collides(self.paddle) then
            self:applyPowerUp(powerUp.type)
            powerUp.inPlay = false
        end
    end

    -- for rendering particle systems
    for _, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    for _, powerUp in pairs(self.powerUps) do
        if powerUp.inPlay == true then
            powerUp:update(dt)
        end
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for _, ball in pairs(self.balls) do
        ball:render()
    end

    for _, powerUp in pairs(self.powerUps) do
        powerUp:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for _, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end

function PlayState:applyPowerUp(type)
    if type == PUP_HALF_POINTS then
        self.scoreMultiplier = math.min(0.01, self.scoreMultiplier * 0.5)
    elseif type == PUP_DOUBLE_POINTS then
        self.scoreMultiplier = self.scoreMultiplier * 2
    elseif type == PUP_ADD_LIFE then
        self.health = self.health + 1
    elseif type == PUP_SUB_LIFE then
        self.health = self.health - 1
    elseif type == PUP_BALL_SPEED_FASTER then
        for _, ball in pairs(self.balls) do
            if ball.inPlay == true then
                ball.dx = ball.dx * 1.25
                ball.dy = ball.dy * 1.25
            end
        end
    elseif type == PUP_BALL_SPEED_SLOWER then
        for _, ball in pairs(self.balls) do
            if ball.inPlay then
                ball.dx = ball.dx * 0.75
                ball.dy = ball.dy * 0.75
            end
        end
    elseif type == PUP_TINY_BALL then
        for _, ball in pairs(self.balls) do
            if ball.inPlay == true then
                ball.scale = BALL_SMALL_SCALE
            end
        end
    elseif type == PUP_LARGE_BALL then
        for _, ball in pairs(self.balls) do
            if ball.inPlay then
                ball.scale = BALL_LARGE_SCALE
            end
        end
    elseif type == PUP_EXTRA_BALL then
        local extraBall = Ball()
        extraBall.skin = math.random(7)
        extraBall.x = self.paddle.x + (self.paddle.width * 0.5)
        extraBall.y = self.paddle.y - (self.paddle.height - (extraBall.height * (extraBall.scale * 1.2)))
        extraBall.dx = math.random(-200, 200)
        extraBall.dy = math.random(-50, -60)
        table.insert(self.balls, extraBall)
    elseif type == PUP_KEY then
    end
end
