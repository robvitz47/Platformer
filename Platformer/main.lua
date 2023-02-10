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
  gravity = 600
}

local ground = {
  y = 500
}

local box_image = love.graphics.newImage("sprites/box.png")
local tiles = {}
local tile_size = 50
local tile_image = love.graphics.newImage("sprites/tile.png")
local background_image = love.graphics.newImage("sprites/background.png")
local knight = love.graphics.newImage("sprites/knight.png")
local background_x = 0

function love.load()
  player.x = 50 -- change the spawn x position
  player.y = 50 -- change the spawn y position

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

  if love.keyboard.isDown("space") then
    player.velocity_y = -player.jump_speed
    player.state = "jumping"
  end

  background_x = background_x + dt * 100

  -- Prevent player from running off the left side of the screen
  if player.x < 0 then
    player.x = 0
  end

  -- Prevent player from running off the right side of the screen
  if player.x + player.width > love.graphics.getWidth() then
    player.x = love.graphics.getWidth() - player.width
  end
end
function love.draw()
  love.graphics.draw(background_image, 0, 0)
  love.graphics.draw(background_image, (background_x % background_image:getWidth()), 0)

  love.graphics.push()
  love.graphics.scale(0.5, 0.5)

  for i, tile in ipairs(tiles) do
    love.graphics.draw(tile_image, tile.x - (background_x % tile_size), tile.y)
  end

  love.graphics.draw(knight, player.x, player.y)
  love.graphics.pop()
end