Powerup = Class{}

function Powerup:init(type)
  self.width = 16
  self.height = 16

  self.type = type

  self.inPlay = true
  self.x = math.random(50, gameWidth - 50)
  self.y = -self.height * 2
  self.dy = 50
end

function Powerup:collides(target)
  if self.x > target.x + target.width or target.x > self.x + self.width then
    return false
  end

  if self.y > target.y + target.height or target.y > self.y + self.height then
    return false
  end

  return true
end

function Powerup:update(dt)
  if self.inPlay then
    self.y = self.y + self.dy * dt
  end

  if self.y + self.height > gameHeight then
    self.inPlay = false
  end
end

function Powerup:render()
  if self.inPlay then
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type],
      self.x, self.y)
  end
end