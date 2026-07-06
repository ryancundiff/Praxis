--[=[
	A collection of utilities related to debug library on Roblox.

	@class TracebackUtils
]=]

local TracebackUtils = {}

--[=[
	Returns the memory id of the function a level above.

	```lua
	local function TestFunction()
		print(TracebackUtils.GetCallingFunctionId()) -- Prints the memory ID of Init()
	end

	local function Init()
		TestFunction()
	end

	Init()
	```

	@return string
]=]


function TracebackUtils.GetCallingFunctionId()
	return debug.info(3, "f")
end

--[=[
	Returns the name of the function a level above.

	```lua
	local function TestFunction()
		print(TracebackUtils.GetCallingFunctionName()) -- Prints "Init"
	end

	local function Init()
		TestFunction()
	end

	Init()
	```

	@return string
]=]

function TracebackUtils.GetCallingFunctionName()
	return debug.info(3, "n")
end

--[=[
	Equivalent to calling debug.traceback() without any message or level.

	@return string
]=]

function TracebackUtils.GetShallowTraceback()
	return debug.traceback()
end

--[=[
	Throws an error with a traceback string.
]=]

function TracebackUtils.ErrorTraceback(ErrorMessage : string)
	error(ErrorMessage .. "\n" .. debug.traceback())
end

--[=[
	Throws a warning with a traceback string.
]=]

function TracebackUtils.WarnTraceback(WarningMessage : string)
	warn(WarningMessage .. "\n" .. debug.traceback())
end

return TracebackUtils