-- Require necessary modules for the game
require "Box"                               -- Require the Box module to create box objects
local StateMachine = require "StateMachine" -- Require the StateMachine module to handle game states

-- Configuration function for Love2D settings
function love.conf(t)
    t.window.width = 640               -- Set the window width
    t.window.height = 960              -- Set the window height
    t.window.orientation = "landscape" -- Set the window orientation
end

-- The main loading function, called once at the start of the game
function love.load()
    love.window.setMode(640, 960, { fullscreen = false }) -- Set up the game window
    gameStateMachine = StateMachine.new()             -- Create a new instance of the StateMachine
    gameStateMachine:change("start")                  -- Set the initial state to "start"
end

-- Update function, called every frame with the time since last frame (dt) as the argument
function love.update(dt)
    gameStateMachine:update(dt) -- Update the current state of the game state machine
end

-- Draw function, called every frame to render the game
function love.draw()
    gameStateMachine:draw() -- Draw the current state of the game state machine
end

-- Key pressed event function, called whenever a key is pressed
function love.keypressed(key)
    if key == "f1" then -- Check if the F1 key was pressed
        -- Toggle between the "start" and "game" states
        if gameStateMachine.currentState == gameStateMachine.states.start then
            gameStateMachine:change("game")  -- Change to the game state if currently in start state
        else
            gameStateMachine:change("start") -- Change to the start state if currently in game state
        end
    end
    -- on key press of P pause the game

    if key == "p" then
        -- Go to state
        if gameStateMachine.currentState == gameStateMachine.states.game then
            gameStateMachine:change("pause") -- Change to the game state if currently in start state
        elseif gameStateMachine.currentState == gameStateMachine.states.pause then
            gameStateMachine:change("game")  -- Change to the game state if currently in start state
        end
    end
end
