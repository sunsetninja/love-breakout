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
  -- 2. 'paddle-select' (where we get to choose the color of our paddle)
  -- 3. 'serve' (waiting on a key press to serve the ball)
  -- 4. 'play' (the ball is in play, bouncing between paddles)
  -- 5. 'victory' (the current level is over, with a victory jingle)
  -- 6. 'game-over' (the player has lost; display score and allow restart)
  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['serve'] = function() return ServeState() end,
    ['play'] = function() return PlayState() end,
    ['victory'] = function() return VictoryState() end,
    ['game-over'] = function() return GameOverState() end,
  }
  gStateMachine:change('start')

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

function displayFPS()
  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end