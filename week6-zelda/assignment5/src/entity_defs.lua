--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

NPC_ENTITY_WIDTH, NPC_ENNTITY_HEIGHT = 16, 16
NPC_WALK_SPEED = 20

POWER_UP_PROB_MAX = 100

-- Texture Vars
CHAR_WALK_TXTR = 'character-walk'
CHAR_SWORD_TXTR = 'character-swing-sword'
CHAR_ITEM_LIFT_TXTR = 'character-item-lift'
CHAR_ITEM_LIFT_INTERVAL = 0.08
CHAR_ITEM_WALK_TXTR = 'character-item-walk'

-- lets not have multiple places in the code where we define our entities
ENTITY_DEFS = {
    ['player'] = {
        walkSpeed = PLAYER_WALK_SPEED,
        animations = {
            ['walk-left'] = {
                frames = { 13, 14, 15, 16 },
                interval = 0.155,
                texture = CHAR_WALK_TXTR
            },
            ['walk-right'] = {
                frames = { 5, 6, 7, 8 },
                interval = 0.15,
                texture = CHAR_WALK_TXTR
            },
            ['walk-down'] = {
                frames = { 1, 2, 3, 4 },
                interval = 0.15,
                texture = CHAR_WALK_TXTR
            },
            ['walk-up'] = {
                frames = { 9, 10, 11, 12 },
                interval = 0.15,
                texture = CHAR_WALK_TXTR
            },
            ['idle-left'] = {
                frames = { 13 },
                texture = CHAR_WALK_TXTR
            },
            ['idle-right'] = {
                frames = { 5 },
                texture = CHAR_WALK_TXTR
            },
            ['idle-down'] = {
                frames = { 1 },
                texture = CHAR_WALK_TXTR
            },
            ['idle-up'] = {
                frames = { 9 },
                texture = CHAR_WALK_TXTR
            },
            -- SWORD SWING
            ['sword-left'] = {
                frames = { 13, 14, 15, 16 },
                interval = 0.05,
                looping = false,
                texture = CHAR_SWORD_TXTR
            },
            ['sword-right'] = {
                frames = { 9, 10, 11, 12 },
                interval = 0.05,
                looping = false,
                texture = CHAR_SWORD_TXTR
            },
            ['sword-down'] = {
                frames = { 1, 2, 3, 4 },
                interval = 0.05,
                looping = false,
                texture = CHAR_SWORD_TXTR
            },
            ['sword-up'] = {
                frames = { 5, 6, 7, 8 },
                interval = 0.05,
                looping = false,
                texture = CHAR_SWORD_TXTR
            },
            -- ITEM LIFTER
            ['lift-down'] = {
                frames = { 1, 2, 3 },
                interval = CHAR_ITEM_LIFT_INTERVAL,
                looping = false,
                texture = CHAR_ITEM_LIFT_TXTR
            },
            ['lift-right'] = {
                frames = { 4, 5, 6 },
                interval = CHAR_ITEM_LIFT_INTERVAL,
                looping = false,
                texture = CHAR_ITEM_LIFT_TXTR
            },
            ['lift-up'] = {
                frames = { 7, 8, 9 },
                interval = CHAR_ITEM_LIFT_INTERVAL,
                looping = false,
                texture = CHAR_ITEM_LIFT_TXTR
            },
            ['lift-left'] = {
                frames = { 10, 11, 12 },
                interval = CHAR_ITEM_LIFT_INTERVAL,
                looping = false,
                texture = CHAR_ITEM_LIFT_TXTR
            },
            -- CARRY ITEM WALKER
            ['carry-walk-down'] = {
                frames = { 1, 2, 3, 4 },
                interval = 0.3,
                texture = CHAR_ITEM_WALK_TXTR
            },
            ['carry-walk-right'] = {
                frames = { 5, 6, 7, 8 },
                interval = 0.3,
                texture = CHAR_ITEM_WALK_TXTR
            },
            ['carry-walk-up'] = {
                frames = { 9, 10, 11, 12 },
                interval = 0.3,
                looping = true,
                texture = CHAR_ITEM_WALK_TXTR
            },
            ['carry-walk-left'] = {
                frames = { 13, 14, 15, 16 },
                interval = 0.3,
                texture = CHAR_ITEM_WALK_TXTR
            },
            -- ITEM CARRY IDLER
            ['carry-idle-down'] = {
                frames = { 1 },
                texture = CHAR_ITEM_WALK_TXTR
            },
            ['carry-idle-right'] = {
                frames = { 5 },
                texture = CHAR_ITEM_WALK_TXTR
            },
            ['carry-idle-up'] = {
                frames = { 9 },
                texture = CHAR_ITEM_WALK_TXTR
            },
            ['carry-idle-left'] = {
                frames = { 13 },
                texture = CHAR_ITEM_WALK_TXTR
            },
        }
    },
    ['skeleton'] = {
        health = 10,
        walkSpeed = NPC_WALK_SPEED * 1,
        probOfExtraLife = 55,
        width = NPC_ENTITY_WIDTH,
        height = NPC_ENNTITY_HEIGHT,
        texture = 'entities',
        animations = {
            ['walk-left'] = {
                frames = { 22, 23, 24, 23 },
                interval = 0.2
            },
            ['walk-right'] = {
                frames = { 34, 35, 36, 35 },
                interval = 0.2
            },
            ['walk-down'] = {
                frames = { 10, 11, 12, 11 },
                interval = 0.2
            },
            ['walk-up'] = {
                frames = { 46, 47, 48, 47 },
                interval = 0.2
            },
            ['idle-left'] = {
                frames = { 23 }
            },
            ['idle-right'] = {
                frames = { 35 }
            },
            ['idle-down'] = {
                frames = { 11 }
            },
            ['idle-up'] = {
                frames = { 47 }
            }
        }
    },
    ['slime'] = {
        health = 2,
        walkSpeed = NPC_WALK_SPEED * 0.5,
        probOfExtraLife = 40,
        width = NPC_ENTITY_WIDTH,
        height = NPC_ENNTITY_HEIGHT,
        texture = 'entities',
        animations = {
            ['walk-left'] = {
                frames = { 61, 62, 63, 62 },
                interval = 0.2
            },
            ['walk-right'] = {
                frames = { 73, 74, 75, 74 },
                interval = 0.2
            },
            ['walk-down'] = {
                frames = { 49, 50, 51, 50 },
                interval = 0.2
            },
            ['walk-up'] = {
                frames = { 86, 86, 87, 86 },
                interval = 0.2
            },
            ['idle-left'] = {
                frames = { 62 }
            },
            ['idle-right'] = {
                frames = { 74 }
            },
            ['idle-down'] = {
                frames = { 50 }
            },
            ['idle-up'] = {
                frames = { 86 }
            }
        }
    },
    ['bat'] = {
        health = 1,
        walkSpeed = NPC_WALK_SPEED * 1.5,
        probOfExtraLife = 25,
        width = NPC_ENTITY_WIDTH,
        height = NPC_ENNTITY_HEIGHT,
        texture = 'entities',
        animations = {
            ['walk-left'] = {
                frames = { 64, 65, 66, 65 },
                interval = 0.2
            },
            ['walk-right'] = {
                frames = { 76, 77, 78, 77 },
                interval = 0.2
            },
            ['walk-down'] = {
                frames = { 52, 53, 54, 53 },
                interval = 0.2
            },
            ['walk-up'] = {
                frames = { 88, 89, 90, 89 },
                interval = 0.2
            },
            ['idle-left'] = {
                frames = { 64, 65, 66, 65 },
                interval = 0.2
            },
            ['idle-right'] = {
                frames = { 76, 77, 78, 77 },
                interval = 0.2
            },
            ['idle-down'] = {
                frames = { 52, 53, 54, 53 },
                interval = 0.2
            },
            ['idle-up'] = {
                frames = { 88, 89, 90, 89 },
                interval = 0.2
            }
        }
    },
    ['ghost'] = {
        health = 2,
        walkSpeed = NPC_WALK_SPEED * 1.25,
        probOfExtraLife = 30,
        width = NPC_ENTITY_WIDTH,
        height = NPC_ENNTITY_HEIGHT,
        texture = 'entities',
        animations = {
            ['walk-left'] = {
                frames = { 67, 68, 69, 68 },
                interval = 0.2
            },
            ['walk-right'] = {
                frames = { 79, 80, 81, 80 },
                interval = 0.2
            },
            ['walk-down'] = {
                frames = { 55, 56, 57, 56 },
                interval = 0.2
            },
            ['walk-up'] = {
                frames = { 91, 92, 93, 92 },
                interval = 0.2
            },
            ['idle-left'] = {
                frames = { 68 }
            },
            ['idle-right'] = {
                frames = { 80 }
            },
            ['idle-down'] = {
                frames = { 56 }
            },
            ['idle-up'] = {
                frames = { 92 }
            }
        }
    },
    ['spider'] = {
        health = 1,
        walkSpeed = NPC_WALK_SPEED,
        probOfExtraLife = 10,
        width = NPC_ENTITY_WIDTH,
        height = NPC_ENNTITY_HEIGHT,
        texture = 'entities',
        animations = {
            ['walk-left'] = {
                frames = { 70, 71, 72, 71 },
                interval = 0.2
            },
            ['walk-right'] = {
                frames = { 82, 83, 84, 83 },
                interval = 0.2
            },
            ['walk-down'] = {
                frames = { 58, 59, 60, 59 },
                interval = 0.2
            },
            ['walk-up'] = {
                frames = { 94, 95, 96, 95 },
                interval = 0.2
            },
            ['idle-left'] = {
                frames = { 71 }
            },
            ['idle-right'] = {
                frames = { 83 }
            },
            ['idle-down'] = {
                frames = { 59 }
            },
            ['idle-up'] = {
                frames = { 95 }
            }
        }
    },
    ['baby'] = {
        texture = 'entities',
        animations = {
            ['walk-left'] = {
                frames = { 13, 14, 15, 14 },
                interval = 0.2
            },
            ['walk-right'] = {
                frames = { 82, 83, 84, 83 },
                interval = 0.2
            },
            ['walk-down'] = {
                frames = { 58, 59, 60, 59 },
                interval = 0.2
            },
            ['walk-up'] = {
                frames = { 94, 95, 96, 95 },
                interval = 0.2
            },
            ['idle-left'] = {
                frames = { 71 }
            },
            ['idle-right'] = {
                frames = { 83 }
            },
            ['idle-down'] = {
                frames = { 59 }
            },
            ['idle-up'] = {
                frames = { 95 }
            }
        }
    }
}
