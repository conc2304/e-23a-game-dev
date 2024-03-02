PlayerLiftItemState = Class { __includes = BaseState }

function PlayerLiftItemState:init(player, dungeon)
  self.player = player
  self.dungeon = dungeon

  -- render offset for spaced character sprite
  self.player.offsetY = 5
  self.player.offsetX = 0


  -- lift-left, lift-up, etc
  local animationKey = 'lift-' .. self.player.direction
  self.player:changeAnimation(animationKey)
end

function PlayerLiftItemState:enter(params)
  -- restart lifting animation
  self.player.currentAnimation:refresh()
end

function PlayerLiftItemState:update(dt)
  -- if we've fully elapsed through one cycle of animation, go to its next state
  if self.player.currentAnimation.timesPlayed > 0 then
    self.player.currentAnimation.timesPlayed = 0
    self.player:changeState('carry-item-idle')
  end
end

function PlayerLiftItemState:render()
  local anim = self.player.currentAnimation
  love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
    math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end
