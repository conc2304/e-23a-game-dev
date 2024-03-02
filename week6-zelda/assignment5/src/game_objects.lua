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
        },
        onCollide = function(self, room)
            local doorways = room.doorways
            if self.state == 'unpressed' then
                self.state = 'pressed'

                -- open every door in the room if we press the switch
                for k, doorway in pairs(doorways) do
                    doorway.open = true
                end

                gSounds['door']:play()
            end
        end
    },
    ['life'] = {
        type = 'life',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        consumable = true,
        onCollide = function(self, room, objIndex)
            local player = room.player
            local gameObjects = room.objects

            -- cap how much heart we can give
            player.health = player.health + HEALTH_PER_HEART
            player.health = math.min(player.health, MAX_HEALTH)

            -- remove from game
            table.remove(gameObjects, objIndex)

            gSounds['health-up']:play()
        end,
        defaultState = 'default',
        states = {
            ['default'] = {
                frame = 5
            },
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 14,
        width = 16,
        height = 16,
        solid = true,
        consumable = false,
        liftable = true,
        canDamage = false,
        damageAmount = 1,
        throwDistance = 4 * TILE_SIZE,

        onCollide = function(self, room, objIndex)
            if self.canDamage then
                self:onBreak()
            end
        end,
        defaultState = 'default',
        states = {
            ['default'] = {
                frame = 14
            },
            ['broken'] = {
                frame = 52
            }
        }
    }
}
