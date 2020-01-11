GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
  self.score = params.score
end

function GameOverState:update(dt)
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('start')
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

function GameOverState:render()
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('GAME OVER', 0, gameHeight / 3, gameWidth, 'center')
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Final Score: ' .. tostring(self.score), 0, gameHeight / 2,
    gameWidth, 'center')
  love.graphics.printf('Press Enter!', 0, gameHeight - gameHeight / 4,
    gameWidth, 'center')
end