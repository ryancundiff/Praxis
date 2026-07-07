--[=[
    A helper library for observing the preferred user input of the player.

    @class PreferredInput
]=]

local PreferredInput = {}

-- Services
local UserInputService = game:GetService("UserInputService")

function PreferredInput.observe(Callback : (Preferred : Enum.PreferredInput) -> (() -> ())?)
    local Cleanup : (() -> ())? = nil
    local ObserveId = 0

    local function RunCleanup()
        if typeof(Cleanup) == "function" then
            task.spawn(Cleanup)
            Cleanup = nil
        end
    end

    local function OnPreferredInputChanged()
        ObserveId += 1
        local CurrentId = ObserveId

        RunCleanup()

        local CleanupFunction = Callback(UserInputService.PreferredInput)

        if typeof(CleanupFunction) == "function" then
            if ObserveId == CurrentId then
                Cleanup = CleanupFunction
            else
                task.spawn(CleanupFunction)
            end
        end
    end

    task.spawn(OnPreferredInputChanged)

    local Connection = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(OnPreferredInputChanged)

    return function()
        Connection:Disconnect()
        RunCleanup()
    end
end

function PreferredInput.get() : Enum.PreferredInput
    return UserInputService.PreferredInput
end

return PreferredInput
