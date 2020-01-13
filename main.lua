require("src/dependencies")

function love.load()
  love.window.setTitle('Love breakout')

  love.graphics.setDefaultFilter('nearest', 'nearest')
  
  math.randomseed(os.time())

  gFonts = {
    ['small'] = love.graphics.newFont('assets/fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('assets/fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('assets/fonts/font.ttf', 32)
  }
  love.graphics.setFont(gFonts['small'])

  gTextures = {
    ['background'] = love.graphics.newImage('assets/graphics/background.png'),
    ['main'] = love.graphics.newImage('assets/graphics/breakout.png'),
    ['arrows'] = love.graphics.newImage('assets/graphics/arrows.png'),
    ['hearts'] = love.graphics.newImage('assets/graphics/hearts.png'),
    ['particle'] = love.graphics.newImage('assets/graphics/particle.png')
  }

  gFrames = {
    ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
    ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
    ['balls'] = GenerateQuadsBalls(gTextures['main']),
    ['bricks'] = GenerateQuadsBricks(gTextures['main']),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9)
  }

  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })

  gSounds = {
    ['paddle-hit'] = love.audio.newSource('assets/sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('assets/sounds/score.wav', 'static'),
    ['wall-hit'] = love.audio.newSource('assets/sounds/wall_hit.wav', 'static'),
    ['confirm'] = love.audio.newSource('assets/sounds/confirm.wav', 'static'),
    ['select'] = love.audio.newSource('assets/sounds/select.wav', 'static'),
    ['no-select'] = love.audio.newSource('assets/sounds/no-select.wav', 'static'),
    ['brick-hit-1'] = love.audio.newSource('assets/sounds/brick-hit-1.wav', 'static'),
    ['brick-hit-2'] = love.audio.newSource('assets/sounds/brick-hit-2.wav', 'static'),
    ['hurt'] = love.audio.newSource('assets/sounds/hurt.wav', 'static'),
    ['victory'] = love.audio.newSource('assets/sounds/victory.wav', 'static'),
    ['recover'] = love.audio.newSource('assets/sounds/recover.wav', 'static'),
    ['high-score'] = love.audio.newSource('assets/sounds/high_score.wav', 'static'),
    ['pause'] = love.audio.newSource('assets/sounds/pause.wav', 'static'),

    ['music'] = love.audio.newSource('assets/sounds/music.wav', 'stream')
  }

  -- 1. 'start' (the beginning of the game, where we're told to press Enter)
  -- 2. 'high-scores' (the players high scores)
  -- 3. 'paddle-select' (where we get to choose the color of our paddle)
  -- 4. 'serve' (waiting on a key press to serve the ball)
  -- 5. 'play' (the ball is in play, bouncing between paddles)
  -- 6. 'victory' (the current level is over, with a victory jingle)
  -- 7. 'game-over' (the player has lost; display score and allow restart)
  -- 7. 'enter-high-score' (the player has lost; enter high score)
  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['high-scores'] = function() return HighScoreState() end,
    ['serve'] = function() return ServeState() end,
    ['paddle-select'] = function() return PaddleSelectState() end,
    ['play'] = function() return PlayState() end,
    ['victory'] = function() return VictoryState() end,
    ['game-over'] = function() return GameOverState() end,
    ['enter-high-score'] = function() return EnterHighScoreState() end
  }
  gStateMachine:change('start', {
    highScores = loadHighScores()
  })

  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w,h)
end

function love.update(dt)
  gStateMachine:update(dt)

  love.keyboard.keysPressed = {}
end

function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
  if love.keyboard.keysPressed[key] then
    return true
  else
    return false
  end
end

function love.draw()
  push:apply('start')

  local backgroundWidth = gTextures['background']:getWidth()
  local backgroundHeight = gTextures['background']:getHeight()

  love.graphics.draw(
    gTextures['background'],
    0, 0,
    0,
    gameWidth / (backgroundWidth - 1), gameHeight / (backgroundHeight - 1)
  )

  gStateMachine:render()

  displayFPS()
  push:apply('end')
end

function renderHealth(health)
  local healthX = gameWidth - 100

  for i = 1, health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
    healthX = healthX + 11
  end

  for i = 1, 3 - health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
    healthX = healthX + 11
  end
end

function renderScore(score)
  love.graphics.setFont(gFonts['small'])
  love.graphics.print('Score:', gameWidth - 60, 5)
  love.graphics.printf(tostring(score), gameWidth - 50, 5, 40, 'right')
end

--[[
  Loads high scores from a .lst file, saved in LÖVE2D's default save directory in a subfolder
  called 'breakout'.
]]
function loadHighScores()
  love.filesystem.setIdentity('breakout')

  -- if the file doesn't exist, initialize it with some default scores
  if not love.filesystem.exists('breakout.lst') then
    local scores = ''
    for i = 10, 1, -1 do
      scores = scores .. 'CTO\n'
      scores = scores .. tostring(i * 500) .. '\n'
    end

    love.filesystem.write('breakout.lst', scores)
  end

  local name = true
  local currentName = nil
  local counter = 1

  local scores = {}

  for i = 1, 10 do
    scores[i] = {
      name = nil,
      score = nil
    }
  end

  for line in love.filesystem.lines('breakout.lst') do
    if name then
      scores[counter].name = string.sub(line, 1, 3)
    else
      scores[counter].score = tonumber(line)
      counter = counter + 1
    end

    name = not name
  end

  return scores
end

function displayFPS()
  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end