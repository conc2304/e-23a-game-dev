-- Definition of the Box class.
Box = {}
Box.__index = Box

-- Constructor for creating a new Box object.
function Box.new(x, y, width, height)
    local self = setmetatable({}, Box) -- Sets Box as the metatable for the new object, enabling OOP features.
    self.x = x                         -- X coordinate of the box.
    self.y = y                         -- Y coordinate of the box.
    self.width = width                 -- Width of the box.
    self.height = height               -- Height of the box.
    self.color = { 0, 0, 1 }           -- Color of the box, set to blue (in RGB).
    self.ySpeed = 50                   -- Vertical speed of the box's movement.
    self.direction = 1                 -- Direction of movement (1 for moving up, -1 for moving down).
    return self                        -- Returns the newly created box object.
end

-- Method to update the box's state.
function Box:update(dt)
    if self.y <= 0 or then
        self.direction = -1 *self.direction
    end
    if self.y >= t.window.height - self.height then
        self.ySpeed = self.ySpeed
    end

    self.y = self.y + self.direction * self.ySpeed * dt -- Updates the Y position based on speed and direction.
    -- Logic to change the direction when reaching certain bounds. This part of the code is not shown here,
    -- but it typically contains conditions to reverse the direction when the box reaches the top or bottom
    -- of the screen or certain predefined limits.
end

-- Method to draw the box on the screen.
function Box:draw()
    love.graphics.setColor(self.color)                                       -- Sets the color for drawing the box.
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height) -- Draws a filled rectangle with the box's properties.
end
