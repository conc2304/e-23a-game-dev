--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['life'] = {
        type = 'life',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        consumable = true,
        onCollide = function(self, player, gameObjects, objIndex)
            -- cap how much heart we can give
            player.health = player.health + HEALTH_PER_HEART
            player.health = math.min(player.health, MAX_HEALTH)
            self.visible = false
            table.remove(gameObjects, objIndex)

            gSounds['health-up']:play()
        end,
        defaultState = 'unconsumed',
        states = {
            ['unconsumed'] = {
                frame = 5
            },
            ['consumed'] = {
                frame = 1
            }
        }

    },
    ['pot'] = {
        -- TODO
    }
}
