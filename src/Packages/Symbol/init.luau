-- Author: iGottic

--[=[
	@class Symbol
]=]

local Symbol = {}

-- Types
export type Symbol = typeof(newproxy(true))

--[=[
	Creates a blank userdata that can be converted into a string.

	@param Name string -- The string representing the symbol
	@return Symbol
]=]

function Symbol.new(Name : string)
	local self = newproxy(true)

	getmetatable(self).__tostring = function()
		return Name
	end

	return self
end

--[=[
	Creates a blank symbol.

	@return Symbol
]=]

function Symbol.newNameless()
	local self = newproxy(true)

	return self
end

--[=[
	Equivalent to `tostring`, gets the string name from a Symbol.

	@param ThisSymbol Symbol -- The symbol you're checking
	@return Symbol
]=]

function Symbol.AsString(ThisSymbol : Symbol)
	return tostring(ThisSymbol)
end

return Symbol