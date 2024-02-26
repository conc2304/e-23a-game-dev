Text = Class {}

function Text:init(def)
  self.text = def.text

  -- position
  self.x = def.x
  self.y = def.y
  self.limit = def.limit or VIRTUAL_WIDTH
  self.alignment = def.alignment or 'center'
  self.font = def.font
  self.color = def.color
  self.visible = def.visible
  self.hasShadow = def.hasShadow or false
end

function Text:render()
  if self.visible then
    love.graphics.setFont(gFonts['title'])
    if self.hasShadow then
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.printf(self.text, self.x + 1, self.y + 1, self.limit, self.alignment)
    end
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 255)
    love.graphics.printf(self.text, self.x, self.y, self.limit, self.alignment)
  end
end
