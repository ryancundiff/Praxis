--[=[
    Touch input capturer.

    @class Touch
]=]

local Touch = {}
Touch.__index = Touch

-- Services
local UserInputService = game:GetService("UserInputService")

-- Imports
local Signal = require(script.Parent.Parent.Signal)
local Bucket = require(script.Parent.Parent.Bucket)

function Touch.new()
    local self = setmetatable({}, Touch)

    self._Bucket = Bucket.new()

    self.TouchTap = Signal.Wrap(UserInputService.TouchTap)
    self.TouchTapInWorld = Signal.Wrap(UserInputService.TouchTapInWorld)
    self.TouchMoved = Signal.Wrap(UserInputService.TouchMoved)
    self.TouchLongPress = Signal.Wrap(UserInputService.TouchLongPress)
    self.TouchPan = Signal.Wrap(UserInputService.TouchPan)
    self.TouchPinch = Signal.Wrap(UserInputService.TouchPinch)
    self.TouchRotate = Signal.Wrap(UserInputService.TouchRotate)
    self.TouchSwipe = Signal.Wrap(UserInputService.TouchSwipe)
    self.TouchStarted = Signal.Wrap(UserInputService.TouchStarted)
    self.TouchEnded = Signal.Wrap(UserInputService.TouchEnded)

    self._Bucket:Add(self.TouchTap)
    self._Bucket:Add(self.TouchTapInWorld)
    self._Bucket:Add(self.TouchMoved)
    self._Bucket:Add(self.TouchLongPress)
    self._Bucket:Add(self.TouchPan)
    self._Bucket:Add(self.TouchPinch)
    self._Bucket:Add(self.TouchRotate)
    self._Bucket:Add(self.TouchSwipe)
    self._Bucket:Add(self.TouchStarted)
    self._Bucket:Add(self.TouchEnded)

    return self
end

function Touch:IsTouchEnabled() : boolean
    return UserInputService.TouchEnabled
end

function Touch:Destroy()
    self._Bucket:Destroy()
end

return Touch
