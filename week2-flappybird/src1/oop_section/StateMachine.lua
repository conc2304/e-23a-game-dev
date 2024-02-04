-- Require the state modules
require "GameState"  -- Require the GameState module for the game state logic
require "StartState" -- Require the StartState module for the start state logic
require "PauseState" -- Require the PauseState module for the start state logic

-- StateMachine table acts as a class for managing game states
StateMachine = {}
StateMachine.__index = StateMachine

-- Constructor function for StateMachine
function StateMachine.new()
    local self = setmetatable({}, StateMachine) -- Set StateMachine as the metatable for self
    self.states = {
        start = StartState.new(),               -- Initialize the start state
        game = GameState.new(),                 -- Initialize the game state
        pause = PauseState.new()                -- Initialize the pause state
    }
    self.currentState = nil                     -- Variable to keep track of the current state
    return self
end

-- Function to change the current state of the state machine
function StateMachine:change(stateName)
    self.currentState = self.states[stateName] -- Set the current state to the specified state
end

-- Update function, called every frame with the time since last frame (dt) as the argument
function StateMachine:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt) -- Call the update method of the current state if it exists
    end
end

-- Draw function, called every frame to render the game
function StateMachine:draw()
    if self.currentState and self.currentState.draw then
        self.currentState:draw() -- Call the draw method of the current state if it exists
    end
end

-- Return the StateMachine table for use in other modules
return StateMachine
