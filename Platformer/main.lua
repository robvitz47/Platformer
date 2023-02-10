local player = {
  x = 100,
  y = 100,
  width = 50,
  height = 50,
  velocity_x = 0,
  velocity_y = 0,
  jump_height = 10,
  jump_speed = 300,
  max_fall_speed = 4000,
  gravity = 300
}

local ground = {
  y = 380
}

local box_image = love.graphics.newImage("sprites/box.png")
local tiles = {}
local tile_size = 50
local tile_image = love.graphics.newImage("sprites/tile.png")
local background_image = love.graphics.newImage("sprites/background.png")
local player_spritesheet = love.graphics.newImage("sprites/Necromancer.png")
local spriteWidth = 32
local spriteHeight = 32
local quads = {}

  for y = 0, player_spritesheet:getHeight() - spriteHeight, spriteHeight do
    for x = 0, player_spritesheet:getWidth() - spriteWidth, spriteWidth do
      table.insert(quads, love.graphics.newQuad(x, y, spriteWidth, spriteHeight, player_spritesheet:getDimensions()))
  end
end
-- Add the Animations table to store animations
local Animations = {}

function newAnimation(image, width, height, duration)
  local animation = {}
  animation.spritesheet = image
  animation.quads = {}
  
  for y = 0, image:getHeight() - height, height do
    for x = 0, image:getWidth() - width, width do
      table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
    end
  end
  
  animation.duration = duration
  animation.current_time = 0
  
  return animation
end

-- Create the animations
Animations.idle = newAnimation(player_spritesheet, 50, 50, 0.1)
Animations.run = newAnimation(player_spritesheet, 50, 50, 0.1)
Animations.jump = newAnimation(player_spritesheet, 50, 50, 0.1)

function love.load()
  player.x = 50 -- change the spawn x position
  player.y = 500 -- change the spawn y position
  player.current_animation = Animations.idle

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
  -- Update the time in the current animation
  player.current_animation.current_time = player.current_animation.current_time + dt
  
  if love.keyboard.isDown("left") then
    player.velocity_x = -300
    player.current_animation = Animations.run
elseif love.keyboard.isDown("right") then
    player.velocity_x = 300
    player.current_animation = Animations.run
else
    player.velocity_x = 0
    player.current_animation = Animations.idle
end

  player.velocity_y = player.velocity_y or 0

if love.keyboard.isDown("space") then
    player.state = "jumping"
  else
    player.state = "idle"
  end

  player.current_animation.current_time = player.current_animation.current_time + dt
  if player.current_animation.current_time >= player.current_animation.duration then
    player.current_animation.current_time = player.current_animation.current_time - player.current_animation.duration
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

  -- Check if player has reached edge of screen
  if player.x + player.width >= love.graphics.getWidth() then
    -- Generate new tiles to the right of the screen
    for i = 0, love.graphics.getHeight() / tile_size do
      tiles[#tiles + 1] = {
        x = love.graphics.getWidth(),
        y = i * tile_size
      }
    end

    -- Update player position
    player.x = 0
  end
-- Check if the player is close to the edge of the screen
if player.x > love.graphics.getWidth() - love.graphics.getWidth() then
  -- Generate new tiles to the right of the screen
  for i = 0, love.graphics.getHeight() / tile_size do
    tiles[#tiles + 1] = {
      x = love.graphics.getWidth(),
      y = i * tile_size
    }
  end
  -- Generate a box at a random y position
  local box_y = math.random(0, love.graphics.getHeight() - 50)
  tiles[#tiles + 1] = {
    x = love.graphics.getWidth(),
    y = box_y,
    is_box = true
  }
  

end

end
  -- Check if the player has moved off the screen to the right
 if player.x > love.graphics.getWidth() then
  -- Move the player back to the left side of the screen
  player.x = 0

  -- Move all the tiles to the left
  for i, tile in ipairs(tiles) do
    tile.x = tile.x - love.graphics.getWidth()
  end
end

function love.draw()
  love.graphics.draw(background_image, 0, 0)
  
  for _, tile in ipairs(tiles) do
    love.graphics.draw(tile_image, tile.x, tile.y)
  end

  if player.state == "idle" then
    player.current_animation = idle_animation
  elseif player.state == "jumping" then
    player.current_animation = jump_animation
  end

  local spriteNum = math.floor(player.current_animation.current_time / player.current_animation.duration * #player.current_animation.quads) + 1
  if spriteNum >= 1 and spriteNum <= #player.current_animation.quads then
    love.graphics.draw(player.current_animation.spritesheet, player.current_animation.quads[spriteNum], player.x, player.y, 0, player.width / width, player.height / height)
  end
end