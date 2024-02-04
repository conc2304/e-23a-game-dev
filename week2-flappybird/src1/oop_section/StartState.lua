-- Definition of the StartState class.
StartState = {}
StartState.__index = StartState

-- Constructor for creating a new StartState object.
function StartState.new()
    local self = setmetatable({}, StartState) -- Sets StartState as the metatable for the new object, enabling OOP features.
    return self -- Returns the newly created StartState object.
end

-- Method to update the StartState.
function StartState:update(dt)
    -- Update logic for StartState.
    -- This part of the code is expected to contain any logic for updating the state, 
    -- such as handling user inputs or animations that occur in the start state.
    -- However, this specific implementation is empty, indicating no update operations are performed in this state.
end

-- Method to draw the StartState on the screen.
function StartState:draw()
    -- Draws a text label "Start" on the screen.
    love.graphics.print("Start", 300, 480) -- Prints "Start" at coordinates (300, 480) on the screen.
end

-- Returns the StartState class.
return StartState
