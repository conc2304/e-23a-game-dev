LevelUpMenuState = Class { __includes = BaseState }

function LevelUpMenuState:init(stats, onClose)
  self.stats = stats

  -- function to be called once this message is popped
  self.onClose = onClose or function() end


  local items = {}
  local heightCalc = 0

  for key, value in pairs(stats) do
    local prev = value.curr - value.inc
    local gained = value.inc
    local next = value.curr
    -- one line itemfor the attribute name, the other for the stat change
    table.insert(items, {
      text = string.upper(key),
      align = 'left',
      font = gFonts['medium']
    })
    table.insert(items, {
      text = string.format("%d+%d=%d", prev, gained, next),
      align = 'right',
      font = gFonts['small']
    })
    heightCalc = heightCalc + (2 * gFonts['medium']:getHeight() + 2)
  end

  local width = 96
  local height = math.max(128, heightCalc)
  local offsetY = 64 -- 64 is the height of the battle dialog box,
  local spacingY = 8 -- space it away from the bottom dialog

  print("LEVEL UP MENU")


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

  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
    print("end state")
    self.onClose()
  end
end

function LevelUpMenuState:render()
  self.levelUpMenu:render()
end
