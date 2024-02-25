--[[
    GD50
    -- Super Mario Bros. Remake --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class {}

function GameObject:init(def)
    self.x = def.x
    self.y = def.y
    self.texture = def.texture
    self.width = def.width
    self.height = def.height
    self.frame = def.frame
    self.animation = def.animation
    self.solid = def.solid
    self.collidable = def.collidable
    self.consumable = def.consumable
    self.onCollide = def.onCollide
    self.onConsume = def.onConsume
    self.hit = def.hit
end

function GameObject:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
        target.y > self.y + self.height or self.y > target.y + target.height)
end

function GameObject:update(dt)
    -- print("GO UPDATE")
    if self.animation then
        -- print("update-animation")
        self.animation:update(dt)
    end
end

function GameObject:render()
    if self.texture == nil or self.frame == nil or gFrames[self.texture][self.frame] == nil then
        print("no texture")
        print_r(self)
    end

    if self.animation then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.animation:getCurrentFrame()], self.x,
            self.y)
    else
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
    end
end
