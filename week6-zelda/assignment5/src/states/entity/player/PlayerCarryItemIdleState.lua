PlayerCarryItemIdleState = Class { __includes = EntityIdleState }

local statePrefix = 'carry-'

function PlayerCarryItemIdleState:enter(params)
  -- render offset for spaced character sprite (negated in render function of state)
  self.entity.offsetY = 5
  self.entity.offsetX = 0
end

function PlayerCarryItemIdleState:update(dt)
  if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
      love.keyboard.isDown('up') or love.keyboard.isDown('down') then
    local animationKey = statePrefix .. 'walk-' .. self.entity.direction
    self.entity:changeState('walk')
    self.entity:changeAnimation(animationKey)
  end

  if love.keyboard.wasPressed('space') then
    -- todo handle throw item
    print("idle carry - throw pot")
    -- self.entity:changeState('throw-item')
  end

  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    local objects = self.dungeon.currentRoom.objects or nil
    if objects then
      self.entity:handleLiftToggle(objects)
    end
  end
end
