Paddle = Class{}

paddleSizes = {
  -- small
  [1] = 32,
  -- medium
  [2] = 64,
  -- large
  [3] = 96,
  -- extra large
  [4] = 128,
}

defaultPaddleSize = 2

function Paddle:init(skin)
  self.x = gameWidth / 2 - 32
  self.y = gameHeight - 32
  self.dx = 0

  self.size = defaultPaddleSize
  
  self.width = paddleSizes[self.size]
  self.height = 16

  self.skin = skin
end

function Paddle:update(dt)
  if love.keyboard.isDown('left') then
    self.dx = -paddleSpeed
  elseif love.keyboard.isDown('right') then
    self.dx = paddleSpeed
  else
    self.dx = 0
  end

  if self.dx < 0 then
    self.x = math.max(0, self.x + self.dx * dt)
  else
    self.x = math.min(gameWidth - self.width, self.x + self.dx * dt)
  end
end


function Paddle:render()
  love.graphics.draw(
    gTextures['main'],
    gFrames['paddles'][self.size + 4 * (self.skin - 1)],
    self.x, self.y
  )
end

function Paddle:setSize(size)
  local oldCenter = self.x + self.width / 2
  
  self.size = size
  self.width = paddleSizes[self.size]
  self.x = math.max(0, oldCenter - self.width / 2)
end

function Paddle:increaseSize()
  self:setSize(math.min(4, self.size + 1))
end

function Paddle:decreaseSize()
  self:setSize(math.max(1, self.size - 1))
end

function Paddle:resetSize()
  self:setSize(defaultPaddleSize)
end