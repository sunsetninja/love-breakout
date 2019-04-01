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

  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })
end

function love.resize(w, h)
  push:resize(w,h)
end

function love.update(dt)
end

function love.keypressed(key)
end

function love.draw()
  push:apply('start')
  
  push:apply('end')
end