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
  -- animation enter handled by the player lift item state
end

function PlayerCarryItemWalkState:update(dt)
  self:handleKeyboardInput()

  -- EntityWalkState performs base collision detection against walls
  EntityWalkState.update(self, dt)


  -- handle entering another room, drop the item and exit into walk state
  if self.bumped then
    if self.entity.direction == 'left' then
      -- temporarily adjust position into the wall, since bumping pushes outward
      self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt

      -- check for colliding into doorway to transition
      for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
        if self.entity:collides(doorway) and doorway.open then
          -- shift entity to center of door to avoid phasing through wall
          self.entity.y = doorway.y + 4
          self.entity:dropItem()
          self.entity:changeState('walk')
          Event.dispatch('shift-left')
        end
      end

      -- readjust
      self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
    elseif self.entity.direction == 'right' then
      -- temporarily adjust position
      self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt

      -- check for colliding into doorway to transition
      for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
        if self.entity:collides(doorway) and doorway.open then
          -- shift entity to center of door to avoid phasing through wall
          self.entity.y = doorway.y + 4
          self.entity:dropItem()
          self.entity:changeState('walk')
          Event.dispatch('shift-right')
        end
      end

      -- readjust
      self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
    elseif self.entity.direction == 'up' then
      -- temporarily adjust position
      self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt

      -- check for colliding into doorway to transition
      for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
        if self.entity:collides(doorway) and doorway.open then
          -- shift entity to center of door to avoid phasing through wall
          self.entity.x = doorway.x + 8
          self.entity:dropItem()
          self.entity:changeState('walk')
          Event.dispatch('shift-up')
        end
      end

      -- readjust
      self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
    else
      -- temporarily adjust position
      self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt

      -- check for colliding into doorway to transition
      for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
        if self.entity:collides(doorway) and doorway.open then
          -- shift entity to center of door to avoid phasing through wall
          self.entity.x = doorway.x + 8
          self.entity:dropItem()
          self.entity:changeState('walk')
          Event.dispatch('shift-down')
        end
      end

      -- readjust
      self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
    end
  end
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
