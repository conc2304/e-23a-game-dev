LevelUpMenuState = Class { __includes = BaseState }


function LevelUpMenuState:init(stats, onClose)
  -- this holds our levelling up states
  self.stats = stats

  -- function to be called once this dialog box is done
  self.onClose = onClose or function() end

  local items = {}     -- menu items
  local heightCalc = 0 -- make menu size dynamic

  for attributeName, value in pairs(stats) do
    -- we infer pre-levelled up state based on user's current state,
    -- and how much we increased it that attribute by
    local prev = value.curr - value.inc
    local gained = value.inc
    local next = value.curr

    -- one line item for the attribute name,
    -- the other for the stat change
    table.insert(items, {
      text = string.upper(attributeName),
      align = 'left',
      font = gFonts['medium']
    })
    table.insert(items, {
      -- the stats as prev+gained=next
      text = string.format("%d+%d = %d", prev, gained, next),
      align = 'right',
      font = gFonts['small']
    })

    -- use the larger of the two fonts to dynamically size our container
    heightCalc = heightCalc + (2 * gFonts['medium']:getHeight())
  end

  local width = 96
  local spacingY = 8 -- space it away from the bottom dialog
  local height = math.max(128, heightCalc) + spacingY
  local offsetY = 64 -- 64 is the height of the battle dialog box,

  -- make the menu
  self.levelUpMenu = Menu {
    x = VIRTUAL_WIDTH - width,
    y = VIRTUAL_HEIGHT - offsetY - spacingY - height,
    width = width,
    height = height,
    items = items,
    canSelect = false
  }
end

function LevelUpMenuState:update(dt)
  self.levelUpMenu:update(dt)

  -- on enter close up shop
  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
    self.onClose()
  end
end

function LevelUpMenuState:render()
  self.levelUpMenu:render()
end
