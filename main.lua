vector = require "hump.vector"
camera = require "hump.camera"
Gamestate = require "hump.gamestate"
require "savevariables"
require "spritemanager"
require "LayeredSprite"


stemcolor = { 255, 0, 0 }
stempointsize = 3

blossomcolor = { 0, 255, 0 }
blossompointsize = 4



editmodes = 
{
	f1 = 
	{
		activate = true,
		commands = { "open" },
	},
	f2 = 
	{
		commands = 
		{
			"addstem",
			"editstem",
		},
	},
	f3 = 
	{
		commands = 
		{
			"addblossom",
			"editblossom",
		},
	},
	f4 = 
	{
		activate = true,
		commands = 
		{
			"reset",
		},
	},
	s = 
	{
		activate = true,
		commands = 
		{
			"save",
		},
	},
}

currentmode = "f1"
modeindex = 1

helpmsg = "none"

local states = 3
local statenames = {
	"baby",
	"young",
	"mature"

}

local planttypes = 
{
	"bush",
	"flower",
	"tree"

}

local planttype = "flower"
local currentstate = 1
data = {}


function openfile(name)
	planttype = string.sub(name, 0, string.find(name, "_") - 1)
	plantid = string.sub( name, string.find(name, "_")+1, string.find(name, "_") + 1)

	print( planttype.. "_".. plantid)
	plantSprite = spritemanager.createSprite(planttype.."_"..plantid, planttype.."_baby")

	for i=1,4 do
		data[1] = {}
	end
end

open = Gamestate.new()



function open:init()

	--return fileTree
	self.files = {}
	local lfs = love.filesystem
	local filesTable = lfs.enumerate("res/sprites/")
	for i,v in ipairs(filesTable) do
	    local file = "res/sprites/"..v
	    if lfs.isFile(file) then
	        if string.sub(v, -4) == ".lua" then
	        	for i=1,#planttypes do
	        		--print( )
	        		if string.sub(v, 0, #(planttypes[i]) ) == planttypes[i] then
	        			print( "found "..v)
	        			table.insert(self.files, v)
	        		end
	        	end
	        end
	    end
	end
	self.fileindex = 1
end

function open:enter(previous)
	helpmsg = "cycle file with mousebuttons: ".. self.files[self.fileindex] .. " enter to confirm, space to cancel"

end

function open:keyreleased(key)
	-- if key == "return" then
	-- 	if self.notsure then
	-- 		openfile(self.files[self.fileindex])
	-- 		Gamestate.switch(waiting)
	-- 		currentmode = currentmode + 1 
	-- 	else
	-- 		self.notsure = true
	-- 		helpmsg = "WARNING: SWITCHING FILES WILL WIPE ALL YOUR CHANGES. ENTER TO CONTINUE, SPACE TO CANCEL"
	-- 	end
	-- end
end

function open:mousereleased(x,y,btn)
	-- if btn == "l" then
	-- 	self.fileindex = self.fileindex + 1
	-- 	if self.fileindex > #self.files then
	-- 		self.fileindex = 1
	-- 	end
	-- elseif btn == "r" then
	-- 	self.fileindex = self.fileindex - 1
	-- 	if self.fileindex < 1 then
	-- 		self.fileindex = #self.files
	-- 	end
	-- end		
	-- helpmsg = "cycle file with mousebuttons: ".. self.files[self.fileindex] .. " enter to confirm, space to cancel"
end

editstem = Gamestate.new()
	
function editstem:init()
end

function editstem:enter(previous)
	helpmsg = "release button when done"
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


	if self.dragstem and self.dragvert then
		for i=currentstate+1,states do
			if data[i] ~= nil then
				if data[i].stems == nil then
					data[i].stems = {}
				end
				data[i].stems[self.dragstem][self.dragvert][1] = data[currentstate].stems[self.dragstem][self.dragvert][1]
				data[i].stems[self.dragstem][self.dragvert][2] = data[currentstate].stems[self.dragstem][self.dragvert][2]
			end
		end

		self.dragstem = nil
		self.dragvert = nil
	end
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
	helpmsg = "release button when done"
end

function editblossom:mousepressed(x,y,btn)
	if data[currentstate].blossompoints then
		for i,blossom in ipairs(data[currentstate].blossompoints) do
			
			local vdist = vector(blossom) - vector(cam:worldCoords(x,y))
			if vdist:len() < 5 then 
				self.dragblossom = i
				return
			end 


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
	--add in our sprite and animation names
	for i=1,states do
		data[i].sprite = string.format("%s_%s", planttype, plantid)
		data[i].anim = string.format("%s_%s", planttype, statenames[i])
	end


	--save shit out and go back to waiting



	print("SAVED")
	savevariables.register("data")
	savevariables.writeOut( string.format("%s_%s_data.lua", planttype, plantid) )

	Gamestate.switch(waiting)
end

reset = Gamestate.new()

function reset:init()
end

function reset:enter(previous)
	helpmsg = "PRESS SPACE TO RESET"
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
			helpmsg = "ARE YOU REALLY SURE? THIS DELETES ALL LATER STATES AS WELL. PRESS SPACE AGAIN"
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
	helpmsg = "waiting for left click"
end

function waiting:mousereleased(x, y, btn)
	if btn == "r" then 
		currentmode = currentmode + 1
		if currentmode > table.maxn(editmodes) then
			currentmode = 1
		end
	end
end

function waiting:keypressed(key)
	if editmodes[key] ~= nil then
		currentmode = key
		if editmodes[key].activate then
			Gamestate.switch(_G[editmodes[key].commands[1]])
		end

	end
end

function waiting:mousepressed(x,y, btn)
	-- if btn == "l" then 
	-- 	Gamestate.switch(_G[editmodes[currentmode]])
	-- 	if editmodes[currentmode] == "editstem" then
	-- 		editstem:mousepressed(x,y,btn)
	-- 	end
	-- 	if editmodes[currentmode] == "editblossom" then
	-- 		editblossom:mousepressed(x,y,btn)
	-- 	end
	-- end
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
				data[i].stems = {}
				table.insert(data[i].stems, copytable(self.clicks))
			end
		end

		helpmsg = "none"

		Gamestate.switch(waiting)
	else
		helpmsg = "waitforclick"
	end
end

function love.load()
	 -- assert(love.graphics.isSupported('pixeleffect'), 'Pixel effects are not supported on your hardware. Sorry about that.')

	math.randomseed(os.time())
	cam = camera(0, -100, 1, 0)

	love.graphics.setBackgroundColor(255, 255, 255)

	--load our sprite, and then init the data

	Gamestate.registerEvents()
	Gamestate.switch(waiting)



end

function love.draw()
	cam:attach()

	--draw our sprite, for now just a rectangle
	--love.graphics.setColor(128,128,128)
	--love.graphics.rectangle("fill", -100, -100, 200, 200)

	if plantSprite then

		plantSprite:draw()

		love.graphics.setColorMode("modulate")

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
	end

	cam:detach()

	--draw help text

	love.graphics.setColor(0,0,0)

	love.graphics.push()
	for k,editmode in pairs(editmodes) do

		love.graphics.printf( k..": "..editmode.commands[1], 50, 20, 700)
		love.graphics.translate(100, 0)
	end
	love.graphics.pop()

	--love.graphics.printf( "Editmode: "..editmodes[currentmode], 50, 40, 700)
	love.graphics.printf( "helpmsg: "..helpmsg, 50, 60, 700 )
end

function love.update(dt)
end


function love.mousepressed(x, y, button)
	if helpmsg == "none" then
		if button == "l" then

		end
	end
end

function love.keyreleased( key, unicode )
	if key == "right" and plantSprite then
		currentstate = currentstate + 1
		if currentstate > states then
			currentstate = 1
		end
		if data[currentstate] == nil then
			data[currentstate] = copytable( data[ currentstate - 1])


		end

		plantSprite:setAnimation(planttype.. "_"..statenames[currentstate])
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
		helpmsg = "addblossom"
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