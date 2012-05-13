vector = require "hump.vector"
camera = require "hump.camera"
Gamestate = require "hump.gamestate"
require "savevariables"

stemcolor = { 255, 0, 0 }
stempointsize = 3

blossomcolor = { 0, 255, 0 }
blossompointsize = 4



editmodes = 
{
	"addstem",
	"editstem",
	"addblossom",
	"editblossom",
	"save",
	"reset",
}

currentmode = 1

editstate = "none"

local states = 4
local statenames = {
	"SPROUT",
	"BABY",
	"YOUNG",
	"MATURE"

}
local currentstate = 1
data = {}


editstem = Gamestate.new()
	
function editstem:init()
end

function editstem:enter()
	editstate = "release button when done"
end

function editstem:mousepressed(x,y,btn)
	for i,stem in ipairs(data[currentstate].stems) do
		
		local vdist = vector(stem[1]) - vector(cam:worldCoords(x,y))
		if vdist:len() < 5 then 
			self.dragstem = i
			self.dragvert = 1
			return
		end 

		vdist = vector(stem[2]) - vector(cam:worldCoords(x,y))
		if vdist:len() < 5 then 
			self.dragstem = i
			self.dragvert = 2
			return
		end 


	end
end

function editstem:mousereleased(x,y,btn)
	--copy the data forward


	for i=currentstate+1,states do
		data[i].stems[self.dragstem][self.dragvert][1] = data[currentstate].stems[self.dragstem][self.dragvert][1]
		data[i].stems[self.dragstem][self.dragvert][2] = data[currentstate].stems[self.dragstem][self.dragvert][2]

	end

	self.dragstem = nil
	self.dragvert = nil

	Gamestate.switch(waiting)

end

function editstem:update(dt)
	if self.dragstem and self.dragvert then
		data[currentstate].stems[self.dragstem][self.dragvert] = { cam:worldCoords(love.mouse.getPosition()) } 
	end
end


editblossom = Gamestate.new()
	
function editblossom:init()
end

function editblossom:enter()
	editstate = "release button when done"
end

function editblossom:mousepressed(x,y,btn)
	for i,blossom in ipairs(data[currentstate].blossompoints) do
		
		local vdist = vector(blossom) - vector(cam:worldCoords(x,y))
		if vdist:len() < 5 then 
			self.dragblossom = i
			return
		end 


	end
end

function editblossom:mousereleased(x,y,btn)
	--copy the data forward
	for i=currentstate+1,states do
		if data[i] then
			if data[i].blossompoints == nil then
				data[i].blossompoints = {}
			end
			data[i].blossompoints[self.dragblossom][1] = data[currentstate].blossompoints[self.dragblossom][1]
			data[i].blossompoints[self.dragblossom][2] = data[currentstate].blossompoints[self.dragblossom][2]
		end
	end

	self.dragblossom = nil

	Gamestate.switch(waiting)

end

function editblossom:update(dt)
	if self.dragblossom then
		data[currentstate].blossompoints[self.dragblossom] = { cam:worldCoords(love.mouse.getPosition()) } 
	end
end



save = Gamestate.new()

function save:init()
end

function save:enter(previous)
	--save shit out and go back to waiting
	print("SAVED")
	savevariables.register("data")
	savevariables.writeOut("flower1data.lua")

	Gamestate.switch(waiting)
end

reset = Gamestate.new()

function reset:init()
end

function reset:enter(previous)
	editstate = "PRESS SPACE TO RESET"
	self.notsure = true
end

function copytable(t)
	local r = {}
	for k,v in pairs(t) do
		if type(v) == "table" then
			r[k] = copytable(v)
		else
			r[k] = v
		end
	end
	return r
end

function reset:keyreleased(key)
	if key == " " then
		if self.notsure then 
			editstate = "ARE YOU REALLY SURE? THIS DELETES ALL LATER STATES AS WELL. PRESS SPACE AGAIN"
			self.notsure = false
		else
			for i=currentstate,4 do
				data[i] = nil
			end
			if currentstate > 1 then
				data[currentstate] = copytable( data[ currentstate - 1])
			else
				data[1] = {}
			end

			Gamestate.switch(waiting)
		end
	end
end

waiting = Gamestate.new()

function waiting:init()
end

function waiting:enter(previous)
	editstate = "waiting for left click"
end

function waiting:mousereleased(x, y, btn)
	if btn == "r" then 
		currentmode = currentmode + 1
		if currentmode > table.maxn(editmodes) then
			currentmode = 1
		end
	end
end

function waiting:mousepressed(x,y, btn)
	if btn == "l" then 
		Gamestate.switch(_G[editmodes[currentmode]])
		if editmodes[currentmode] == "editstem" then
			editstem:mousepressed(x,y,btn)
		end
		if editmodes[currentmode] == "editblossom" then
			editblossom:mousepressed(x,y,btn)
		end
	end
end

addblossom = Gamestate.new()

function addblossom:init()

end

function addblossom:enter(previous)

end

function addblossom:mousereleased(x,y,btn)
	if data[currentstate].blossompoints == nil then
		data[currentstate].blossompoints = {}

	end

	local stuff = {cam:worldCoords(x,y)}
	table.insert(data[currentstate].blossompoints, stuff)

	--copy forward, only if it exists, otherwise it'll happen elsehwere
	for i=currentstate + 1,states do
		if data[i] then
			if data[i].blossompoints == nil then
				data[i].blossompoints = {}
			end
			table.insert(data[i].blossompoints, copytable(stuff) )
		end
	end


	Gamestate.switch(waiting)
end

addstem = Gamestate.new()
function addstem:init() -- run only once
end

function addstem:enter(previous) -- run every time the state is entered
	self.clicks = {}

end

function addstem:draw()
	cam:attach()
	if self.clicks[1] ~= nil then
		love.graphics.setColor(stemcolor)
		love.graphics.circle( "fill", self.clicks[1][1], self.clicks[1][2], stempointsize)
	end
	cam:detach()
end


function addstem:mousereleased(x,y, mouse_btn)
	local click = { cam:worldCoords(x,y) }
	table.insert( self.clicks, click )

	if table.maxn( self.clicks ) == 2 then 
		if data[currentstate].stems == nil then
			data[currentstate].stems = {}
		end

		table.insert( data[currentstate].stems, self.clicks )

		--copy forward, only if it exists, otherwise it'll happen elsehwere
		for i=currentstate + 1,states do
			if data[i] then
				table.insert(data[i].stems, copytable(self.clicks))
			end
		end

		editstate = "none"

		Gamestate.switch(waiting)
	else
		editstate = "waitforclick"
	end
end

function love.load()
	 -- assert(love.graphics.isSupported('pixeleffect'), 'Pixel effects are not supported on your hardware. Sorry about that.')

	math.randomseed(os.time())
	cam = camera(0, 0, 1, 0)

	love.graphics.setBackgroundColor(255, 255, 255)

	--load our sprite, and then init the data

	for i=1,4 do
		data[1] = {}
	end

	Gamestate.registerEvents()
	Gamestate.switch(waiting)

end

function love.draw()
	cam:attach()

	--draw our sprite, for now just a rectangle
	love.graphics.setColor(128,128,128)
	love.graphics.rectangle("fill", -100, -100, 200, 200)


	--draw any data we currently have
	if data[currentstate].stems then
		for i,stem in ipairs(data[currentstate].stems) do
			love.graphics.setColor(stemcolor)
			love.graphics.circle("fill", stem[1][1], stem[1][2], stempointsize)
			love.graphics.circle("fill", stem[2][1], stem[2][2], stempointsize)
			love.graphics.line(stem[1][1], stem[1][2], stem[2][1], stem[2][2])
		end
	end

	if data[currentstate].blossompoints then
		for i,bp in ipairs(data[currentstate].blossompoints) do
			love.graphics.setColor(blossomcolor)
			love.graphics.circle("fill", bp[1], bp[2], blossompointsize)
		end
	end


	cam:detach()

	love.graphics.setColor(0,0,0)
	love.graphics.printf( "CURRENT STATE:  "..statenames[currentstate], 50, 20, 700)
	love.graphics.printf( "Editmode: "..editmodes[currentmode], 50, 40, 700)
	love.graphics.printf( "Editstate: "..editstate, 50, 60, 700 )
end

function love.update(dt)
end


function love.mousepressed(x, y, button)
	if editstate == "none" then
		if button == "l" then

		end
	end
end

function love.keyreleased( key, unicode )
	if key == "right" then
		currentstate = currentstate + 1
		if currentstate > states then
			currentstate = 1
		end
		if data[currentstate] == nil then
			data[currentstate] = copytable( data[ currentstate - 1])
		end
	-- elseif key == "left" then
	-- 	currentstate = currentstate - 1
	-- 	if currentstate < 1 then
	-- 		currentstate = states
	-- 	end
	elseif key == "down" then
		cam.zoom = cam.zoom / 1.5
	elseif key == "up" then
		cam.zoom = cam.zoom * 1.5
	elseif key == "f1" then
		editstate = "addblossom"
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