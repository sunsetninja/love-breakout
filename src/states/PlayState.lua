PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.score = params.score
  self.highScores = params.highScores
  self.health = params.health
  self.level = params.level
  self.ball = params.ball
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-60, -70)
  self.recoverPoints = params.recoverPoints

  self.paused = false
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
    self.ball.y = self.paddle.y - 8
    self.ball.dy = -self.ball.dy

    -- left side of the paddle
    if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
      self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
    -- right side of the paddle
    elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
      self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
    end
    
    gSounds['paddle-hit']:play()
  end

  for k, brick in pairs(self.bricks) do
    brick:update(dt)
    
    if brick.inPlay and self.ball:collides(brick) then
      brick:hit()
      
      self.score = self.score + (brick.tier * 200 + brick.color * 25)

      if self.score > self.recoverPoints then
        self.health = math.min(3, self.health + 1)

        self.recoverPoints = math.min(100000, self.recoverPoints * 2)

        gSounds['recover']:play()
      end

      if self:checkVictory() then
        gSounds['victory']:play()

        gStateMachine:change('victory', {
          level = self.level,
          paddle = self.paddle,
          health = self.health,
          score = self.score,
          ball = self.ball,
          recoverPoints = self.recoverPoints
        })
      end

      -- left edge; (+2 for set by x as priority collision)
      if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x - 8
      
      -- right edge; (+6 for set by x as priority collision)
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

  if self.ball.y >= gameHeight then
    self.health = self.health - 1
    gSounds['hurt']:play()

    if self.health == 0 then
      gStateMachine:change('game-over', {
        score = self.score,
        highScores = self.highScores
      })
    else
      gStateMachine:change('serve', {
        paddle = self.paddle,
        bricks = self.bricks,
        health = self.health,
        score = self.score,
        level = self.level,
        recoverPoints = self.recoverPoints
      })
    end
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

function PlayState:render()
  for k, brick in pairs(self.bricks) do
    brick:render()
  end

  for k, brick in pairs(self.bricks) do
    brick:renderParticles()
  end
  
  self.paddle:render()
  self.ball:render()

  renderScore(self.score)
  renderHealth(self.health)

  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, gameHeight / 2 - 16, gameWidth, 'center')
  end
end

function PlayState:checkVictory()
  for k, brick in pairs(self.bricks) do
    if brick.inPlay then
      return false
    end
  end

  return true
end