--[[
    GD50
    Legend of Zelda

    Author: NOT Colton Ogden
    notcogden@cs50.harvard.edu
]]

PlayerCarryItemWalkState = Class { __includes = PlayerWalkState }

local statePrefix = 'carry-'

function PlayerCarryItemWalkState:init(player, dungeon)
  self.entity = player
  self.dungeon = dungeon

  -- render offset for spaced character sprite; negated in render function of state
  self.entity.offsetY = 5
  self.entity.offsetX = 0
  print("INIT PlayerCarryItemWalkState")
end

function PlayerCarryItemWalkState:update(dt)
  -- self:handleKeyboardInput()

  -- perform base collision detection against walls
  PlayerWalkState:update(self, dt)
  print("UPDATE PlayerCarryItemWalkState")
end

function PlayerCarryItemWalkState:enter(params)
  print("Enter PlayerCarryItemWalkState")
end

function PlayerCarryItemWalkState:render()
  print("Render PlayerCarryItemWalkState")
end
