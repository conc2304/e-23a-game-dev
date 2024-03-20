--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class { __includes = Entity }

function Player:init(def)
    Entity.init(self, def)
    local playerDef = Pokemon.getRandomDef()
    playerDef.baseAttack = playerDef.baseAttack * 10
    playerDef.baseSpeed = playerDef.baseSpeed * 10
    playerDef.baseHP = playerDef.baseHP * 10

    -- todo change back to 5
    self.party = Party {
        pokemon = {
            Pokemon(playerDef, 10)
            -- Pokemon(playerDef, 5)
        }
    }
end
