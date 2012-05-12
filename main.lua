vector = require "hump.vector"
camera = require "hump.camera"





function love.load()
	 -- assert(love.graphics.isSupported('pixeleffect'), 'Pixel effects are not supported on your hardware. Sorry about that.')

	math.randomseed(os.time())
	cam = camera(0, 0,1,0)

	love.graphics.setBackgroundColor(255, 255, 255)
end

function love.draw()
	cam:attach()

	--draw our sprite, for now just a rectangle
	love.graphics.setColor(128,128,128)
	love.graphics.rectangle("fill", -100, -100, 200, 200)


	cam:detach()
end

function love.update(dt)
end

function love.mousepressed(x, y, button)
	if button == "l" then
	end
end

function love.keyreleased( key, unicode )
	if key == "right" then

	elseif key == "left" then

	elseif key == "down" then

	elseif key == "up" then

	elseif key == "f1" then
		if DEBUG then
			DEBUG = false
		else
			DEBUG = true
		end
	elseif key == "f12" then
		if SPEEDUP then
			SPEEDUP = false
		else
			SPEEDUP = true
		end
	elseif key == "f11" then
		if DRAWGROUND then
			DRAWGROUND = false
		else
			DRAWGROUND = true
		end
	elseif key == "f10" then
		if DRAWPHYSICS then
			DRAWPHYSICS = false
		else
			DRAWPHYSICS = true
		end
	elseif key == "f9" then
		if DRAWPLANTS then
			DRAWPLANTS = false
		else
			DRAWPLANTS = true
		end
	end

end