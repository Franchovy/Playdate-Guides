import "CoreLibs/object"

-- Your Initialization/setup code here
local imageShip = playdate.graphics.image.new("assets/ship")
local spriteShip = playdate.graphics.sprite.new(imageShip)

spriteShip:moveTo(200, 120) -- Place the ship in the center of the screen
spriteShip:add()            -- Add the ship to the screen!

function playdate.update()
    -- Your Update/play code here

    -- Gets the crank direction in degrees.
    local crankDirection = playdate.getCrankPosition()

    -- Set the rotation of the sprite
    spriteShip:setRotation(crankDirection)

    -- If-statement to detect if button A is pressed
    if playdate.buttonIsPressed(playdate.kButtonA) then
        -- Calculate the movement in the direction the ship is facing

        local speedMovement = 5
        local crankDirectionRadians = math.rad(crankDirection)

        local velX = math.cos(crankDirectionRadians)
        local velY = math.sin(crankDirectionRadians)

        -- Move the ship!

        spriteShip:moveBy(
            speedMovement * velX,
            speedMovement * velY
        )
    end

    -- Wrap the ship around the screen if it goes too far

    if spriteShip.x < -10 then
        spriteShip:moveTo(410, spriteShip.y)
    elseif spriteShip.x > 410 then
        spriteShip:moveTo(-10, spriteShip.y)
    end

    if spriteShip.y < -10 then
        spriteShip:moveTo(spriteShip.x, 250)
    elseif spriteShip.y > 250 then
        spriteShip:moveTo(spriteShip.x, -10)
    end

    -- Update (and draw) all the sprites!
    playdate.graphics.sprite.update()
end
