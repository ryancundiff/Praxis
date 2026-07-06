local DialogueTree = {}
DialogueTree.__index = DialogueTree

-- Types
export type DialogueMemory = {[any] : any}
export type Data = string | {Data} | (self : DialogueTree, player : Player) -> Data

export type Options = {{
    Input : string,
    Response : DialogueTreeData,
}} | (self : DialogueTree, player : Player) -> {{
    Input : string,
    Response : DialogueTreeData?,
}}

export type DialogueTreeData = {
    Text : Data,
    Options : Options,
}

export type Dialogue = {
    CharacterName : string,
    DialogueTreeData : DialogueTreeData,
}

-- Imports
local Signal = require(script.Parent.Signal)

-- Types Extended
export type Session = {
    Memory : DialogueMemory,
    ShowNext : Signal.Signal<string, Options>,
    Respond : Signal.Signal<number?>,
    CurrentData : DialogueTreeData,
    TextProcessMetadata : any,
}

export type DialogueTree = typeof(setmetatable({}, DialogueTree)) & {
    Sessions : {[Player] : Session},
    Dialogue : Dialogue,
}

local function ProcessTextAsync(self : DialogueTree, player : Player, forcedText : Data?)
    local Session : Session = self.Sessions[player]
    local Text = forcedText or Session.CurrentData.Text

    local function ProcessOptions()
        if typeof(Session.CurrentData.Options) == "function" then
            return Session.CurrentData.Options(self, player)
        else
            return Session.CurrentData.Options
        end
    end

    if typeof(Text) == "string" then
        Session.ShowNext:Fire(Text, ProcessOptions())
    elseif typeof(Text) == "table" then
        if Session.TextProcessMetadata then
            Session.TextProcessMetadata += 1
        else
            Session.TextProcessMetadata = 1
        end

        if Session.TextProcessMetadata == #Text then
            Session.TextProcessMetadata = nil

            Session.ShowNext:Fire(Text[#Text], ProcessOptions())
        else
            Session.ShowNext:Fire(Text[Session.TextProcessMetadata], {
                {
                    Input = "...",
                    Response = {
                        Text = Text[Session.TextProcessMetadata + 1],
                    },
                }
            })
        end
    elseif typeof(Text) == "function" then
        ProcessTextAsync(Text(self, player), player)
        return
    end

    Session.Respond:Once(function(pickedOptionIndex : number?)
        if pickedOptionIndex then
            local pickedOption = Session.CurrentData.Options[pickedOptionIndex]

            if not pickedOption then
                warn(`Attempted to pick option {pickedOptionIndex} when it does not exist`)
                return
            end

            if pickedOption.Response then
                Session.CurrentData = pickedOption.Response
                ProcessTextAsync(self, player)
            else
                self:End(player)
            end
        else
            self:End(player)
        end
    end)
end

function DialogueTree.new(Dialogue : Dialogue) : DialogueTree
    local self : DialogueTree = setmetatable({}, DialogueTree)

    self.Sessions = {}
    self.Dialogue = Dialogue

    return self
end

function DialogueTree.Converse(self : DialogueTree, player : Player, memory : DialogueMemory?) : Session
    if self.Sessions[player] then
        warn(`Attempted to start session when player {player} already has active session`)
        return
    end

    local Session : Session = {
        Memory = if memory then table.clone(memory) else {},
        ShowNext = Signal.new(),
        Respond = Signal.new(),
        CurrentData = self.Dialogue.DialogueTreeData,
        TextProcessMetadata = nil,
    }

    task.defer(ProcessTextAsync, self, player)

    return Session.ShowNext
end

function DialogueTree.End(self : DialogueTree, player : Player)
    if not self.Sessions[player] then
        warn(`Attempted to end session when player {player} does not have active session`)
        return
    end

    local Session : Session = self.Sessions[player]

    Session.ShowNext:Destroy()
    Session.Respond:Destroy()
    self.Sessions[player] = nil
    Session.ShowNext:Fire()
end

function DialogueTree.Respond(self : DialogueTree, player : Player, pickedOptionIndex : number?)
    if not self.Sessions[player] then
        warn(`Attempted to respond when player {player} does not have active session`)
        return
    end

    local Session : Session = self.Sessions[player]

    Session.Respond:Fire(pickedOptionIndex)
end

function DialogueTree.Remember(self : DialogueTree, player : Player, index : any, value : any)
    if not self.Sessions[player] then
        warn(`Attempted to make memory when player {player} does not have active session`)
        return
    end

    self.Sessions[player].Memory[index] = value
end

function DialogueTree.Forget(self : DialogueTree, player : Player, index : any)
    if not self.Sessions[player] then
        warn(`Attempted to forget memory when player {player} does not have active session`)
        return
    end

    self.Sessions[player].Memory[index] = nil
end

function DialogueTree.Recall(self : DialogueTree, player : Player, index : any) : any
    if not self.Sessions[player] then
        warn(`Attempted to recall memory when player {player} does not have active session`)
        return nil
    end

    return self.Sessions[player].Memory[index]
end

function DialogueTree.ClearSessions(self : DialogueTree)
    self.Sessions = {}
end

return DialogueTree