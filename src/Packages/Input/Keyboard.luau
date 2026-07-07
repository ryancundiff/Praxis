--[=[
    Keyboard input capturer.

    @class Keyboard
]=]

local Keyboard = {}
Keyboard.__index = Keyboard

-- Services
local UserInputService = game:GetService("UserInputService")

-- Imports
local Signal = require(script.Parent.Parent.Signal)
local Bucket = require(script.Parent.Parent.Bucket)

function Keyboard.new()
    local self = setmetatable({}, Keyboard)

    self._Bucket = Bucket.new()

    self.KeyDown = Signal.new()
    self.KeyUp = Signal.new()

    self._Bucket:Add(self.KeyDown)
    self._Bucket:Add(self.KeyUp)

    self._Bucket:Add(UserInputService.InputBegan:Connect(function(InputObject, Processed)
        if InputObject.UserInputType == Enum.UserInputType.Keyboard then
            self.KeyDown:Fire(InputObject.KeyCode, Processed)
        end
    end))

    self._Bucket:Add(UserInputService.InputEnded:Connect(function(InputObject, Processed)
        if InputObject.UserInputType == Enum.UserInputType.Keyboard then
            self.KeyUp:Fire(InputObject.KeyCode, Processed)
        end
    end))

    return self
end

function Keyboard:IsKeyDown(KeyCode : Enum.KeyCode) : boolean
    return UserInputService:IsKeyDown(KeyCode)
end

function Keyboard:AreKeysDown(KeyCodeOne : Enum.KeyCode, KeyCodeTwo : Enum.KeyCode) : boolean
    return self:IsKeyDown(KeyCodeOne) and self:IsKeyDown(KeyCodeTwo)
end

function Keyboard:AreEitherKeysDown(KeyCodeOne : Enum.KeyCode, KeyCodeTwo : Enum.KeyCode) : boolean
    return self:IsKeyDown(KeyCodeOne) or self:IsKeyDown(KeyCodeTwo)
end

function Keyboard:Destroy()
    self._Bucket:Destroy()
end

return Keyboard
