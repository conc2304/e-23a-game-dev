-- Definition of the PauseState class.
PauseState = {}
PauseState.__index = PauseState

-- Constructor for creating a new PauseState object.
function PauseState.new()
  local self = setmetatable({}, PauseState) -- Sets PauseState as the metatable for the new object, enabling OOP features.
  return self                               -- Returns the newly created PauseState object.
end

-- Method to update the PauseState.
function PauseState:update(dt)
  -- Update logic for PauseState.
  -- Do Nothing
end

-- Method to draw the PauseState on the screen.
function PauseState:draw()
  -- Draws a text label "Pause" on the screen.
  love.graphics.print("Pause", 300, 480) -- Prints "Pause" at coordinates (300, 480) on the screen.
end

-- Returns the PauseState class.
return PauseState
