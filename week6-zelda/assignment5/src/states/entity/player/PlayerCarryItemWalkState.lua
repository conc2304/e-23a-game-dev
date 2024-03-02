--[[
    GD50
    Legend of Zelda

    Author: NOT Colton Ogden
    notcogden@cs50.harvard.edu
]]

PlayerCarryItemWalkState = Class { __includes = EntityWalkState }

local statePrefix = 'carry-'

function PlayerCarryItemWalkState:init(player, dungeon)
  self.entity = player
  self.dungeon = dungeon

  -- render offset for spaced character sprite; negated in render function of state
  self.entity.offsetY = 5
  self.entity.offsetX = 0
end

function PlayerCarryItemWalkState:enter(dt)
  -- todo handle animation enter
end

function PlayerCarryItemWalkState:update(dt)
  self:handleKeyboardInput()

  -- EntityWalkState performs base collision detection against walls
  EntityWalkState.update(self, dt)
end

function PlayerCarryItemWalkState:enter(params)
  print("Enter PlayerCarryItemWalkState")
end

function PlayerCarryItemWalkState:render()
  EntityWalkState.render(self)
end

function PlayerCarryItemWalkState:handleKeyboardInput()
  -- update character animation based on movement direction
  local keyboarDirections = { 'up', 'down', 'left', 'right' }
  local dirPressed = false
  for _, keyDir in pairs(keyboarDirections) do
    if love.keyboard.isDown(keyDir) then
      self.entity.direction = keyDir
      local animationKey = statePrefix .. 'walk-' .. keyDir
      self.entity:changeAnimation(animationKey)
      dirPressed = true
    end
  end

  -- if no direction then back to idling
  if not dirPressed then
    local animationKey = statePrefix .. 'idle-' .. self.entity.direction
    self.entity:changeState('carry-item-idle')
    self.entity:changeAnimation(animationKey)
  end

  -- handle dropping the item
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    if self.entity.liftedItem then
      self.entity:dropItem()
      self.entity:changeState('walk')
    end
  end

  -- handle throwing the item
  if love.keyboard.wasPressed('space') then
    self.entity:throwItem(self.entity.liftedItem)
    self.entity:changeState('walk')
  end
end
