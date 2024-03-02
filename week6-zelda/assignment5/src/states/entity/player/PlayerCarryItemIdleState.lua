PlayerCarryItemIdleState = Class { __includes = EntityIdleState }

local statePrefix = 'carry-'

function PlayerCarryItemIdleState:enter(params)
  self.entity.offsetY = 5
  self.entity.offsetX = 0

  -- local prevState = params.prevState or nil
  -- check if intering a lift from a non lift state

  -- todo handle animation enter
  local animationKey = statePrefix .. 'idle-' .. self.entity.direction
  self.entity:changeAnimation(animationKey)
end

function PlayerCarryItemIdleState:exit()
end

function PlayerCarryItemIdleState:update(dt)
  if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
      love.keyboard.isDown('up') or love.keyboard.isDown('down') then
    local animationKey = statePrefix .. 'walk-' .. self.entity.direction
    self.entity:changeState('carry-item-walk')
    self.entity:changeAnimation(animationKey)
  end

  -- handle throwing the item
  if love.keyboard.wasPressed('space') then
    self.entity:throwItem(self.entity.liftedItem)
    self.entity:changeState('idle')
  end

  -- handle dropping the item
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    self.entity:dropItem()
    self.entity:changeState('idle')
  end
end
