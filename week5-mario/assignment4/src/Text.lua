Text = Class {}

function Text:init(def)
  self.text = def.text
  self.visible = def.visible

  -- position
  self.x = def.x
  self.y = def.y
  self.limit = def.limit or VIRTUAL_WIDTH
  self.alignment = def.alignment or 'center'

  -- typograghy
  self.font = def.font
  self.color = def.color
  self.hasShadow = def.hasShadow or false
end

function Text:render()
  -- if visible then render if not dont
  if self.visible then
    love.graphics.setFont(gFonts['title'])
    -- add shadow if we want that and its offset by 1 in xy
    if self.hasShadow then
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.printf(self.text, self.x + 1, self.y + 1, self.limit, self.alignment)
    end
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 255)
    love.graphics.printf(self.text, self.x, self.y, self.limit, self.alignment)
  end
end
