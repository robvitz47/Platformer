local player = {
  x = 100,
  y = 100,
  width = 20,
  height = 20,
  velocity_x = 300,
  velocity_y = 0,
  jump_height = 10,
  jump_speed = 500,
  max_fall_speed = 4000,
  gravity = 600,
  speed = 100
}

local ground = {
  y = 735
}


local enemy = {
  x = 400,
  y = 400,
  width = 30,
  height = 30,
  image = love.graphics.newImage("sprites/enemy.png"),
  scored = false,
  is_alive = true
}

local enemy2 = {
  x = 400,
  y = 400,
  width = 30,
  height = 30,
  image = love.graphics.newImage("sprites/enemy2.png"),
  scored = false,
  is_alive = false
}
local high_score_value = 0
local high_scores = {}
local score_value = 0
local score = {
  name = "",
  value = score_value
}

local tiles = {}
local tile_size = 50
local tile_image = love.graphics.newImage("sprites/tile.png")
local background_image = love.graphics.newImage("sprites/background.png")
local knight = love.graphics.newImage("sprites/knight.png")
local background_x = 0
local jump_sound = love.audio.newSource("sprites/jump.wav", "static")
local enemy_hit = love.audio.newSource("sprites/hit_damage.wav", "static")
local boss_hit = love.audio.newSource("sprites/boss_hit.wav", "static")
local background_music = love.audio.newSource("sprites/background_music.wav", "static")
local start_screen = false
local is_paused = false
local enemy2_timer = 10  -- enemy2 will appear every 10 seconds
local enemy2_delay = enemy2_timer
local font = love.graphics.newFont()
local level = 1

function love.load()
  background_music:play()
  background_music:setLooping(true)
  player.x = 100 -- change the spawn x position
  player.y = 100 -- change the spawn y position
  enemy.is_alive = true

  -- Generate random x position for enemy
  enemy.x = 500

-- Set y position to the ground
  enemy.y = ground.y + enemy.height - 65

-- Generate initial tiles
  for i = 0, love.graphics.getWidth() / tile_size do
    for j = 0, love.graphics.getHeight() / tile_size do
      tiles[#tiles + 1] = {
        x = i * tile_size,
        y = j * tile_size
      }
    end
  end
end

function love.update(dt)
  if score_value >= 10 then
    level = level + 1
    score_value = 0
  end
  
  enemy2_delay = enemy2_delay - dt

  -- Check if the timer has elapsed
  if enemy2_delay <= 0 then
    enemy2.x = math.random(0, love.graphics.getWidth() - enemy2.width) * 2.5
    enemy2.y = ground.y + enemy2.height - 65
    enemy2.is_alive = true
    enemy2_delay = enemy2_timer
  end

  if is_paused then
    return
  end

  -- Apply gravity
  player.velocity_y = player.velocity_y + player.gravity * dt

  player.y = player.y + player.velocity_y * dt

  -- Limit player's fall velocity
  if player.velocity_y > player.max_fall_speed then
    player.velocity_y = player.max_fall_speed
  end 

  if player.y + player.height > ground.y then
    player.y = ground.y - player.height
    player.velocity_y = 0
  end

    player.x = player.x + player.velocity_x * dt
  
    background_x = background_x - player.velocity_x * dt

  -- Check if player has reached edge of screen
  if player.x + player.width >= love.graphics.getWidth() then
    -- Generate new tiles to the right of the screen
    for i = 0, love.graphics.getHeight() / tile_size do
      tiles[#tiles + 1] = {
        x = love.graphics.getWidth(),
        y = i * tile_size
      }
    end
  end
  if love.keyboard.isDown("a") then
    player.velocity_x = player.velocity_x - player.speed * dt
  elseif love.keyboard.isDown("d") then
    player.velocity_x = player.velocity_x + player.speed * dt
  else
    player.velocity_x = 0
  end
  if love.keyboard.isDown("space") then
    player.velocity_y = -player.jump_speed
    player.state = "jumping"
    jump_sound:play()
  end

  background_x = background_x + dt * 100

  -- Prevent player from running off the left side of the screen
  if player.x < 0 then
    player.x = 0
  end
  if not enemy.scored and player.x + player.width >= enemy.x and player.x <= enemy.x + enemy.width and
  player.y + player.height <= enemy.y and player.y + player.height >= enemy.y - enemy.height then

    -- Check if player is hitting enemy from above
  if player.y + player.height <= enemy.y then
      if enemy.is_alive then
        -- Kill the enemy
        enemy.is_alive = false

        -- Set the enemy's `scored` flag to `true`
        enemy.scored = true

        --play sound 
        enemy_hit:play()

        -- Update the score and the high scores
        score_value = score_value + 0
        high_scores[#high_scores + 1] = score_value
      end
  end
end

if not enemy2.scored and player.x + player.width >= enemy2.x and player.x <= enemy2.x + enemy2.width and
  player.y + player.height <= enemy2.y and player.y + player.height >= enemy2.y - enemy2.height then

    -- Check if player is hitting enemy2 from above
  if player.y + player.height <= enemy2.y then
      if enemy2.is_alive then
        -- Kill the enemy2
        enemy2.is_alive = false

        -- Set the enemy2's `scored` flag to `true`
        enemy2.scored = true

        --play sound 
        enemy_hit:play()

        -- Update the score and the high scores
        score_value = score_value + 2
        high_scores[#high_scores + 2] = score_value
      end
  end
end
if not enemy.is_alive then
  enemy.x = math.random(0, love.graphics.getWidth() - enemy.width)
  enemy.y = ground.y + enemy.height - 65
  enemy.is_alive = true
end
if enemy.scored then
    -- Increment the score if the enemy has been scored
    score_value = score_value + 1
    -- Reset the `scored` flag to `false`
    enemy.scored = false
end

function love.keypressed(key)
  if key == "p" then
    is_paused = not is_paused
  end
end

function love.draw()
  love.graphics.draw(background_image, 0, 0)
  love.graphics.draw(background_image, (background_x % background_image:getWidth()), 0)

  love.graphics.push()
  love.graphics.setFont(font)  
  love.graphics.print("Score: " .. score_value, 10, 10)

  -- Check if the player has pressed the tab key
  if love.keyboard.isDown("tab") then
    love.graphics.print("High Score: " .. high_score_value, 10, 30)
  end

  love.graphics.scale(0.5, 0.5)

  for i, tile in ipairs(tiles) do
    love.graphics.draw(tile_image, tile.x - (background_x % tile_size), tile.y)
  end
  love.graphics.scale(1, 1)
  love.graphics.draw(knight, player.x, player.y)
  if enemy.is_alive then
    love.graphics.draw(enemy.image, enemy.x, enemy.y)
  end
  if enemy2.is_alive then
    love.graphics.draw(enemy2.image, enemy2.x, enemy2.y)
  end


  love.graphics.pop()

  if is_paused then
    drawPauseMenu()
  end
end

function drawPauseMenu()
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf("Game Paused", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end
end