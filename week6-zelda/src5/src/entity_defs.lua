--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

-- Texture Vars
CHAR_WALK_TXTR = 'character-walk'
CHAR_SWORD_TXTR = 'character-swing-sword'
CHAR_POT_LIFT_TXTR = 'character-pot-lift'
CHAR_POT_WALK_TXTR = 'character-pot-walk'

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
            -- POT LIFTER
            ['pot-lift-down'] = {
                frames = { 1, 2, 3 },
                interval = 0.3,
                looping = false,
                texture = CHAR_POT_LIFT_TXTR
            },
            ['pot-lift-right'] = {
                frames = { 4, 5, 6 },
                interval = 0.3,
                looping = false,
                texture = CHAR_POT_LIFT_TXTR
            },
            ['pot-lift-up'] = {
                frames = { 7, 8, 9 },
                interval = 0.3,
                looping = false,
                texture = CHAR_POT_LIFT_TXTR
            },
            ['pot-lift-left'] = {
                frames = { 10, 11, 12 },
                interval = 0.3,
                looping = false,
                texture = CHAR_POT_LIFT_TXTR
            },
            -- POT WALKER
            ['pot-walk-down'] = {
                frames = { 1, 2, 3, 4 },
                interval = 0.3,
                looping = true,
                texture = CHAR_POT_WALK_TXTR
            },
            ['pot-walk-right'] = {
                frames = { 5, 6, 7, 8 },
                interval = 0.3,
                looping = true,
                texture = CHAR_POT_WALK_TXTR
            },
            ['pot-walk-up'] = {
                frames = { 9, 10, 11, 12 },
                interval = 0.3,
                looping = true,
                texture = CHAR_POT_WALK_TXTR
            },
            ['pot-walk-left'] = {
                frames = { 13, 14, 15, 16 },
                interval = 0.3,
                looping = true,
                texture = CHAR_POT_WALK_TXTR
            },
            -- POT IDLER
            ['pot-idle-down'] = {
                frames = { 1 },
                texture = CHAR_POT_WALK_TXTR
            },
            ['pot-idle-right'] = {
                frames = { 5 },
                texture = CHAR_POT_WALK_TXTR
            },
            ['pot-idle-up'] = {
                frames = { 9 },
                texture = CHAR_POT_WALK_TXTR
            },
            ['pot-idle-left'] = {
                frames = { 13 },
                texture = CHAR_POT_WALK_TXTR
            },
        }
    },
    ['skeleton'] = {
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
    }
}
