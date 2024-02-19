--[[
    GD50
    Match-3 Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state the game is in when we've just started; should
    simply display "Match-3" in large text, as well as a message to press
    Enter to begin.
]]

local positions = {}

StartState = Class { __includes = BaseState }

local ACTION_BEGIN_GAME = 1
local ACTION_QUIT_GAME = 2
local START_ACTIONS = { [ACTION_BEGIN_GAME] = ACTION_BEGIN_GAME, [ACTION_QUIT_GAME] = ACTION_QUIT_GAME }

function StartState:init()
    -- currently selected menu item
    self.currentMenuItem = 1

    -- colors we'll use to change the title text
    self.colors = {
        [1] = { 217 / 255, 87 / 255, 99 / 255, 1 },
        [2] = { 95 / 255, 205 / 255, 228 / 255, 1 },
        [3] = { 251 / 255, 242 / 255, 54 / 255, 1 },
        [4] = { 118 / 255, 66 / 255, 138 / 255, 1 },
        [5] = { 153 / 255, 229 / 255, 80 / 255, 1 },
        [6] = { 223 / 255, 113 / 255, 38 / 255, 1 }
    }

    -- letters of MATCH 3 and their spacing relative to the center
    self.letterTable = {
        { 'M', -108 },
        { 'A', -64 },
        { 'T', -28 },
        { 'C', 2 },
        { 'H', 40 },
        { '3', 112 }
    }

    -- time for a color change if it's been half a second
    self.colorTimer = Timer.every(0.075, function()
        -- shift every color to the next, looping the last to front
        -- assign it to 0 so the loop below moves it to 1, default start
        self.colors[0] = self.colors[6]

        for i = 6, 1, -1 do
            self.colors[i] = self.colors[i - 1]
        end
    end)

    -- generate full table of tiles just for display
    for i = 1, 64 do
        table.insert(positions, gFrames['tiles'][math.random(18)][math.random(6)])
    end

    -- used to animate our full-screen transition rect
    self.transitionAlpha = 0

    -- if we've selected an option, we need to pause input while we animate out
    self.pauseInput = false


    -- decare the menu options positions
    self.optionMenuYBottom = 12
    self.menuItemHeight = gFonts['medium']:getHeight()
    self.menuWidth = 400
    self.startY = VIRTUAL_HEIGHT / 2 + self.optionMenuYBottom + 8 -- start on top
    self.startX = VIRTUAL_WIDTH / 2 - self.menuWidth / 2
    self.quitY = VIRTUAL_HEIGHT / 2 + self.optionMenuYBottom + 33 -- quit on bottom
    -- self.quitY = VIRTUAL_HEIGHT / 2 + self.optionMenuYBottom + (1.5 * self.menuItemHeight) -- quit on bottom
end

function StartState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if love.mouse.wasPressed(1) then
        local mouse = love.mouse.buttonsPressed[1]
        self:handleMouseClick(mouse.x, mouse.y)
    end


    -- as long as can still input, i.e., we're not in a transition...
    if not self.pauseInput then
        -- change menu selection
        if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
            self.currentMenuItem = self.currentMenuItem == 1 and 2 or 1
            gSounds['select']:play()
        end

        -- switch to another state via one of the menu options
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            -- do navigation
            self:navigateTo(self.currentMenuItem)
        end
    end

    -- update our Timer, which will be used for our fade transitions
    Timer.update(dt)
end

function StartState:render()
    -- render all tiles and their drop shadows
    local boardOffsetX = 128
    for y = 1, BOARD_GRID_SIZE.y do
        for x = 1, BOARD_GRID_SIZE.x do
            -- render shadow first
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x],
                (x - 1) * TILE_WIDTH + boardOffsetX + 3, (y - 1) * TILE_HIGHT + (TILE_HIGHT / 2) + 3)

            -- render tile
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x],
                (x - 1) * TILE_WIDTH + boardOffsetX, (y - 1) * TILE_HIGHT + (TILE_HIGHT / 2))
        end
    end

    -- keep the background and tiles a little darker than normal
    love.graphics.setColor(0, 0, 0, 128 / 255)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    self:drawMatch3Text(-60)
    self:drawOptions(self.optionMenuYBottom)

    -- draw our transition rect; is normally fully transparent, unless we're moving to a new state
    love.graphics.setColor(1, 1, 1, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

--[[
    Draw the centered MATCH-3 text with background rect, placed along the Y
    axis as needed, relative to the center.
]]
function StartState:drawMatch3Text(y)
    -- draw semi-transparent rect behind MATCH 3
    love.graphics.setColor(1, 1, 1, 128 / 255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y - 11, 150, 58, 6) -- so many random numbers!!!!

    -- draw MATCH 3 text shadows
    love.graphics.setFont(gFonts['large'])
    self:drawTextShadow('MATCH 3', VIRTUAL_HEIGHT / 2 + y)

    -- print MATCH 3 letters in their corresponding current colors
    for i = 1, 6 do
        love.graphics.setColor(self.colors[i])
        love.graphics.printf(self.letterTable[i][1], 0, VIRTUAL_HEIGHT / 2 + y,
            VIRTUAL_WIDTH + self.letterTable[i][2], 'center')
    end
end

--[[
    Draws "Start" and "Quit Game" text over semi-transparent rectangles.
]]
function StartState:drawOptions(y)
    -- draw rect behind start and quit game text
    love.graphics.setColor(1, 1, 1, 128 / 255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y, 150, 58, 6)

    -- draw Start text
    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Start', self.startY)

    if self.currentMenuItem == 1 then
        love.graphics.setColor(99 / 255, 155 / 255, 1, 1)
    else
        love.graphics.setColor(48 / 255, 96 / 255, 130 / 255, 1)
    end

    love.graphics.printf('Start', 0, self.startY, VIRTUAL_WIDTH, 'center')

    -- draw Quit Game text
    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Quit Game', self.quitY)

    if self.currentMenuItem == 2 then
        love.graphics.setColor(99 / 255, 155 / 255, 1, 1) -- code makers why u no use variables??!??
    else
        love.graphics.setColor(48 / 255, 96 / 255, 130 / 255, 1)
    end

    love.graphics.printf('Quit Game', 0, self.quitY, VIRTUAL_WIDTH, 'center')
end

--[[
    Helper function for drawing just text backgrounds; draws several layers of the same text, in
    black, over top of one another for a thicker shadow.
]]
function StartState:drawTextShadow(text, y)
    love.graphics.setColor(34 / 255, 32 / 255, 52 / 255, 1)
    love.graphics.printf(text, 2, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 0, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 2, VIRTUAL_WIDTH, 'center')
end

function StartState:handleMouseClick(mouseX, mouseY)
    local gameX, gameY = push:toGame(mouseX, mouseY)

    -- handle start click
    if gameX >= self.startX and gameX <= self.startX + self.menuWidth and
        gameY >= self.startY and gameY <= self.startY + self.menuItemHeight then
        self.currentMenuItem = 1
        self:navigateTo(self.currentMenuItem)
    end

    -- handle quict click
    if gameX >= self.startX and gameX <= self.startX + self.menuWidth and
        gameY >= self.quitY and gameY <= self.quitY + self.menuItemHeight then
        -- "Quit Game" was clicked
        print("Quit Game clicked")
        self.currentMenuItem = 2
        self:navigateTo(self.currentMenuItem)
    end
end

function StartState:navigateTo(actionState)
    local action = START_ACTIONS[actionState]

    -- finite state for actions
    if action == nil then return end

    gSounds['select']:play()


    if action == START_ACTIONS[ACTION_BEGIN_GAME] then
        -- tween, using Timer, the transition rect's alpha to 1, then
        -- transition to the BeginGame state after the animation is over
        Timer.tween(1, {
            [self] = { transitionAlpha = 1 }
        }):finish(function()
            gStateMachine:change('begin-game', {
                level = 1
            })

            -- remove color timer from Timer
            self.colorTimer:remove()
        end)
    elseif action == START_ACTIONS[ACTION_QUIT_GAME] then
        love.event.quit() -- ... um quit
    end

    -- turn off input during transition
    self.pauseInput = true
end
