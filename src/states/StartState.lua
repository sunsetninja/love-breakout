StartState = Class{__includes = BaseState}

local highlighted = 1;

function StartState:update(dt)
  if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
    highlighted = highlighted == 1 and 2 or 1
    gSounds['paddle-hit']:play()
  end

  -- confirm whichever option we have selected to change screens
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gSounds['confirm']:play()

    if highlighted == 1 then
      gStateMachine:change('play')
    end
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

function StartState:render()
  -- title
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf("BREAKOUT",
    0, gameHeight / 3,
    gameWidth, 'center'
  )
  
  -- instructions
  love.graphics.setFont(gFonts['medium'])

  -- if we're highlighting 1, render that option blue
  if highlighted == 1 then
    love.graphics.setColor(0, 255, 255, 255)
  end
  love.graphics.printf("START",
    0, gameHeight / 2 + 70,
    gameWidth, 'center'
  )

  -- reset the color
  love.graphics.setColor(255, 255, 255, 255)

  -- render option 2 blue if we're highlighting that one
  if highlighted == 2 then
      love.graphics.setColor(0, 255, 255, 255)
  end
  love.graphics.printf("HIGH SCORES",
    0, gameHeight / 2 + 90,
    gameWidth, 'center'
  )

  -- reset the color
  love.graphics.setColor(255, 255, 255, 255)
end