local addOn, E = ...
local L = E.L

local chatframe = E:Module("ChatFrames")

local f, db = chatframe

local keep = 20 -- number of messages to log (could do 10000 too, in theory...)

local events = {
--  "CHAT_MSG_BATTLEGROUND",
--  "CHAT_MSG_BATTLEGROUND_LEADER",
    "CHAT_MSG_BN_WHISPER", -- battle.net whispers will show wrong names
    "CHAT_MSG_BN_WHISPER_INFORM", -- battle.net whispers will show wrong names
--  "CHAT_MSG_CHANNEL", -- all channel related talk (general, trade, defense, custom channels, e.g.)
    "CHAT_MSG_EMOTE", -- only "/me text" messages, not /dance, /lol and such
    "CHAT_MSG_GUILD",
    "CHAT_MSG_GUILD_ACHIEVEMENT",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_SAY",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_YELL",
    "PLAYER_LOGIN", -- not a part of the chat messages logging, must be kept to show log at login
}

local playerFlag = "CHATHISTORYOWNMSGFLAG" -- unique flag that means that this was our message (must not change in between sessions or you have to delete the savedvariables file)

_G["CHAT_FLAG_"..playerFlag] = "|TInterface\\GossipFrame\\GossipGossipIcon.blp:0:0:1:-2:0:0:0:0:0:0:0:0:0|t "

local _ChatEdit_SetLastTellTarget = ChatEdit_SetLastTellTarget
function ChatEdit_SetLastTellTarget(...)
    if chatframe.silent then
    return
    end
    return _ChatEdit_SetLastTellTarget(...)
end

local function timestamp()
    local a_2 = select(2, ("."):split(GetTime() or "0."..random(1, 999), 2)) or 0

    return time().."."..a_2
end

local temp2 = {}
local function printsorted()	
    local temp, data = {}
    for id, _ in pairs(db) do
    table.insert(temp, tonumber(id))
    end
    table.sort(temp, function(a, b)
    return a < b
    end)

    for i = 1, #temp do
    data = db[tostring(temp[i])]
    if type(data) == "table" then
        ChatFrame_MessageEventHandler(DEFAULT_CHAT_FRAME, data[20], unpack(data))
    end
    end
    DEFAULT_CHAT_FRAME:AddMessage("  ")
    DEFAULT_CHAT_FRAME:AddMessage("------------------")
    DEFAULT_CHAT_FRAME:AddMessage("  ")
end

local function cleanup()
    local c, k = 0
    for id, data in pairs(db) do
    c = c + 1
    if (not k) or k > data[21] then
        k = data[21]
    end
    end
    if c > keep then
    db[k] = nil
    end
end

local function LoadChatHistory()
    if not AleaUIDB then AleaUIDB = {} end		
    if not AleaUIDB["ChatHistory"] then AleaUIDB["ChatHistory"] = {} end

    db = AleaUIDB["ChatHistory"]
    
    chatframe:ToggleChatHistory()
end

local function OvEventFunction(self, event, ...)
    local temp = {...}
    if #temp > 0 then
        temp[20] = event
        temp[21] = timestamp()
        if temp[2] == UnitName("player") then
        temp[6] = playerFlag
        end
        db[temp[21]] = temp
        cleanup()
    end	
end

for _, event in pairs(events) do
    chatframe[event] = OvEventFunction
end

function chatframe:ToggleChatHistory()
    if E.db.chatPanel.history then
        f.silent = 1
        printsorted()
        f.silent = nil	
        
        for _, event in pairs(events) do
            chatframe:RegisterEvent(event)
        end
    else
        for _, event in pairs(events) do
            chatframe:UnregisterEvent(event)
        end			
        wipe(db)
        wipe(AleaUIDB["ChatHistory"])
    end
end

E:OnInit2(LoadChatHistory)