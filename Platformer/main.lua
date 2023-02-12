local player = {
  x = 50,
  y = 50,
  width = 50,
  height = 50,
  velocity_x = 300,
  velocity_y = 0,
  jump_height = 10,
  jump_speed = 500,
  max_fall_speed = 4000,
  gravity = 600,
  speed = 100
}

local ground = {
  y = 750
}


local enemy = {
  x = 720,
  y = 400,
  width = 200,
  height = 200,
  image = love.graphics.newImage("sprites/enemy.png"),
  scored = false
}


local tiles = {}
local tile_size = 50
local tile_image = love.graphics.newImage("sprites/tile.png")
local background_image = love.graphics.newImage("sprites/background.png")
local knight = love.graphics.newImage("sprites/knight.png")
local background_x = 0
score = 0

function love.load()
  player.x = 50 -- change the spawn x position
  player.y = 50 -- change the spawn y position
  enemy.is_alive = true

  -- Generate random x position for enemy
  enemy.x = math.random(0, love.graphics.getWidth() - enemy.width)

-- Set y position to the ground
  enemy.y = ground.y + enemy.height - 275

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
  player.state = "running"

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
    end
  end
end

if not enemy.is_alive then
  enemy.x = player.x
  enemy.y = ground.y - 80
  enemy.is_alive = true
  if enemy.scored then
    -- Increment the score if the enemy has been scored
    score = score + 1
    -- Reset the `scored` flag to `false`
    enemy.scored = false
  end
end
  if not enemy.is_alive then
    enemy.x = player.x
    enemy.y = ground.y - 80
    enemy.is_alive = true
    score = score + 1
  end
end
function love.draw()
  love.graphics.draw(background_image, 0, 0)
  love.graphics.draw(background_image, (background_x % background_image:getWidth()), 0)

  love.graphics.push()
    love.graphics.print("Score: " .. score, 10, 10)
  love.graphics.scale(0.5, 0.5)

  for i, tile in ipairs(tiles) do
    love.graphics.draw(tile_image, tile.x - (background_x % tile_size), tile.y)
  end

  love.graphics.draw(knight, player.x, player.y)
  if enemy.is_alive then
    love.graphics.draw(enemy.image, enemy.x, enemy.y)
  end
  love.graphics.pop()
end