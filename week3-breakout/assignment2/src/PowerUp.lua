PowerUp = Class {}


PUP_HALF_POINTS = 1
PUP_DOUBLE_POINTS = 2
PUP_ADD_LIFE = 3
PUP_SUB_LIFE = 4
PUP_BALL_SPEED_FASTER = 5
PUP_BALL_SPEED_SLOWER = 6
PUP_TINY_BALL = 7
PUP_LARGE_BALL = 8
PUP_EXTRA_BALL = 9
PUP_KEY = 10


function PowerUp:init(x, y, type)
  self.x = x
  self.y = y
  self.type = type
  self.width = 16
  self.height = 16
  self.inPlay = true

  self.dy = math.random(7, 10)
  self.dx = 0
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function PowerUp:collides(target)
  return Collides(self, target)
end

function PowerUp:update(dt)
  self.y = self.y + self.dy * dt
end

function PowerUp:reset()
end

function PowerUp:render()
  if self.inPlay then
    -- render power up
    love.graphics.draw(
      gTextures['main'],
      gFrames['powerUps'][self.type],
      self.x,
      self.y
    )
  end
end
