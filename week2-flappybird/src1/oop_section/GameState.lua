-- Definition of the GameState class.
GameState = {}
GameState.__index = GameState

-- Constructor for creating a new GameState object.
function GameState.new()
    local self = setmetatable({}, GameState) -- Sets GameState as the metatable for the new object, enabling OOP features.
    -- Creates two Box objects. Assumes that the Box class is defined elsewhere and available globally.
    myBox1 = Box.new(100, 100, 50, 50) -- Creates the first Box object at position (100,100) with width 50 and height 50.
    myBox2 = Box.new(200, 200, 50, 50) -- Creates the second Box object at position (200,200) with width 50 and height 50.
    return self -- Returns the newly created game state object.
end

-- Method to update the game state.
function GameState:update(dt)
    -- Updates the state of both Box objects. Assumes these objects are global or accessible in this scope.
    myBox1:update(dt) -- Updates the first box.
    myBox2:update(dt) -- Updates the second box.
end

-- Method to draw the game state on the screen.
function GameState:draw()
    -- Draws both Box objects. Assumes these objects are global or accessible in this scope.
    myBox1:draw() -- Draws the first box.
    myBox2:draw() -- Draws the second box.
    
    -- Draws a text label on the screen.
    love.graphics.print("Game", 10, love.graphics.getHeight() - 20) -- Prints "Game" at the bottom-left of the screen.
end


-- Returns the GameState class.
return GameState
