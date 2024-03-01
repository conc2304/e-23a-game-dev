PlayerCarryItemIdleState = Class { __includes = EntityIdleState }

function PlayerCarryItemIdleState:enter(params)
  -- render offset for spaced character sprite (negated in render function of state)
  self.entity.offsetY = 5
  self.entity.offsetX = 0
end

function PlayerCarryItemIdleState:update(dt)
  if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
      love.keyboard.isDown('up') or love.keyboard.isDown('down') then
    self.entity:changeState('walk-carry-item')
  end

  if love.keyboard.wasPressed('return') then
    -- todo handle throw item
    print("idle carry - throw pot")
    -- self.entity:changeState('throw-item')
  end
end
