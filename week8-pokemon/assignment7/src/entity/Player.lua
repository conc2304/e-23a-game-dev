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

    self.party = Party {
        pokemon = {
            Pokemon(playerDef, 5)
        }
    }
end
