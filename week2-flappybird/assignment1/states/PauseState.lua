PauseState = Class { __inclueds = BaseState }


PAUSE_IMAGE = love.graphics.newImage('pause-icon.png')

function PauseState:init()
  -- Do nothing
end

function PauseState:update(dt)
  -- if we are in the Pause State and the user preses pause again
  -- then go into the countdown state, which at its end goes into play state
  if love.keyboard.wasPressed(PAUSE_KEY) then
    gStateMachine:change('countdown', { prevPlayState = self.prevPlayState })
  end
end

function PauseState:render()
  love.graphics.setFont(hugeFont)
  love.graphics.printf("Pause", 0, 150, VIRTUAL_WIDTH, 'center')
  local scale = 0.75
  love.graphics.draw(PAUSE_IMAGE, VIRTUAL_WIDTH / 2 - ((PAUSE_IMAGE:getWidth() * scale) / 2), 80, 0, scale, scale)
end

function PauseState:enter(prevPlayState)
  -- get the
  self.prevPlayState = prevPlayState

  -- regardless of whether other states manage scrolling, we want this behaviour
  scrolling = false
  sounds['music']:pause()
  sounds['pauseEnter']:play()
end

function PauseState:exit()
  sounds['music']:play()
  sounds['pauseExit']:play()
end
