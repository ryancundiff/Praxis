--[=[
    @class TagUtils

    Wrapper for collection service to make it easier to work with tags.
]=]

local TagUtils = {}

-- Services
local CollectionService = game:GetService("CollectionService")

--[=[
    @param tag string -- The tag to listen for.
    @param callback (instance: Instance) -> () -- The callback to call when an instance with the tag is added.

    Wraps around `GetInstanceAddedSignal` and calls the callback for all existing instances with the tag as well.
]=]

function TagUtils.OnInstanceAdded(tag: string, callback: (instance: Instance) -> ())
    for _, instance in CollectionService:GetTagged(tag) do
        task.spawn(callback, instance)
    end

    CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

return TagUtils