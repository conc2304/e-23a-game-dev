--[[
    GD50
    Legend of Zelda

    Author: NOT Colton Ogden
    notcogden@cs50.harvard.edu
]]

PlayerCarryItemWalkState = Class { __includes = PlayerWalkState }

function PlayerCarryItemWalkState:init(player, dungeon)
  self.player = player
  self.dungeon = dungeon


  -- render offset for spaced character sprite
  -- self.player.offsetY = 5
  -- self.player.offsetX = 8
end

function PlayerCarryItemWalkState:enter(params)
  -- restart sword swing sound for rapid swinging
  print("ENTER CARRY STATE")

  -- restart sword swing animation
  self.player.currentAnimation:refresh()
end

function PlayerCarryItemWalkState:update(dt)
  -- check if hitbox collides with any entities in the scene

  EntityWalkState.update(self, dt)

  -- allow us to change into this state afresh if we swing within it, rapid swinging
  if love.keyboard.wasPressed('space') then
    print("throw pot")
    -- todo handle pot throwing
  end
end

function PlayerCarryItemWalkState:render()
  local anim = self.player.currentAnimation
  love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
    math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

  --
  -- debug for player and hurtbox collision rects VV
  --

  -- love.graphics.setColor(255, 0, 255, 255)
  -- love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
  -- love.graphics.rectangle('line', self.swordHurtbox.x, self.swordHurtbox.y,
  --     self.swordHurtbox.width, self.swordHurtbox.height)
  -- love.graphics.setColor(255, 255, 255, 255)
end

function PlayerCarryItemWalkState:handleKeyboardInput()
  if love.keyboard.isDown('left') then
    self.player.direction = 'left'
    self.player:changeAnimation('carry-walk-left')
  elseif love.keyboard.isDown('right') then
    self.player.direction = 'right'
    self.player:changeAnimation('carry-walk-right')
  elseif love.keyboard.isDown('up') then
    self.player.direction = 'up'
    self.player:changeAnimation('carry-walk-up')
  elseif love.keyboard.isDown('down') then
    self.player.direction = 'down'
    self.player:changeAnimation('carry-walk-down')
  else
    self.player:changeState('idle-carry-item')
  end

  if love.keyboard.wasPressed('enter') then
    -- todo handle throw item
    -- self.entity:changeState('swing-sword')
  end
end
