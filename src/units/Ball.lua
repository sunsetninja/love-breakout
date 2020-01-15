Ball = Class{}

ballSizes = {
  -- small
  [1] = 4,
  -- medium
  [2] = 8,
  -- large
  [3] = 12,
}

defaultBallSize = 2

function Ball:init(skin, index)
  self.x = 0
  self.y = 0
  self.dy = 0
  self.dx = 0
  self.index = index
  
  self.size = defaultBallSize
  self.width = ballSizes[self.size]
  self.height = ballSizes[self.size]
  
  self.skin = skin
end

function Ball:collides(target)
  if self.x > target.x + target.width or target.x > self.x + self.width then
    return false
  end

  if self.y > target.y + target.height or target.y > self.y + self.height then
    return false
  end 

  return true
end

function Ball:reset()
  self.x = gameWidth / 2 - 2
  self.y = gameHeight / 2 - 2
  
  self.dx = 0
  self.dy = 0
end

function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt

  if self.x <= 0 then
    self.x = 0
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end

  if self.x >= gameWidth - self.width then
    self.x = gameWidth - self.width
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end

  if self.y <= 0 then
    self.y = 0
    self.dy = -self.dy
    gSounds['wall-hit']:play()
  end
end

function Ball:render()
  love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin],
    self.x, self.y, 0,
    self.width / ballSizes[defaultBallSize],
    self.height / ballSizes[defaultBallSize]
  )
end

function Ball:setSize(size)
  local oldCenterX = self.x + self.width / 2
  local oldCenterY = self.y + self.height / 2
  
  self.size = size
  self.width = ballSizes[self.size]
  self.height = ballSizes[self.size]
  self.x = math.max(0, oldCenterX - self.width / 2)
  self.y = math.max(0, oldCenterY - self.height / 2)
end

function Ball:increaseSize()
  self:setSize(math.min(3, self.size + 1))
end

function Ball:decreaseSize()
  self:setSize(math.max(1, self.size - 1))
end