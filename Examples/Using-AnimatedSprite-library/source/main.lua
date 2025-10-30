import "CoreLibs/object"
import "libs/AnimatedSprite"

-- Your Initialization Code here

local imagetableSprite = assert(playdate.graphics.imagetable.new("assets/sprite_sheet"))
local myAnimatedSprite = AnimatedSprite.new(imagetableSprite)

myAnimatedSprite:addState("idle", 1, 6, { tickStep = 5, xScale = 2, yScale = 2 }, true).asDefault()
myAnimatedSprite:addState("fire", 7, 13, { tickStep = 2, xScale = 2, yScale = 2, nextAnimation = "idle" })
myAnimatedSprite:addState("walk", 14, 25, { tickStep = 2, xScale = 2, yScale = 2 })
myAnimatedSprite:addState("jump", 25, 28, { tickStep = 2, xScale = 2, yScale = 2, nextAnimation = "fall" })
myAnimatedSprite:addState("fall", 29, 33, { tickStep = 2, xScale = 2, yScale = 2, nextAnimation = "idle" })
myAnimatedSprite:addState("hit", 34, 38, { tickStep = 3, xScale = 2, yScale = 2, nextAnimation = "idle" })
myAnimatedSprite:addState("death", 39, 50, { tickStep = 2, xScale = 2, yScale = 2, loop = false })

myAnimatedSprite:moveTo(200, 120)
myAnimatedSprite:add()

local lives = 3

function playdate.update()
    -- Your gameplay loop code here
    playdate.graphics.sprite.update()

    if lives > 0 then
        if playdate.buttonJustPressed(playdate.kButtonA) then
            myAnimatedSprite:changeState("fire")
        elseif playdate.buttonIsPressed(playdate.kButtonUp) then
            myAnimatedSprite:changeState("jump")
        elseif playdate.buttonIsPressed(playdate.kButtonRight) then
            myAnimatedSprite:changeState("walk")
            myAnimatedSprite.globalFlip = 0
        elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
            myAnimatedSprite:changeState("walk")
            myAnimatedSprite.globalFlip = 1
        elseif playdate.buttonJustPressed(playdate.kButtonB) and myAnimatedSprite.currentState ~= "hit" then
            lives -= 1

            if lives > 0 then
                myAnimatedSprite:changeState("hit")
            else
                myAnimatedSprite:changeState("death")
            end
        end
    else
        if playdate.buttonIsPressed(playdate.kButtonA) then
            myAnimatedSprite:changeState("idle")

            lives = 3
        end
    end
end
