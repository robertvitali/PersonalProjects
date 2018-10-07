-----------------------------------------------------------------------------------------
--
-- main.lua 
-- 4/3/16
-----------------------------------------------------------------------------------------

-- Your code here
display.setStatusBar(display.HiddenStatusBar)
system.activate("multitouch")

local physics = require("physics")
physics.start(true)
physics.setGravity(0, 1.2)


local Width = display.contentWidth
local halfWidth = display.contentWidth/2
local Height = display.contentHeight
local halfHeight = display.contentHeight/2
local rectW = Width/2
local rectH = Height/3
local randomX = math.random(0, Width)
local randomY = math.random(-500, -100)
local asteroidCollision = false



--scoring and groups
local score = 0
local health = 3

--Background
local background = display.newImage("background.jpg", halfWidth, halfHeight)
background.width = Width
background.height = Height


--show score
local scoreText = display.newText("Score: "..score, Width - Width/2, 20, native.systemFont, 26)

--show health
local healthText = display.newText("Health: "..health, Width - Width/8, 20, native.systemFont, 26)



--Graphics of rocket ship
local sheet1 = graphics.newImageSheet("rocketShip.png", {width = 64, height = 64, numFrames = 17})
local rocketShip = display.newSprite(sheet1, {name = "rocketShip", start = 1, count = 17, time = 200})
rocketShip.myName = "rocketShip"
rocketShip.x = halfWidth
rocketShip.y = halfHeight + halfHeight/1.6
rocketShip:play()

--Physics for rocket ship
physics.addBody(rocketShip, "kinematic", {density = 1, friction = 0, bounce = 0})
--rocketShip.isBullet = true


--Graphics of asteroid
local sheet2 = graphics.newImageSheet("asteroid.png", {width = 96, height = 96, numFrames = 1})
local asteroid = display.newSprite(sheet2, {name = "asteroid", start = 1, count = 1, time = 200})
asteroid.myName = "asteroid"
asteroid.x = halfWidth
asteroid.y = randomY
asteroid:play()


--Physics for asteroid
physics.addBody(asteroid, "dynamic", {density = 2, friction = 0, bounce = .4, radius = 44})
--asteroid.isBullet = true


--initializing right and left buttons
local rightRect = display.newRect(Width - rectW/4 , Height - rectH/2, rectW, rectH)
rightRect.alpha = .01
local rightText = display.newText("Move Right", Width - rectW/4, Height - rectH/2, native.systemFont, 30)
rightRect:setFillColor(0,0,0)
rightText.alpha = .4

local leftRect = display.newRect(rectW/4, Height - rectH/2, rectW, rectH)
leftRect.alpha = .01
local leftText = display.newText("Move Left", rectW/4,  Height - rectH/2, native.systemFont, 30)
leftRect:setFillColor(0,0,0)
leftText.alpha = .4


--functions for left and right buttons


--function to move rocketship right
function handlerEnterFrameRight(event)
	if(movingRight == true) then
		moveRight()
	end
end
Runtime:addEventListener("enterFrame", handlerEnterFrameRight)

function moveRight()
	if (rocketShip.x < Width) then
		rocketShip.x  = rocketShip.x + 8
	end
end

function handlerightButton(event)
	if (event.phase == "began") then
		--move right
		moveRight()
		movingRight = true
		rightText.alpha = .2
		leftText.alpha = .2
	elseif(event.phase == "ended" and movingRight==true)then
		--stop moving right
		moveRight()
		movingRight = false
		rightText.alpha = .35
		leftText.alpha = .35
	end
	return true
end
rightRect:addEventListener("touch", handlerightButton)


--function that moves rocketship left
function handlerEnterFrameLeft(event)
	if(movingLeft == true) then
		moveLeft()
	end
end
Runtime:addEventListener("enterFrame", handlerEnterFrameLeft)


function moveLeft()
	if (rocketShip.x > 0) then
		rocketShip.x  = rocketShip.x - 8
	end
end

function handleleftButton(event)
	if (event.phase == "began") then
		--move left
		moveLeft()
		movingLeft = true
		rightText.alpha = .2
		leftText.alpha = .2
	elseif(event.phase == "ended" and movingLeft == true)then
		--stop moving left
		moveLeft()
		movingLeft = false
		rightText.alpha = .35
		leftText.alpha = .35
	end
	return true
end
leftRect:addEventListener("touch", handleleftButton)


--Collisions
local function onCollision(event)
if (event.object1.myName == "rocketShip" and event.object2.myName == "asteroid") or (event.object1.myName == "asteroid" and event.object2.myName == "rocketShip") then
	print("first object: "..event.object1.myName)
	print(" second object: "..event.object2.myName)
	print(asteroidCollision)
	asteroidCollision = true
	transition.to(asteroid, {alpha=0, timer=1})
	transition.to(asteroid, {alpha=1, timer=10})
	score = score + .5
		
	end
end



Runtime:addEventListener("collision", onCollision)


-- Local collision handling
local function onLocalCollision( self, event )
    print( event.target )        --the first object in the collision
    print( event.other )         --the second object in the collision
    print( event.selfElement )   --the element (number) of the first object which was hit in the collision
    print( event.otherElement )  --the element (number) of the second object which was hit in the collision
    asteroidCollision = true

end
rocketShip.collision = onLocalCollision
rocketShip:addEventListener( "collision", rocketShip )


function resetTimerFunction()
	print("resetAfterCollision triggered")
	if (asteroidCollision == true) then
		--resetting asteroid position after a collision
		asteroid:setLinearVelocity(1000, 0)
		asteroid.x = randomX
		asteroid.y = randomY
		asteroid:setLinearVelocity(0, 3)
		transition.to(asteroid, {alpha=1, timer=100})
	    asteroidCollision = false

	    --update text on screen
	    scoreText:removeSelf()
	    healthText:removeSelf()
	    scoreText = display.newText("Score: "..score, Width - Width/2, 20, native.systemFont, 26)
	    healthText = display.newText("Health: "..health, Width - Width/8, 20, native.systemFont, 26)

	    --change x,y
	    randomX = math.random(0, Width)
		randomY = math.random(-500, -100)

	end
end

--timer for resetting x,y
local timer1 = timer.performWithDelay(100, resetTimerFunction, 0)
