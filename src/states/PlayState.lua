PlayState = Class{__includes = BaseState}

function PlayState:init()
  self.paddle = Paddle()
  self.paused = false

  self.ball = Ball(math.random(7))

  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)

  self.ball.x = gameWidth / 2 - 4
  self.ball.y = gameHeight - 42
end

function PlayState:update(dt)
  if self.paused then
    if love.keyboard.wasPressed('space') then
      self.paused = false
      gSounds['pause']:play()
    else
      return
    end
  elseif love.keyboard.wasPressed('space') then
    self.paused = true
    gSounds['pause']:play()
    return
  end

  if self.ball:collides(self.paddle) then
    self.ball.y = gameHeight - 42
    self.ball.dy = -self.ball.dy
    gSounds['paddle-hit']:play()
  end

  self.paddle:update(dt)
  self.ball:update(dt)

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

function PlayState:render()
  self.paddle:render()
  self.ball:render()

  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, gameHeight / 2 - 16, gameWidth, 'center')
  end
end