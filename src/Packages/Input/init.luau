--[=[
    The Input package provides access to various user input classes. Based on the Input library from sleitnick.

    @class Input
]=]

local Input = {
    PreferredInput = require(script.PreferredInput),
    Mouse = require(script.Mouse),
    Keyboard = require(script.Keyboard),
    Touch = require(script.Touch),
    Gamepad = require(script.Gamepad),
}

return Input
