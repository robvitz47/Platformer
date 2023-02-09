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
local player_image = love.graphics.newImage("sprites/Soldier.png")

function love.load()
  player.x = 10 -- change the spawn x position
  player.y = 10 -- change the spawn y position
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
  -- Check for left arrow key press
  if love.keyboard.isDown("left") then
    player.velocity_x = -300
  -- Check for right arrow key press
  elseif love.keyboard.isDown("right") then
    player.velocity_x = 300
  else
    player.velocity_x = 0
  end

  player.velocity_y = player.velocity_y or 0

  -- Check for space key press
  if love.keyboard.isDown("up") then
    player.velocity_y = -player.jump_speed
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
      love.graphics.draw(background_image, 0, 0, 0, love.graphics.getWidth() / background_image:getWidth(), love.graphics.getHeight() / background_image:getHeight()*2)

      for i, tile in ipairs(tiles) do
        if tile.is_box then
          love.graphics.draw(box_image, tile.x, tile.y, 0, tile_size / box_image:getWidth(), tile_size / box_image:getHeight())
        else
          love.graphics.draw(tile_image, tile.x, tile.y, 0, tile_size / tile_image:getWidth(), tile_size / tile_image:getHeight()*12)
        end
      end
      love.graphics.draw(player_image, player.x, player.y, 0, 0.5, 0.5)
end   