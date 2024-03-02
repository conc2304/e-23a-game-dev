PlayerCarryItemIdleState = Class { __includes = EntityIdleState }

local statePrefix = 'carry-'

-- 'carry-item-idle'
-- 'carry-item-walk'

function PlayerCarryItemIdleState:enter(params)
  print("ENTER PlayerCarryItemIdleState")
  -- render offset for spaced character sprite (negated in render function of state)
  self.entity.offsetY = 5
  self.entity.offsetX = 0

  local animationKey = statePrefix .. 'idle-' .. self.entity.direction
  self.entity:changeAnimation(animationKey)
end

function PlayerCarryItemIdleState:update(dt)
  -- print("UPDATE PlayerCarryItemIdleState")
  if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
      love.keyboard.isDown('up') or love.keyboard.isDown('down') then
    local animationKey = statePrefix .. 'walk-' .. self.entity.direction
    print("UPDATE PlayerCarryItemIdleState ---> walk")
    self.entity:changeState('carry-item-walk')
    self.entity:changeAnimation(animationKey)
  end

  if love.keyboard.wasPressed('space') then
    -- todo handle throw item
    print("idle carry - throw pot")
    -- self.entity:changeState('throw-item')

    self.entity:throwItem(self.entity.liftedItem)
  end

  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    print("handleDropd")

    self.entity:dropItem()
    self.entity:changeState('idle')
  end
end
