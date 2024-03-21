--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Selection class gives us a list of textual items that link to callbacks;
    this particular implementation only has one dimension of items (vertically),
    but a more robust implementation might include columns as well for a more
    grid-like selection, as seen in many kinds of interfaces and games.
]]

Selection = Class {}

function Selection:init(def)
    self.items = def.items
    -- default to canSelect is true if not passed in
    self.canSelect = def.canSelect == nil and true or def.canSelect

    self.x = def.x
    self.y = def.y

    self.height = def.height
    self.width = def.width
    self.font = def.font or gFonts['small']

    self.gapHeight = self.height / #self.items

    self.currentSelection = 1
end

function Selection:update(dt)
    if not self.canSelect then
        return
    end

    if love.keyboard.wasPressed('up') then
        if self.currentSelection == 1 then
            self.currentSelection = #self.items
        else
            self.currentSelection = self.currentSelection - 1
        end

        gSounds['blip']:stop()
        gSounds['blip']:play()
    elseif love.keyboard.wasPressed('down') then
        if self.currentSelection == #self.items then
            self.currentSelection = 1
        else
            self.currentSelection = self.currentSelection + 1
        end

        gSounds['blip']:stop()
        gSounds['blip']:play()
    elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        if self.items[self.currentSelection].onSelect then self.items[self.currentSelection].onSelect() end

        gSounds['blip']:stop()
        gSounds['blip']:play()
    end
end

function Selection:render()
    local currentY = self.y
    local currFont = love.graphics.getFont()

    for i = 1, #self.items do
        -- allow items to use different fonts if they are set
        if self.items[i].font then
            love.graphics.setFont(self.items[i].font)
        end

        local paddedY = currentY + (self.gapHeight / 2) - love.graphics.getFont():getHeight() / 2
        -- allow different alignments of text
        local align = self.items[i].align or 'center'
        local padX = 0
        -- pad our left/right aligned text so its not on top of the menu border
        if align == 'left' then padX = 8 end
        if align == 'right' then padX = -8 end

        -- draw selection marker if we're at the right index, if we need one
        if i == self.currentSelection and self.canSelect then
            love.graphics.draw(gTextures['cursor'], self.x - 8, paddedY)
        end

        love.graphics.printf(self.items[i].text, self.x + padX, paddedY, self.width, align)

        currentY = currentY + self.gapHeight
    end

    -- reset the font to what it was before
    love.graphics.setFont(currFont)
end
