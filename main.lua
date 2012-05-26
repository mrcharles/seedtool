vector = require "hump.vector"
camera = require "hump.camera"
Gamestate = require "hump.gamestate"
local gui = require "Quickie"

require "savevariables"
require "spritemanager"
require "LayeredSprite"


stemcolor = { 255, 0, 0 }
stempointsize = 3

blossomcolor = { 0, 255, 0 }
blossompointsize = 4


editorstate = {
	keybinds = 
	{

		f1 = 
		{
			activate = true,
			commands = { "open" },
		},
		f2 = 
		{
			onmouse = "l",
			commands = 
			{
				"addstem",
				"addblossom",
			},
		},
		f3 = 
		{
			onmousetest = "l",
			commands = 
			{
				"edit",
			},
		},
		f8 = 
		{
			activate = true,
			commands = 
			{
				"save",
			},
		},
		f12 = 
		{
			activate = true,
			commands = 
			{
				"reset",
			},
		},
	},

	submodes = 
	{
		edit = 
		{
			"vertex",
			"tree"
		}
	},


	currentmode = "",
	currentsubmode = 1,
	currentkey = "",

	helpmsg = "none"

}


function editorstate:cycleSubmode( )
	local submode = self.submodes[self.currentmode]

	if submode then
		self.currentsubmode = self.currentsubmode + 1
		if self.currentsubmode > #submode then
			self.currentsubmode = 1
		end
	end
end

function editorstate:submode()
	local submode = self.submodes[self.currentmode]
	if submode then
		return submode[self.currentsubmode]
	end
end

function editorstate:disableCurrent()
	local bind = self.keybinds[self.currentkey]
	if bind and bind.activate then
		Gamestate.switch(waiting)
		self.currentkey = ""
		self.currentmode = ""
	end
end

function editorstate:toggleCurrent(bind)
	if bind.activate then
		Gamestate.switch(waiting)
		self.currentkey = ""
		self.currentmode = ""
	else -- cycle
		local next = bind.command + 1
		if next > #bind.commands then
			bind.command = 1
		else
			bind.command = next
		end
		self.currentmode = bind.commands[bind.command]
		self.currentsubmode = 1

	end		
end

function editorstate:setNewKey(key)
	if self.keybinds[key] ~= nil then
		self:disableCurrent()
		self.currentkey = key
		self.keybinds[key].command = 1
		self.currentmode = self.keybinds[key].commands[1]
		self.currentsubmode = 1
		
		if self.keybinds[key].activate then
			Gamestate.switch(_G[self.keybinds[key].commands[1]])
		end

	end
end

function editorstate:handleMouse(x,y,button)
	local mode = self.keybinds[self.currentkey]

	if mode then
		if mode.onmouse == button then
			Gamestate.switchOnly( _G[mode.commands[ mode.command or 1 ]], x, y, button)
			return true
		elseif mode.onmousetest == button then
			if Gamestate.testSwitchOnly(_G[mode.commands[ mode.command or 1 ]], x, y, button) then -- we're dragging the window
				return true
			end
		end
	end

end

function editorstate:handleKey(key)
	if key == " " then -- this cycles active modes
		self:cycleSubmode()
	elseif key == self.currentkey then
		self:toggleCurrent(self.keybinds[key])
	else
		self:setNewKey(key)
	end
end

function editorstate:draw()
	love.graphics.setColor(0,0,0)

	love.graphics.push()
	for k,editmode in pairs(self.keybinds) do
		if k == self.currentkey then
			love.graphics.setColor(255, 0, 0)
			local submode = self:submode()
			if submode then
				love.graphics.printf( "> "..submode, 57, 40, 700 )
			end
		else
			love.graphics.setColor(0,0,0)
		end

		love.graphics.printf( k..": "..editmode.commands[editmode.command or 1], 50, 20, 700)

		love.graphics.translate(100, 0)
	end
	love.graphics.pop()

	--love.graphics.printf( "Editmode: "..keybinds[currentkey], 50, 40, 700)
	love.graphics.printf( "helpmsg: "..helpmsg, 50, 60, 700 )
end


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

local plantSprite = nil

function openfile(name)
	planttype = string.sub(name, 0, string.find(name, "_") - 1)
	plantid = string.sub( name, string.find(name, "_")+1, string.find(name, "_") + 1)

	print( planttype.. "_".. plantid)
	plantSprite = spritemanager.createSprite(planttype.."_"..plantid, planttype.."_baby")

	--see if we have existing data and load it up
	local name = planttype.. "_" .. plantid .. "_data.lua"

	if love.filesystem.isFile(name) then

		data = savevariables.load(name)

	else
		for i=1,4 do
			data[1] = {}
		end
	end
end

function getClickedStem(x,y)
	if data[currentstate].stems then

		for i,stem in ipairs(data[currentstate].stems) do
		
			if not stem.parent then	

				local vdist = vector(stem[1]) - vector(cam:worldCoords(x,y))
				if vdist:len() < 5 then 
					return i, 1
				end 

				vdist = vector(stem[2]) - vector(cam:worldCoords(x,y))
				if vdist:len() < 5 then 
					return i, 2
				end 
			end

		end
	end
end

function getStemPosition( stem )
	if stem.parent ~= nil then --parented
		local stems = assert( data[currentstate].stems, "invalid parent" )
		return { stems[stem.parent][stem.idx][1], stems[stem.parent][stem.idx][2] }
	end

	return { stem[1], stem[2] }
end

open = Gamestate.new()

function open:init()

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
	helpmsg = "cycle file with arrows, enter to confirm, esc to cancel"

end

function open:update()

end

function open:draw()

	for i=self.fileindex-3,self.fileindex+3 do
		if i > 0 and i <= #self.files then

			if i == self.fileindex then
				love.graphics.setColor(255,0,0)
			else
				local c = (math.abs(i - self.fileindex) / 4) * 255
				love.graphics.setColor( c, c, c )
			end
			love.graphics.printf(self.files[i], -800, 200 + (i - self.fileindex) * -30, 1000, "right")
		end

	end


end

function open:keyreleased(key)
	if key == "return" then
		if plantSprite == nil or self.notsure then
			openfile(self.files[self.fileindex])
			Gamestate.switch(waiting)
		else
			self.notsure = true
			helpmsg = "WARNING: SWITCHING FILES WILL WIPE ALL YOUR CHANGES. ENTER TO CONTINUE, SPACE TO CANCEL"
		end
	elseif key == "esc" then
		helpmsg = "cycle file with arrows, enter to confirm, esc to cancel"
	elseif key == "up" or key == "right" then
		self.fileindex = math.max( self.fileindex - 1, 1 )
	elseif key == "down" or key == "left" then
		self.fileindex = math.min( self.fileindex + 1, #self.files )
	end
end

function open:mousereleased(x,y,btn)

end


edit = Gamestate.new()

function edit:init()

end

function edit:test(x,y,btn)
	local stem, vert = getClickedStem(x,y)

	if stem then
		return true
	end
end

function edit:enter(previous, x, y, btn)
	self.dragstem, self.dragvert = getClickedStem(x,y)

	print( string.format("moving vert (%d, %d)",self.dragstem, self.dragvert))
	helpmsg = "release button when done"

end



function edit:mousereleased(x,y,btn)
	--copy the data forward
	-- if self.dragstem and self.dragvert then
	-- 	for i=currentstate+1,#statenames do
	-- 		if data[i] ~= nil then
	-- 			if data[i].stems == nil then
	-- 				data[i].stems = {}
	-- 			end
	-- 			data[i].stems[self.dragstem][self.dragvert][1] = data[currentstate].stems[self.dragstem][self.dragvert][1]
	-- 			data[i].stems[self.dragstem][self.dragvert][2] = data[currentstate].stems[self.dragstem][self.dragvert][2]
	-- 		end
	-- 	end

	-- 	self.dragstem = nil
	-- 	self.dragvert = nil
	-- end
	Gamestate.switch(waiting)

end

function edit:adjustTree(stemid, vert, delta)
	for i,stem in ipairs(data[currentstate].stems) do
		if stem[1].parent == stemid and stem[1].idx == vert then 
			stem[2][1] = stem[2][1] + delta.x
			stem[2][2] = stem[2][2] + delta.y
			self:adjustTree(i, 2, delta)
		elseif stem[2].parent == stemid and stem[2].idx == vert then 
			stem[1][1] = stem[1][1] + delta.x
			stem[1][2] = stem[1][2] + delta.y

			self:adjustTree(i, 1, delta)
		end
	end

end

function edit:update(dt)
	if self.dragstem and self.dragvert then

		if editorstate:submode() == "tree" then
			local oldpos = vector( data[currentstate].stems[self.dragstem][self.dragvert] )
			local othervert = data[currentstate].stems[self.dragstem][ 3 - self.dragvert ]
			local othervertpos = vector( othervert )
			local delta = vector( cam:worldCoords(love.mouse.getPosition()) ) - oldpos

			--iterate through all stems parented to this one and apply the offset to the one above them. this is a bad comment.
			self:adjustTree(self.dragstem, self.dragvert, delta)
			--oh, and adjust the other vert on this stem if it's above us
			if othervert.parent == nil and othervertpos.y < oldpos.y then
				othervert[1] = othervert[1] + delta.x
				othervert[2] = othervert[2] + delta.y
				--and of course adjust any tree parented to this one
				self:adjustTree( self.dragstem, 3 - self.dragvert, delta)
			end				

		end

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
	for i=currentstate+1,#statenames do
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
	for i=1,#statenames do
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
	print("got reset enter")
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
			print("got reset keyreleased but not sure")
			self.notsure = false
		else
			print("got reset keyreleased SURE")
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

end

function waiting:keypressed(key)
end

function waiting:mousepressed(x,y, btn)

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
	for i=currentstate + 1,#statenames do
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

function addstem:enter(previous, x, y, btn) -- run every time the state is entered
	self.clicks = {}

	--see if we hit an existing stem in order to parent
	local stem, idx = getClickedStem(x,y)

	if stem then
		local click = { parent = stem, idx = idx }
		print( string.format( "New stem will be parented to (%d, %d)", stem, idx))
		table.insert( self.clicks, click )
		self.parenting = true
	end
	--self:mousereleased(x,y,btn)
end

function addstem:draw()
	cam:attach()
	if self.clicks[1] ~= nil then
		if self.clicks[1].parent then
			love.graphics.setColor(255,255,255)
		else
			love.graphics.setColor(stemcolor)
		end
		local stempos = getStemPosition(self.clicks[1])
		love.graphics.circle( "fill", stempos[1], stempos[2], stempointsize)
	end
	cam:detach()
end

function addstem:update(dt)
	if self.parentstem then

	end
end

function addstem:keyreleased(key, unicode)
	if key == "escape" then
		self.clicks = nil
		Gamestate.switch(waiting)
	end
end

function addstem:mousereleased(x,y, mouse_btn)
	if self.parenting then
		self.parenting = nil
		return
	end
	local click = { cam:worldCoords(x,y) }
	table.insert( self.clicks, click )

	if table.maxn( self.clicks ) == 2 then 
		if data[currentstate].stems == nil then
			data[currentstate].stems = {}
		end

		table.insert( data[currentstate].stems, self.clicks )

		--copy forward, only if it exists, otherwise it'll happen elsehwere
		for i=currentstate + 1,#statenames do
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

	love.graphics.setBackgroundColor(128, 255, 128)

	--load our sprite, and then init the data

	Gamestate.registerEvents()
	Gamestate.switch(waiting)


	--gui.group.default.size[1] = 75
	--gui.group.default.size[2] = 50

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
				local stemstart = getStemPosition( stem[1] )
				love.graphics.circle("fill", stemstart[1], stemstart[2], stempointsize)
				local stemend = getStemPosition( stem[2] )
				love.graphics.circle("fill", stemend[1], stemend[2], stempointsize)
				love.graphics.line(stemstart[1], stemstart[2], stemend[1], stemend[2])
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
	editorstate:draw()

	gui.core.draw()
end

zoomfactor = 1.2
minzoom = 0.5
maxzoom = 5

local dragpos = nil

function love.mousepressed(x, y, button)


	if editorstate:handleMouse(x,y,button) then
		return
	end
	--if no input used then default controls

	if button == "wd" then
		cam.zoom = math.max( cam.zoom / zoomfactor, minzoom )
		--print("wheel down")
	elseif button == "wu" then
		--print("wheel up")
		cam.zoom = math.min( cam.zoom * zoomfactor, maxzoom )
	elseif button == "r" then
		dragpos = vector( x, y )
		love.mouse.setGrab(true)
	end

end

function love.mousereleased(x, y, button)
	if dragpos then
		dragpos = nil
		love.mouse.setGrab(false)
	end

end

function love.update(dt)
	--gui.group.push{grow = "up", pos = {5, 800}}
	gui.Button{ text = "TEST", pos = {5,765}}
	--gui.group.pop()

	if dragpos then
		--print("dragging")
		local mouse = vector( love.mouse.getPosition() )

		local diff = (mouse - dragpos) * ( 1 / cam.zoom )
		local dx, dy = diff:unpack()

		cam:move( -dx, -dy )
		dragpos = mouse
	end
end

function love.keyreleased( key, unicode )
	if key == "right" and plantSprite then
		currentstate = currentstate + 1
		if currentstate > #statenames then
			currentstate = 1
		end
		if data[currentstate] == nil then
			data[currentstate] = copytable( data[ currentstate - 1])


		end

		plantSprite:setAnimation(planttype.. "_"..statenames[currentstate])
	elseif key == "x" then
		cam.x = 0
		cam.y = 0
	else -- check for commands
		editorstate:handleKey(key)
	end



end