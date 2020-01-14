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
  self.ball.inGame = true
  self.balls = {
    [1] = self.ball,
  }
  self.ballsCount = 1
  
  self.recoverPoints = params.recoverPoints
  self.powerup = nil
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

  -- powerups
  if self.powerup and self.powerup.inGame then
    if self.powerup:collides(self.paddle) then
      self.powerup.inGame = false

      if not (self.powerup.type == 4) then
        self.score = self.score + 200
      end

      if self.powerup.type == 3 then
        self.health = math.min(3, self.health + 1)
      end
      
      if self.powerup.type == 4 then
        self:takeHealth()
      end
      
      if self.powerup.type == 5 then
        self.paddle:increaseSize()
      end
      
      if self.powerup.type == 6 then
        self.paddle:decreaseSize()
      end

      if self.powerup.type == 7 then
        for b, ball in pairs(self.balls) do
          ball:decreaseSize()
        end
      end
      
      if self.powerup.type == 8 then
        for b, ball in pairs(self.balls) do
          ball:increaseSize()
        end
      end

      if self.powerup.type == 9 and self.ballsCount < 3 then
        local extraBallIndex = self.ballsCount + 1

        for key, value in pairs(self.balls) do
          if not value.inGame then
            extraBallIndex = key
          end
        end

        local extraBall = Ball(math.random(7), extraBallIndex)
        extraBall.inGame = true
        extraBall.x = self.paddle.x + (self.paddle.width / 2) - 4
        extraBall.y = self.paddle.y - 8
        extraBall.dx = math.random(-200, 200)
        extraBall.dy = math.random(-60, -70)
        
        self.balls[extraBallIndex] = extraBall
        self.ballsCount = self.ballsCount + 1
      end
    end
  else
    self.powerup = Powerup(math.random(3, 9))
  end

  -- balls
  for b, ball in pairs(self.balls) do
    if ball.inGame then
      ball:update(dt)

      if ball:collides(self.paddle) then
        ball.y = self.paddle.y - 8
        ball.dy = -ball.dy
    
        -- left side of the paddle
        if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
          ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
        -- right side of the paddle
        elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
          ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
        end
        
        gSounds['paddle-hit']:play()
      end

      for k, brick in pairs(self.bricks) do
        brick:update(dt)
        
        if brick.inPlay and ball:collides(brick) then
          brick:hit()
          
          self.score = self.score + (brick.tier * 200 + brick.color * 25)

          if self.score > self.recoverPoints then
            self.health = math.min(3, self.health + 1)

            self.recoverPoints = math.min(100000, self.recoverPoints * 2)

            gSounds['recover']:play()
          end

          if self:checkVictory() then
            gSounds['victory']:play()
            self.paddle:resetSize()

            gStateMachine:change('victory', {
              level = self.level,
              paddle = self.paddle,
              health = self.health,
              score = self.score,
              ball = self.balls[1],
              recoverPoints = self.recoverPoints
            })
          end

          -- left edge; (+2 for set by x as priority collision)
          if ball.x + 2 < brick.x and ball.dx > 0 then
            ball.dx = -ball.dx
            ball.x = brick.x - 8
          
          -- right edge; (+6 for set by x as priority collision)
          elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
            ball.dx = -ball.dx
            ball.x = brick.x + 32
          
          -- top edge;
          elseif ball.y < brick.y then
            ball.dy = -ball.dy
            ball.y = brick.y - 8
          
          -- bottom edge;
          else
            ball.dy = -ball.dy
            ball.y = brick.y + 16
          end

          ball.dy = ball.dy * 1.02
          break
        end
      end

      
      if ball.y >= gameHeight and ball.inGame then
        local lastBall = self.ballsCount == 1
        ball.inGame = false
        self.ballsCount = math.max(0, self.ballsCount - 1)
        
        if lastBall then
          self:takeHealth()
        end
      end
    end
  end

  self.paddle:update(dt)
  
  if self.powerup and self.powerup.inGame then
    self.powerup:update(dt)
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

  for b, ball in pairs(self.balls) do
    if ball.inGame then
      ball:render()
    end
  end
  
  if self.powerup then
    self.powerup:render()
  end

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

function PlayState:takeHealth()
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
      highScores = self.highScores,
      recoverPoints = self.recoverPoints
    })
  end
end