--[[
    GD50
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]



Level = Class {}

function Level:init()
    -- create a new "world" (where physics take place), with no x gravity
    -- and 30 units of Y gravity (for downward force)
    self.world = love.physics.newWorld(0, 300)

    -- bodies we will destroy after the world update cycle; destroying these in the
    -- actual collision callbacks can cause stack overflow and other errors
    self.destroyedBodies = {}

    -- define collision callbacks for our world; the World object expects four,
    -- one for different stages of any given collision
    function beginContact(a, b, coll)
        self:handleContact(a, b)
    end

    -- the remaining three functions here are sample definitions, but we are not
    -- implementing any functionality with them in this demo; use-case specific
    -- http://www.iforce2d.net/b2dtut/collision-anatomy
    function endContact(a, b, coll) end

    function preSolve(a, b, coll) end

    function postSolve(a, b, coll, normalImpulse, tangentImpulse) end

    -- register just-defined functions as collision callbacks for world
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    self:generateLevel()
end

function Level:update(dt)
    self:handleUserInput()
    -- update launch marker, which shows trajectory
    self.launchMarker:update(dt)

    -- Box2D world update code; resolves collisions and processes callbacks
    self.world:update(dt)

    self:handleDestroyedBodies()

    self:handleResetCheck()
end

function Level:render()
    -- render ground tiles across full scrollable width of the screen
    for x = -VIRTUAL_WIDTH, VIRTUAL_WIDTH * 2, 35 do
        love.graphics.draw(gTextures['tiles'], gFrames['tiles'][12], x, VIRTUAL_HEIGHT - 35)
    end

    self.launchMarker:render()

    for k, alien in pairs(self.aliens) do
        alien:render()
    end

    for k, obstacle in pairs(self.obstacles) do
        obstacle:render()
    end

    for _, projectile in pairs(self.playerProjectiles) do
        projectile:render()
    end

    -- render instruction text if we haven't launched bird
    if not self.launchMarker.launched then
        love.graphics.setFont(gFonts['medium'])
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf('Click and drag circular alien to shoot!',
            0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- render victory text if all aliens are dead
    if #self.aliens == 0 then
        love.graphics.setFont(gFonts['huge'])
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf('VICTORY', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    end
end

--
-- HELPER FUNCTIONS
--




function Level:handleContact(a, b)
    -- grab the body (or nil) that belongs to the all entities,
    -- getfixture() will return nil if not found
    local playerFixture = GetFixtureByType(a, b, 'Player')
    local obstacleFixture = GetFixtureByType(a, b, 'Obstacle')
    local alienFixture = GetFixtureByType(a, b, 'Alien')
    local groundFixture = GetFixtureByType(a, b, 'Ground')

    local destoryThreshold = 20

    -- flag the that the player has had a collision
    if playerFixture then
        self.launchMarker.hasCollided = true
    end

    -- if we collided between both the player and an obstacle...
    if obstacleFixture and playerFixture then
        -- destroy the obstacle if player's combined X/Y velocity is high enough
        local sumVel = GetSumOfAbsVelocities(playerFixture:getBody())

        if sumVel > destoryThreshold then
            table.insert(self.destroyedBodies, obstacleFixture:getBody())
        end
    end

    -- if we collided between an obstacle and an alien, as by debris falling...
    if obstacleFixture and alienFixture then
        -- destroy the alien if falling debris is falling fast enough
        local sumVel = GetSumOfAbsVelocities(obstacleFixture:getBody())

        if sumVel > destoryThreshold then
            table.insert(self.destroyedBodies, alienFixture:getBody())
        end
    end

    -- if we collided between the player and the alien...
    if playerFixture and alienFixture then
        -- destroy the alien if player is traveling fast enough
        local sumVel = GetSumOfAbsVelocities(playerFixture:getBody())

        if sumVel > destoryThreshold then
            table.insert(self.destroyedBodies, alienFixture:getBody())
        end
    end

    -- if we hit the ground, play a bounce sound
    if playerFixture and groundFixture then
        gSounds['bounce']:stop()
        gSounds['bounce']:play()
    end
end

function Level:handleResetCheck()
    -- replace launch marker if original alien stopped moving
    if self.launchMarker.launched then
        -- check if all projectiles are done moving
        local projectilesStillMoving = self:areProjectilesMoving()

        -- when done moving, reset the launcher and extra projectiles
        if not projectilesStillMoving then
            self.launchMarker.alien.body:destroy()
            self.launchMarker = AlienLaunchMarker(self.world)

            for _, projectile in pairs(self.playerProjectiles) do
                projectile.body:destroy()
            end

            self.playerProjectiles = {}

            -- re-initialize level if we have no more aliens
            if #self.aliens == 0 then
                gStateMachine:change('start')
            end
        end
    end
end

function Level:areProjectilesMoving()
    -- if all projectiles are off screen return false
    -- if any projectiles velocity is above 1.5, return false
    local function isProjectileMoving(projectile)
        local xPos, _ = projectile.body:getPosition()
        local xVel, yVel = projectile.body:getLinearVelocity()
        local velocityThreshold = 1.5

        -- if we fired our alien offscreen or it's almost done rolling, respawn
        local isOffScreen = xPos < 0 or xPos > VIRTUAL_WIDTH + PLAYER_ENTITY_RADIUS
        local isNotMoving = math.abs(xVel) + math.abs(yVel) < velocityThreshold
        local isFinishedMoving = isOffScreen or isNotMoving

        -- return that i
        return not isFinishedMoving
    end

    -- check principal projectile
    if isProjectileMoving(self.launchMarker.alien) then return true end

    -- check supplemental projectiles
    for _, projectile in pairs(self.playerProjectiles) do
        if isProjectileMoving(projectile) then return true end
    end

    -- if nothing has returned true that they are still moving, then return false
    return false
end

function Level:generateLevel()
    -- shows alien before being launched and its trajectory arrow
    self.launchMarker = AlienLaunchMarker(self.world)

    -- store any extra projectiles that the player may use
    self.playerProjectiles = {}

    -- aliens in our scene
    self.aliens = {}

    -- obstacles guarding aliens that we can destroy
    self.obstacles = {}

    -- simple edge shape to represent collision for ground
    self.edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH * 3, 0)

    -- spawn an alien to try and destroy
    table.insert(self.aliens,
        Alien(self.world, 'square', VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - TILE_SIZE - ALIEN_SIZE / 2, 'Alien'))

    self:generateObstacleFeature(VIRTUAL_WIDTH - 100, VIRTUAL_HEIGHT - TILE_SIZE, true)
    self:generateObstacleFeature(VIRTUAL_WIDTH - 100, VIRTUAL_HEIGHT - TILE_SIZE - 110 - 35, true)

    -- ground data
    self.groundBody = love.physics.newBody(self.world, -VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 35, 'static')
    self.groundFixture = love.physics.newFixture(self.groundBody, self.edgeShape)
    self.groundFixture:setFriction(0.5)
    self.groundFixture:setUserData('Ground')

    -- background graphics
    self.background = Background()
end

function Level:handleDestroyedBodies()
    -- destroy all bodies we calculated to destroy during the update call
    for k, body in pairs(self.destroyedBodies) do
        if not body:isDestroyed() then
            body:destroy()
        end
    end

    -- reset destroyed bodies to empty table for next update phase
    self.destroyedBodies = {}

    -- remove all destroyed obstacles from level
    for i = #self.obstacles, 1, -1 do
        if self.obstacles[i].body:isDestroyed() then
            table.remove(self.obstacles, i)

            -- play random wood sound effect
            local soundNum = math.random(5)
            gSounds['break' .. tostring(soundNum)]:stop()
            gSounds['break' .. tostring(soundNum)]:play()
        end
    end

    -- remove all destroyed aliens from level
    for i = #self.aliens, 1, -1 do
        if self.aliens[i].body:isDestroyed() then
            table.remove(self.aliens, i)
            gSounds['kill']:stop()
            gSounds['kill']:play()
        end
    end
end

-- Generates a henge like |-| shaped obstacle with possibility for alien in the middle
function Level:generateObstacleFeature(x, y, hasAlien)
    -- spawn a few obstacles
    local vertW, vertH = 35, 110
    local horizW, horizH = 110, 35
    local paddingX = 10
    table.insert(self.obstacles, Obstacle(self.world, 'vertical',
        x - horizW + (vertW / 2), y - vertH / 2))
    table.insert(self.obstacles, Obstacle(self.world, 'vertical',
        x, y - vertH / 2))
    table.insert(self.obstacles, Obstacle(self.world, 'horizontal',
        x - horizW / 2 + paddingX, y - vertH - horizH / 2))

    if hasAlien then
        table.insert(self.aliens,
            Alien(self.world, 'square', x - horizW / 2 + paddingX, y - ALIEN_SIZE / 2, 'Alien'))
    end
end

--[[

    Mapping of Powerups to their functions
    -- NOTE Dependencies --
        all powerup functions should be defined before the fn map
        the powerupFnMap needs to be defined before its use in handleUserInput
]]

-- create a buckshot like power up in which we spawn extra projectiles around the original projectile
function Level:handleScatterShot()
    local alienRef = self.launchMarker.alien

    -- get physics settings from our original projectile
    local velocityX, velocityY = alienRef.body:getLinearVelocity()
    local originalX, originalY = alienRef.body:getPosition()

    local projectileRadius = PLAYER_ENTITY_RADIUS
    local projectileSpacing = PLAYER_ENTITY_RADIUS
    local projectileOffsetY = projectileRadius + projectileSpacing
    -- for reference, it seems like our current max velocity x is around 300
    local velocityYScatter = 75 -- amount to offset the y velocity by to create a different angle

    -- allow programmatic adjustments
    local scatterShotsPerSide = 1 -- number of projectiles on each side of the base projectil
    local sides = 2               -- this really shouldnt change, unless we want to create a circle of projectiles instead of a line
    local totalExtraProjectiles = scatterShotsPerSide * sides

    -- generate scatter shots on each side of the base projectile
    for i = 1, totalExtraProjectiles, 1 do
        local isPastHalfway = i > totalExtraProjectiles / sides
        local offsetYShift = isPastHalfway and 1 or
            -1 -- put the projectiles either above or below the original based on am
        local offsetY = projectileOffsetY * offsetYShift
        -- local yPos = originalY + offsetY
        local yPos = math.min(originalY + offsetY, VIRTUAL_HEIGHT - TILE_SIZE - projectileRadius) -- don't put the new projectile in the ground

        -- add new projectile with adjusted y velocity
        local newProjectile = Alien(self.world, 'round', originalX, yPos, 'Player')
        newProjectile.body:setLinearVelocity(velocityX, velocityY + (offsetYShift * velocityYScatter))
        table.insert(self.playerProjectiles, newProjectile)
    end

    gSounds['scatter-shot']:stop()
    gSounds['scatter-shot']:play()
end

local PowerUpFnMap = {
    [POWERUP_TYPE_SCATTER_SHOT] = Level.handleScatterShot
}

function Level:handleUserInput()
    -- only allow power up before collision, and only if the powerup has not been used
    local powerUpAvailable = not self.launchMarker.hasCollided and not self.powerupUsed

    -- handle various powerups if they are available, but not before launching duh
    if love.keyboard.wasPressed('space') and powerUpAvailable and self.launchMarker.launched then
        -- allow for various power ups and handle them accordingly
        local powerupFn = PowerUpFnMap[self.launchMarker.powerupType]
        if powerupFn ~= nil then
            powerupFn(self)
        end
    end
end
