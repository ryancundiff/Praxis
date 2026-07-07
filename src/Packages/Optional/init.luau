--[=[
    @class Optional

    Calls `require` on object or path, returning nil if it does not exist.
]=]

local Optional = {}

--[=[
    @param object Instance | string -- The object or path to require.
    @return any? -- The module if it exists, or nil if it does not.

    ```lua
    local Module = Optional.Get("ModulePath")
    ```
]=]

function Optional.Get(object : Instance | string)
    local Success, Module = pcall(function()
        return require(object)
    end)

    if not Success then
        return nil
    end

    return Module
end

return Optional
