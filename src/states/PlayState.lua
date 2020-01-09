PlayState = Class{__includes = BaseState}

function PlayState:init()
  self.paddle = Paddle()
  self.paused = false

  self.ball = Ball(math.random(7))

  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)

  self.ball.x = gameWidth / 2 - 4
  self.ball.y = gameHeight - 42

  self.bricks = LevelMaker.createMap()
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

  for k, brick in pairs(self.bricks) do
    if brick.inPlay and self.ball:collides(brick) then
      brick:hit()

      -- left edge;
      if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x - 8
      
      -- right edge;
      elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x + 32
      
      -- top edge;
      elseif self.ball.y < brick.y then
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y - 8
      
      -- bottom edge;
      else
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y + 16
      end
      
      self.ball.dy = self.ball.dy * 1.02
      break
    end
  end

  self.paddle:update(dt)
  self.ball:update(dt)

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

function PlayState:render()
  for k, brick in pairs(self.bricks) do
    brick:render()
  end
  
  self.paddle:render()
  self.ball:render()

  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, gameHeight / 2 - 16, gameWidth, 'center')
  end
end