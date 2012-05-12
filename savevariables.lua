module(..., package.seeall);


local fileSave
local saveVariables = {}
local tabDepth = 0

local function getglobal(name)
	return _G[name]
end

--[[***************************************************************************
@brief	Write out some tabs


***************************************************************************--]]
local function writeOutTabs(numTabs)

	for i = 1, numTabs do
		fileSave:write("\t")
	end
end

--[[***************************************************************************
@brief	Write out a table to the user_variables.lua file


***************************************************************************--]]
local function writeOutTable(pName, pTable)

	local bRootTable = (tabDepth == 0)

	writeOutTabs(tabDepth)
	
	if (type(pName) == "number") then
			
		fileSave:write("["..pName.."] = {\n")
	elseif bRootTable then
		fileSave:write("local "..pName.." = {\n")
	else

		fileSave:write(pName.." = {\n")
	end

	tabDepth = tabDepth + 1

	for key, value in pairs(pTable) do

		--fileSave:write("-- in table loop\n")

		if (type(value) == "table") and key ~= "sprData" then

			writeOutTable(key, value)

		elseif type(value) ~= "userdata" and type(value) ~= "function" and key ~= "sprData" then
			writeOutTabs(tabDepth)
			
			-- write the key
			if (type(key) == "number") then
			
				fileSave:write("["..key.."] = ")
			else
				fileSave:write(key.." = ")
			end

			if (type(value) == "number") then

				fileSave:write(value..",\n")
	
			elseif (type(value) == "string") then
	
				fileSave:write("\""..value.."\",\n")
	
			elseif (type(value) == "boolean") then
			
				if (value == true) then
					fileSave:write("true,\n")
				else
					fileSave:write("false,\n")
				end
			end
		end
	end
	
	tabDepth = tabDepth - 1
	writeOutTabs(tabDepth)

	if (tabDepth > 0) then
		fileSave:write("},\n")
	elseif bRootTable then
		fileSave:write("}\nreturn "..pName)
	else
		fileSave:write("}\n")
	end
end


--[[***************************************************************************
@brief	Register a global variable to be saved

This function adds a global variable to the save variables list

@param	strSaveVariableName		the string name of the global variable to register

***************************************************************************--]]
function register(strSaveVariableName)

	print("Registering \"" .. strSaveVariableName .. "\" for saving.")
	
	table.insert(saveVariables, strSaveVariableName)

end


--[[***************************************************************************
@brief	Write out the save variables

This function writes the save variables out to a .lua file

WARNING: can only save non-userdata global variables

***************************************************************************--]]
function writeOut(filename)

	filename = filename or "user_variables.lua"
	fileSave = io.open(filename, "w")
	
	if (fileSave == nil) then
		return
	end

	-- write out the header
	fileSave:write("-- generated file for saving tables\n\n")


	for key, value in pairs(saveVariables) do


		if (type(getglobal(value)) == "number") then
			
			fileSave:write(value.." = "..getglobal(value).."\n")

		elseif (type(getglobal(value)) == "string") then

			fileSave:write(value.." = \""..getglobal(value).."\"\n")

		elseif (type(getglobal(value)) == "boolean") then

			if (getglobal(value) == true) then
				fileSave:write(value.." = true\n")
			else
				fileSave:write(value.." = false\n")
			end
			
		elseif (type(getglobal(value)) == "table") then
		
			tabDepth = 0
			writeOutTable(value, getglobal(value))

		end
	end
	
	io.close(fileSave)
end

--[[***************************************************************************
@brief	Load some previously saved variables

This function really just executes the saved variables lua file

WARNING: this function only makes sense to run AFTER your save variables have
been created and initialized to defaults

***************************************************************************--]]
function load(filename)
	filename = filename or "user_variables.lua"
	
	if love.filesystem.isFile(filename) == true then
		local chunk = love.filesystem.load(filename)
		
		if type(chunk) == "function" then
			chunk()
		end
	end
end
