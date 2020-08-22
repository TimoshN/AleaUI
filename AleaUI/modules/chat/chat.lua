local addOn, E = ...
local L = E.L

local chatframe = E:Module("ChatFrames")

local MY_CLOSE_BUTTON = "×"
local strsplit = strsplit

local defaults = {
	enableTimeStamps = true,
	width = 384,
	height = 140,
	
	xOffset = 7,
	yOffset = 31,
	
	editBoxxOffset = 0,
	editBoxyOffset = 0,
	
	OffsetTop = 5,
	OffsetRight = 3,
	OffsetBottom = 6,
	OffsetLeft = 3,
	
	EnableFriendButton = false,
	LFRsuppres = true,
	enable_background = true,
	disable_chatlog = false,
	enable_soundAlert = true,
	history = true,
	keyHandler = true,
	nameFilter = {},
	battleTagFilter = {},
	msgFilter = {		
		["GolDDeaL.ru"]  = { enable = true },
		["LvL-MoNeY.ru"] = { enable = true },
		['PLazaGame.RU'] = { enable = true },
	},
	["border"] = {
		["background_texture"] = E.media.default_bar_texture_name3,
		["size"] = 1,
		["inset"] = -1,
		["color"] = {
			0,  
			0,  
			0,  
			1,  
		},
		["background_inset"] = 0,
		["background_color"] = {
			0,  
			0,  
			0,  
			0.8,  
		},
		["texture"] = E.media.default_bar_texture_name3,
	},
}

E.default_settings.chatPanel = defaults

local wowString = BNET_CLIENT_WOW
local scString = BNET_CLIENT_SC2
local d3String = BNET_CLIENT_D3
local wtcgString = BNET_CLIENT_WTCG
local appString = BNET_CLIENT_APP
local overwatchString = BNET_CLIENT_OVERWATCH
local hotsString = BNET_CLIENT_HEROES

local decodeURI
do
   local char, gsub, tonumber = string.char, string.gsub, tonumber
   local function decode(hex) return char(tonumber(hex, 16)) end
   
   function decodeURI(s)
      s = gsub(s, '%%(%x%x)', decode)
      return s
   end
end

do
	local function Custom_FCF_UpdateButtonSide(chat)
		local leftDist =  chat:GetLeft() or 0;
		
		local rightDist = GetScreenWidth() - ( chat:GetRight() or 0 );
		local changed = nil;
		if (( leftDist > 0 and leftDist <= rightDist ) or rightDist < 0 ) then
			if ( chat.buttonSide ~= "left" ) then
				FCF_SetButtonSide(chat, "left");
				changed = 1;
			end
		else
			if ( chat.buttonSide ~= "right" or leftDist < 0 ) then
				FCF_SetButtonSide(chat, "right");
				changed = 1;
			end
		end
		return changed;
	end
	
	--FCF_UpdateButtonSide = Custom_FCF_UpdateButtonSide
end

do
	local function IsLFR()
		local _, _, diff = GetInstanceInfo()
		
		return diff == 7 or diff == 17
	end
	
	local throttle = {}
	
	local lfrHandler = CreateFrame("Frame")
	lfrHandler:RegisterEvent("CHAT_MSG_WHISPER")
	lfrHandler:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
	lfrHandler:SetScript("OnEvent", function(self, event, message, sender, ...)
	--	local guid = select(10, ...)
	--	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid or '')

		if E.db and E.db.chatPanel and E.db.chatPanel.LFRsuppres and IsLFR() then		
			local sender2, server = strsplit('-', sender)
			
			if UnitInRaid(sender) or UnitInRaid(sender2) then
				if not throttle[sender] or throttle[sender] < GetTime() then
					throttle[sender] = GetTime()+(3*60)
					
					if event == "CHAT_MSG_WHISPER" then
						SendChatMessage("<AleaUI> Sorry, but player has disabled whispers while in LFR", "WHISPER", nil, sender)
					end
				end
			end
		end
	end)
end

do
	local enableTimeStamps = true

	_G.SELECTED_CHAT_FRAME_ALEA = ChatFrame1

	local hooks = {}
	
	local filterType = nil
	local filterSelectedToken = nil

	local function GetBattleNetFilterStatus(battleTag, game)
		
		local d = E.db.chatPanel.battleTagFilter[battleTag]

		if d and d.enable then
			
			if d.game1 and game == wowString then return true end
			if d.game2 and game == d3String then return true end
			if d.game3 and game == scString then return true end
			if d.game4 and game == wtcgString then return true end
			if d.game5 and game == overwatchString then return true end
			if d.game6 and game == hotsString then return true end
			if d.game7 and game == appString then return true end
			
		end
		
		
		return false
	end
	
	local SoundSys = CreateFrame("Frame")
	SoundSys:RegisterEvent("CHAT_MSG_WHISPER")
	SoundSys:RegisterEvent("CHAT_MSG_BN_WHISPER")
	SoundSys.spam = GetTime()
	SoundSys:HookScript("OnEvent", function(self, event, msg, author, ...)
		for frame in pairs(hooks) do
			frame.tellTimer = nil
		end
		
		if event == 'CHAT_MSG_BN_WHISPER' then
			local senderID = select(11, ...)
			local _, _, battleTag,_, _, _, client = BNGetFriendInfoByID(senderID)
		
			if GetBattleNetFilterStatus(battleTag, client) then
				return true
			end
		end
		
		if self.spam > GetTime() then return end
		self.spam = GetTime() + 3
		
		if E.db.chatPanel.enable_soundAlert then PlaySoundFile([[Interface\AddOns\AleaUI\media\whisper.mp3]],"Master") end
	end)
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER",function(f, event, msg, author, ...)
		local senderID = select(11, ...)
		local _, _, battleTag,_, _, _, client = BNGetFriendInfoByID(senderID)
		
		if GetBattleNetFilterStatus(battleTag, client) then
				return true
			end
	
		return false
	end)
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM",function(f, event, msg, author, ...)
		
		local senderID = select(11, ...)
		local _, _, battleTag,_, _, _, client = BNGetFriendInfoByID(senderID)
	
		if GetBattleNetFilterStatus(battleTag, client) then
			return true
		end
	
		return false
	end)
    
    local backdrop = {
        bgFile = [[Interface\Buttons\WHITE8x8]], 
        edgeFile = [[Interface\Buttons\WHITE8x8]], 
        edgeSize = 1, 
    }

    
    local resizeTabs = true
    local minTabWidth = 60


	local PLAYER_REALM = gsub(E.myrealm,'[%s%-]','')
	local PLAYER_NAME = E.myname.."-"..PLAYER_REALM
	
	chatframe.chatFrameWidth = 384
	chatframe.chatFrameHeight = 140
	chatframe.chatFrameXOffset = 7
	chatframe.chatFrameYOffset = 31


	local toastButtonMover = CreateFrame('Frame', nil, E.UIParent)
	toastButtonMover:SetSize(30, 32)
		
		
	local function GetBattleTagName(id)
		local _, _, battleTag = BNGetFriendInfoByID(id)
		local name = battleTag and strsplit('#', battleTag)
		return name
	end
	
	local function GetBattleTagNameF(id)
		return 'BNetF:'..id
	end
	
	local function ChatFrame_OnMouseScroll(frame, delta)
		if delta < 0 then
			if IsShiftKeyDown() then
				frame:ScrollToBottom()
			else
				for i = 1, 3 do
					frame:ScrollDown()
				end
			end
		elseif delta > 0 then
			if IsShiftKeyDown() then
				frame:ScrollToTop()
			else
				for i = 1, 3 do
					frame:ScrollUp()
				end
			end
		end
	end

	
	local function HideForever(f)
		f:SetScript("OnShow", f.Hide)
		f:Hide()
	end

	local RAID_LEADER = RAID_LEADER
	local MY_CHAT_WHISPER_INFORM_GET = strsplit("\124", CHAT_WHISPER_INFORM_GET)
	local MY_CHAT_WHISPER_GET = string.match(CHAT_WHISPER_GET, ' ([%w%W]+):')
	local SAY_PATTERN = CHAT_SAY_GET:gsub(":", ''):gsub('%%s', ''):gsub(' ', '')
	local YELL_PATTERN = CHAT_YELL_GET:gsub(":", ''):gsub('%%s', ''):gsub(' ', '')
	
	local function customGSUBHandler(pre, sender, post)
		local name, server = strsplit("-", sender)		
		if server then
			local colorp = ( server:find('|r') ) and '|r' or ''
			name = name..'*'..colorp
		end	
		return pre..name..post
	end
	
	local function customUrlDecode(url)
		local decoded = decodeURI(url)
		return format('|cffffffff|Hurl~%s|h[%s]|h|r', decoded, decoded)
	end
	
	local function customKeyHandler(data, a1, a2, a3)
		
		local dungeonID, keystoneLevel, depleted, aff1, aff2, aff3 = select(2, strsplit(':', data))
	
		dungeonID = tonumber(dungeonID)
		
		local itemName = GetItemInfo(138019)
		local keyFindLastName = itemName
		
		if dungeonID then
			local dungeonName = C_ChallengeMode.GetMapInfo(dungeonID)                
			keyFindLastName = format(CHALLENGE_MODE_KEYSTONE_NAME, dungeonName..' +'..keystoneLevel)
		end
		
		--if depleted == '0' then
		--	keyFindLastName = '|cFFFF0000'..keyFindLastName..'|r'   
		--end
		
	--	print('Tprint', 'customKeyHandler', keyFindLastName, dungeonID, keystoneLevel, depleted, aff1, aff2, aff3)
		
		return data..a1..keyFindLastName..a3
	end
	
	local keyFindLastName = nil
	local function customGSUBHandler1(pre, itemname, post)
		return pre..keyFindLastName..post
	end
	
	local function AddMessage(frame, text, r, g, b, id, holdTime)
		
		local editMessage = true
		
		if text:find('Tprint') then
			editMessage = false
		end
		
		--[[	
			RAID

			GUILD

			LEADER

			PARTY_LEADER
			RAID_LEADER

			GUIDE
			
			CHAT_WHISPER_INFORM_GET
			
			
			INSTANCE_CHAT_LEADER

			CHAT_MESSAGE_RAID_LEADER

			OFFICER

			INSTANCE_CHAT

			INSTANCE

			CHAT_WHISPER_GET
		]]
		if(editMessage) then
			text = text:gsub("%["..PARTY_LEADER.."%]", "["..L['PARTY_LEADER_CHAT_TAG'].."]")
			text = text:gsub("%["..GUILD.."%]", "["..L['GUILD_CHAT_TAG'].."]")
			text = text:gsub("%["..PARTY.."%]", "["..L['PARTY_CHAT_TAG'].."]")
			text = text:gsub("%["..RAID.."%]", "["..L['RAID_CHAT_TAG'].."]")
			text = text:gsub("%["..RAID_LEADER.."%]", "["..L['RAID_LEADER_CHAT_TAG'].."]")
			text = text:gsub("^%["..RAID_WARNING.."%]", "["..L['RAID_WARNING_CHAT_TAG'].."]")		
			text = text:gsub("%["..OFFICER.."%]", "["..L['OFFICER_CHAT_TAG'].."]")
			text = text:gsub("%["..INSTANCE.."%]", "["..L['INSTANCE_CHAT_TAG'].."]")
			text = text:gsub("<"..AFK..">", "["..L['AFK_TAG'].."] ")
			text = text:gsub("<"..DND..">", "["..L['DND_TAG'].."] ")
			text = text:gsub("%["..INSTANCE_CHAT_LEADER.."%]", "["..L['INSTANCE_CHAT_LEADER_CHAT_TAG'].."]")
			text = text:gsub("%[(%d0?)%. .-%]", "[%1]")
			text = text:gsub("^(.-|h) "..MY_CHAT_WHISPER_GET, "%1 >>")
			text = text:gsub(MY_CHAT_WHISPER_INFORM_GET.."(.-|h)", ">> %1")
			text = text:gsub("^(.-|h) "..SAY_PATTERN, "["..L['SAY_PATTERN_CHAT_TAG'].."] %1")		
			text = text:gsub("^(.-|h) "..YELL_PATTERN, "["..L['YELL_PATTERN_CHAT_TAG'].."] %1")
			text = text:gsub('([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])', customUrlDecode)
			
			text = text:gsub("(|Hplayer:.-|h%[)(.-)(%]|h)", customGSUBHandler)
			
			if text:find('|Hshare') then
				text = text:gsub(':18:18|t', ':0:0|t')		
			end
		end
	
		if(enableTimeStamps) then
			text = "|cff999999" .. date("%H:%M:%S") .. "|r " .. text
		end

		return hooks[frame](frame, text, r, g, b, id, holdTime)
	end

	local tags2 = {"ButtonFrameUpButton", "ButtonFrameDownButton", "ButtonFrameBottomButton", "ConversationButton", "ButtonFrameMinimizeButton"}
	local function updateGameChatButtons(frame)	
		for i, name in ipairs(tags2) do
			
			local f = _G[frame:GetName()..name]
			
			if f and not f.tx then
	
				f:GetNormalTexture():SetDesaturated(true)
				f:GetNormalTexture():SetTexCoord(0.17, 0.77, 0.23, 0.78)
				f:GetNormalTexture():ClearAllPoints()
				f:GetNormalTexture():SetPoint("TOPLEFT", f,"TOPLEFT", 3,-3)
				f:GetNormalTexture():SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT",  -3,3)

				f:GetPushedTexture():SetDesaturated(true)
				f:GetPushedTexture():SetTexCoord(0.17, 0.77, 0.23, 0.78)
				f:GetPushedTexture():ClearAllPoints()
				f:GetPushedTexture():SetPoint("TOPLEFT", f,"TOPLEFT", 3,-3)
				f:GetPushedTexture():SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT",  -3,3)

				f.tx = f.tx or f:CreateTexture(nil, "BORDER", nil , -1)
				f.tx:SetColorTexture(0, 0, 0, 1)
				f.tx:SetPoint("TOPLEFT", f,"TOPLEFT", 2,-2)
				f.tx:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT", -2,2)

			end
		end
	end
	
	local function SelectChatFrame(f, button, arg)

		print('SelectChatFrame', button, arg )
		print('T', (debugstack(1, 1, 1)) )

		if button == "LeftButton" and arg == false then			
			local id = tonumber(string.match(f:GetName(), "ChatFrame(%d+)Tab"))
			SELECTED_CHAT_FRAME_ALEA = _G[("ChatFrame%d"):format(id)]
			
			updateGameChatButtons(SELECTED_CHAT_FRAME_ALEA)
			
			if id == 2 then	
				CombatLogQuickButtonFrame_Custom:SetPoint("BOTTOMRIGHT", COMBATLOG, "TOPRIGHT", 0, 0);
			end
		end
	end
	
	local hookedEditBox = {}
	
	local leftDef, parentDef, rightDef = "BOTTOMLEFT", E.UIParent, "BOTTOMLEFT"
	local editXoffset, editYoffset = nil, nil
	
	local updatePosition = CreateFrame("Frame")
	updatePosition.elapsed = 0
	updatePosition:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < 0.5 then return end
		self.elapsed = 0
		
		if not E.db.chatPanel then return end
		
		local left, parent, right, xoffset, yoffset = ChatFrame1:GetPoint()
		
		if left ~= leftDef or right ~= rightDef or Round(xoffset) ~= E.db.chatPanel.xOffset or Round(yoffset) ~= E.db.chatPanel.yOffset then
			-- print('Update chat position')
			-- print('    ', left, parent, right, xoffset, yoffset)
			-- print('    ', leftDef, parentDef, rightDef, E.db.chatPanel.xOffset, E.db.chatPanel.yOffset)
			-- print('    ',  left ~= leftDef, right ~= rightDef, xoffset ~= E.db.chatPanel.xOffset, yoffset ~= E.db.chatPanel.yOffset)

			ChatFrame1:ClearAllPoints()
			ChatFrame1:SetPoint(leftDef, parentDef, rightDef, E.db.chatPanel.xOffset, E.db.chatPanel.yOffset)
			ChatFrame1:SetHeight(E.db.chatPanel.height)
			ChatFrame1:SetWidth(E.db.chatPanel.width)
			FCF_SavePositionAndDimensions(ChatFrame1)
		end
		
		if E.db.chatPanel.editBoxxOffset ~= editXoffset or
			E.db.chatPanel.editBoxyOffset ~= editYoffset then
			
			editXoffset = E.db.chatPanel.editBoxxOffset
			editYoffset = E.db.chatPanel.editBoxyOffset
			
		
			for editBox in pairs(hookedEditBox) do			
				editBox:ClearAllPoints()
				editBox:SetPoint("TOPLEFT", ChatFrame1, "BOTTOMLEFT", -2, E.db.chatPanel.editBoxyOffset)
				editBox:SetPoint("TOPRIGHT", ChatFrame1, "BOTTOMRIGHT",  2, E.db.chatPanel.editBoxyOffset)
			end
		end
	end)
	
	local tabs = {
		"Left", "Middle", "Right", "SelectedLeft", "SelectedMiddle",
		"SelectedRight", "HighlightLeft", "HighlightMiddle",
		"HighlightRight"
	}
	
	local bordersTex = {		
		"Background",
		'TopLeftTexture',
		'BottomLeftTexture',
		'TopRightTexture',
		'BottomRightTexture',
		'LeftTexture',
		'RightTexture',
		'BottomTexture',
		'TopTexture',
	}
	
	local tabSizeUpdate = function(self, a)
		if a ~= minTabWidth then
			
			if self.conversationIcon then
				self.conversationIcon:ClearAllPoints()
				self.conversationIcon:Kill()
			end

			self:GetFontString():ClearAllPoints()
			self:GetFontString():SetPoint("LEFT", self, "LEFT", 0, -5)
			self:GetFontString():SetJustifyH("CENTER")
			self:GetFontString():SetPoint("RIGHT", self, "RIGHT", 0, -5)
			self:SetWidth(minTabWidth)
					
			self.glow:ClearAllPoints()
			self.glow:SetPoint("LEFT", self, "LEFT", -2, -5)
			self.glow:SetPoint("RIGHT", self, "RIGHT", 2, -5)
		end
	end
	
	local customTabName = {
		["Общий"]   = "|cFFFFFFFF",
		['Каналы']  = "|cFFFFFFFF",
		['Гильдия'] = "|cFF00FF00",
		['Г']		= "|cFF00FF00",
		['Шепот']   = "|cFFe980e0",
		['Ш']   	= "|cFFe980e0",
		['Добыча']  = "|cFFFFFFFF",
		['Рейд']    = "|cFFFFFFFF",
		
		[GENERAL]	= "|cFFFFFFFF",
		[GUILD] 	= "|cFF00FF00",
		[CHANNELS]	= "|cFFFFFFFF",
		[WHISPER]	= "|cFFe980e0",
		[LOOT]		= "|cFFFFFFFF",
		['G']       = "|cFF00FF00",
		['W']       = "|cFFe980e0",
	}
	
	local tabTextUpdate = function(self, text)
		
		--print('tabTextUpdate', text)

		-- if not self._origText then 
		-- 	self._origText 
		-- end 

		if self.conversationIcon then
			self.conversationIcon:ClearAllPoints()
			self.conversationIcon:Kill()
		end

		if customTabName[text] then

			--print('SetText:1', customTabName[text]..text)
			self.Text:SetText(customTabName[text]..text)
		else
			local name, server = strsplit("-", text or '')
			if name and server then		
				--print('SetText:2', name, text)	
				self.Text:SetText(name)
			end
		end
	end

	local borderoffset = 1
	
	local function CustomChatFrame_MessageEventHandler(self, event, ...)
		
		return false
	end


	local function ChatFrame_Handler(...)
		if ( ChatFrame_ConfigEventHandler(...) ) then
			return;
		end
		if ( ChatFrame_SystemEventHandler(...) ) then
			return
		end
		if ( CustomChatFrame_MessageEventHandler(...) ) then
			return
		end
		if ( ChatFrame_MessageEventHandler(...) ) then
			return
		end
	end

	local function FloatingChatFrame_Handler(...)
		ChatFrame_Handler(...);
		FloatingChatFrame_OnEvent(...);
	end

	local function UpdateTabFontString(name)
		return function() 
			_G[name.."Tab"]:GetFontString():SetFont(E.media.default_font, E.media.default_font_size-1, "OUTLINE")
		end
	end 


	local ChatTabFontObject = CreateFrame('Frame'):CreateFontString()
	ChatTabFontObject:SetFont(E.media.default_font, E.media.default_font_size-1, "OUTLINE")


	local function StyleChatFrame(name)
		local frame = _G[name]		

		
		_G[name.."TabText"]:SetFont(E.media.default_font, E.media.default_font_size-1, "OUTLINE")

		if not frame or frame.aleauihooked then return end	
		frame.aleauihooked = true		
		updateGameChatButtons(frame)
	--	frame:SetIgnoreFramePositionManager(true)
		
		if ( frame.ScrollBar ) then
			frame.ScrollBar:Kill()
		end 

		if ( frame.ScrollToBottomButton ) then 
			frame.ScrollToBottomButton:Kill()
		end 

		-- hooksecurefunc(_G[name.."Tab"]:GetFontString(), 'SetFont', function(...)
		-- 	print(name.."Tab", ...)
		-- end)

		_G[name.."Tab"]:HookScript("OnClick", SelectChatFrame)
	
		-- local func = UpdateTabFontString(name)

		-- C_Timer.After(2, func)
		-- C_Timer.After(5, func)
		-- C_Timer.After(7, func)
		-- C_Timer.After(10, func)

		--print('T', _G[name.."Tab"]:GetFontString() )

		frame:SetClampRectInsets(0, 0, 0, 0)
	
		hooksecurefunc(frame, 'SetClampRectInsets', function(self, a1,a2,a3,a4)
			if (a1 ~= 0 or a2 ~= 0 or a3 ~= 0 or a4 ~= 0) then
				self:SetClampRectInsets(0, 0, 0, 0)
			end
		end)
		
		if ( _G[name.."EditBoxLeft"] ) then
			_G[name.."EditBoxLeft"]:SetAlpha(0)
		end 
		
		if ( _G[name.."EditBoxRight"] ) then
			_G[name.."EditBoxRight"]:SetAlpha(0)
		end 

		if (_G[name.."EditBoxMid"]) then 
			_G[name.."EditBoxMid"]:SetAlpha(0)
		end 
	
		if ( _G[name.."EditBoxFocusLeft"] ) then 
			_G[name.."EditBoxFocusLeft"]:SetAlpha(0)
		end 

		if ( _G[name.."EditBoxFocusRight"] ) then
			_G[name.."EditBoxFocusRight"]:SetAlpha(0)
		end 

		if ( _G[name.."EditBoxFocusMid"] ) then
			_G[name.."EditBoxFocusMid"]:SetAlpha(0)				
		end 

		frame:SetFrameStrata("DIALOG")
		
		frame.editBox:ClearAllPoints()
		frame.editBox:SetPoint("TOPLEFT", ChatFrame1, "BOTTOMLEFT", -2, 0)
		frame.editBox:SetPoint("TOPRIGHT", ChatFrame1, "BOTTOMRIGHT",  2, 0)
		
		if not hookedEditBox[frame.editBox] then
			hookedEditBox[frame.editBox] = true
		end
		
		hooksecurefunc(frame.editBox, "SetFocus", frame.editBox.Show)
		hooksecurefunc(frame.editBox, "ClearFocus", frame.editBox.Hide)
	
		frame.editBox.border = CreateFrame("Frame", nil, frame.editBox, BackdropTemplateMixin and 'BackdropTemplate')
		frame.editBox.border:SetFrameLevel(frame.editBox:GetFrameLevel()-1)
		frame.editBox.border:SetFrameStrata("LOW")
		frame.editBox.border:SetBackdrop(backdrop)
		frame.editBox.border:SetBackdropColor(0,0,0,0.9)
		frame.editBox.border:SetBackdropBorderColor(1,1,1,1)
		frame.editBox.border:SetPoint("LEFT", -borderoffset-1, 0)		
		frame.editBox.border:SetPoint("RIGHT", borderoffset, 0)
		frame.editBox.border:SetPoint("TOP", 0, -7)		
		frame.editBox.border:SetPoint("BOTTOM", 0, 5)
		
		frame.editBox:Hide()
		
		if ( _G[name.."EditBoxFocusRight"] ) then
			hooksecurefunc(_G[name.."EditBoxFocusRight"], "SetVertexColor", function(self, r,g,b,a)
				self.border:SetBackdropBorderColor(r,g,b,1)		
			end)
			
			hooksecurefunc(_G[name.."EditBoxFocusRight"], "Show", function(self, r,g,b,a)
				self.border:Show()
			end)
			
			hooksecurefunc(_G[name.."EditBoxFocusRight"], "Hide", function(self, r,g,b,a)
				self.border:Hide()
			end)
			
			_G[name.."EditBoxFocusRight"].border = frame.editBox.border
		end 

		--Enable moving in editbox without holding alt
		frame.editBox:SetAltArrowKeyMode(nil)

		for index, value in pairs(tabs) do
			local texture = _G[name.."Tab"..value]
			texture:SetTexture(nil)
		end
		
		for i=1, #bordersTex do	
			_G[name..bordersTex[i]]:SetTexture(nil)
			if ( _G[name.."ButtonFrame"..bordersTex[i]] ) then 
				_G[name.."ButtonFrame"..bordersTex[i]]:SetTexture(nil)
			end
		end

		if resizeTabs then
			hooksecurefunc(_G[name.."Tab"], "SetWidth", tabSizeUpdate)		
			_G[name.."Tab"]:SetWidth(1)			
		end
		
		
		tabTextUpdate( _G[name.."Tab"], _G[name.."Tab"].Text:GetText() )
		hooksecurefunc(_G[name.."Tab"], "SetText", tabTextUpdate)

		hooksecurefunc(_G[name.."Tab"], "SetAlpha", function(t, alpha)			
			if alpha ~= 1 and ( GeneralDockManager.selected:GetID() == t:GetID() ) then
				t:SetAlpha(1)
			elseif alpha < 0.6 then
				t:SetAlpha(0.6)
			end
		end)



		if not frame.scriptsSet then
			frame:SetScript("OnMouseWheel", ChatFrame_OnMouseScroll)
			hooksecurefunc(frame, "SetScript", function(f, script, func)
				if script == "OnMouseWheel" and func ~= ChatFrame_OnMouseScroll then
					f:SetScript(script, ChatFrame_OnMouseScroll)
				end
			end)
			
			if frame:GetID() > NUM_CHAT_WINDOWS then
			--	frame:SetScript("OnEvent", FloatingChatFrame_Handler)
			elseif frame:GetID() ~= 2 then
			--	frame:SetScript("OnEvent", ChatFrame_Handler)
			end
			
			frame.scriptsSet = true
		end

		if frame:GetID() ~= 2 then
			hooks[frame] = frame.AddMessage
			frame.AddMessage = AddMessage
		end
	end
	
	chatframe.StyleChatFrame = StyleChatFrame
	
	local CHAT_FRAMES = CHAT_FRAMES
	local function checkForNewWindows()
		--print('checkForNewWindow')
		
		for _, chatFrameName in pairs(CHAT_FRAMES) do
		--	local frame = _G[chatFrameName];
			StyleChatFrame(chatFrameName)
		end
	
		--[==[
		for i=NUM_CHAT_WINDOWS+1, NUM_CHAT_WINDOWS+10 do
			StyleChatFrame(format("ChatFrame%d", i))
		end
		]==]
	end

	hooksecurefunc("FCF_OpenTemporaryWindow", checkForNewWindows)

	local ___f = CreateFrame('Frame')

	___f:RegisterEvent('UPDATE_CHAT_WINDOWS')
	___f:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS')
	___f:SetScript('OnEvent', checkForNewWindows )

	local chatCustomNameSenderReciever = {}
	
	local function CustomMessageHandler(self, event, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16, ...)
	
		if event == "CHAT_MSG_WHISPER_INFORM" then
			local message = a1
			local receiver = a2
			
			local name, server = strsplit('-', receiver)		
		--	print("T", event, message, receiver)
			
			if name and not server then
				local newchatTarget = name.."-"..PLAYER_REALM				
				a2 = newchatTarget
		--		print("Erorr with server on", name)
			end
		elseif event == "CHAT_MSG_WHISPER" then
			local message = a1
			local sender = a2
			
			local name, server = strsplit('-', sender)
			
		--	print("T", event, message, sender)
			
			if name and not server then
				local newchatTarget = name.."-"..PLAYER_REALM				
				a2 = newchatTarget
		--		print("Erorr with server on", name)
			end
		end
		
		return self, event, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16, ...
	end
	
	local function CustomFloatingChatFrameManager_OnEvent(...)
		FloatingChatFrameManager_OnEvent(CustomMessageHandler(...))
	end
	
	for i = 1, NUM_CHAT_WINDOWS do
		StyleChatFrame(format("ChatFrame%d", i))		
		HideForever(_G[("ChatFrame%sButtonFrame"):format(i)])
	
		_G['ChatFrame'..i]:HookScript('OnShow', function(self)
			chatframe:SetLastBackgroundParent(self)
		end)
	end
	
	chatframe.AddCopyButton(_G["ChatFrame1"])
		
	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 7, 31)
	ChatFrame1:SetHeight(chatframe.chatFrameHeight)
	ChatFrame1:SetWidth(chatframe.chatFrameWidth)
	
	FCF_SavePositionAndDimensions(ChatFrame1)
	
	--Hide buttons
	ChatFrameMenuButton:Kill()
	
	--ChatFrameChannelButton:Kill()
	--ChatFrameToggleVoiceDeafenButton:Kill()
	--ChatFrameToggleVoiceMuteButton:Kill()
	
	if (ChatFrameChannelButton) then
		ChatFrameChannelButton:ClearAllPoints()
		ChatFrameChannelButton:SetPoint('TOPRIGHT', ChatFrame1, 'TOPRIGHT', 6, -38)
		ChatFrameChannelButton:DisableDrawLayer('ARTWORK')
		ChatFrameChannelButton.Icon:SetDesaturated(true)
		ChatFrameChannelButton:SetAlpha(0.4)
	end 

	--Make channels sticky
	ChatTypeInfo.SAY.sticky = 1
	ChatTypeInfo.EMOTE.sticky = 1
	ChatTypeInfo.YELL.sticky = 1
	ChatTypeInfo.PARTY.sticky = 1
	ChatTypeInfo.GUILD.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.INSTANCE_CHAT.sticky = 1

	local SetHyperlink = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(data, ...)
		local isURL, _mycurlink = strsplit("~", data)
		if isURL and isURL == "url" then
			chatframe:Popup(_mycurlink)
		else
			SetHyperlink(self, data, ...)
		end
	end

	local defaultFilter =  "%[Game Master%] GM:"
	local _keyWords = {}
	local maxKeyWords = #_keyWords
	local function UpdateFilterMsgList()
		wipe(_keyWords)
		
		_keyWords[#_keyWords+1] = defaultFilter
		
		for k, v in pairs(E.db.chatPanel.msgFilter) do
			if v and v.enabled then
				_keyWords[#_keyWords+1] = k
			end
		end
		
		maxKeyWords = #_keyWords
	end

	local find = string.find
	local match = string.match
	local function spamFiler(f, event, msg, author)
		for i=1, maxKeyWords do
			if find(msg, _keyWords[i]) then	
				return true
			end			
		end	
		return false
	end
	
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER",spamFiler)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL",spamFiler)

	local chatFrameBackground = CreateFrame("Frame", nil, E.UIParent)
	chatFrameBackground:SetFrameStrata("BACKGROUND")
	chatFrameBackground:SetPoint("TOPLEFT", _G['ChatFrame1'], "TOPLEFT", -3, 5)
	chatFrameBackground:SetPoint("BOTTOMRIGHT", _G['ChatFrame1'], "BOTTOMRIGHT", 3, -6)
	
	local artBorder = CreateFrame("Frame", nil, chatFrameBackground, BackdropTemplateMixin and 'BackdropTemplate')
	artBorder:SetBackdrop({
	  edgeFile = [[Interface\Buttons\WHITE8x8]],
	  edgeSize = 1, 
	})
	artBorder:SetBackdropBorderColor(0,0,0,1)
	artBorder:SetPoint("TOPLEFT", chatFrameBackground, "TOPLEFT", 0, -0)
	artBorder:SetPoint("BOTTOMRIGHT", chatFrameBackground, "BOTTOMRIGHT", -0, 0)

	artBorder.back = artBorder:CreateTexture()
	artBorder.back:SetDrawLayer('ARTWORK', -2)
	artBorder.back:SetColorTexture(0, 0, 0, 0)
	artBorder.back:SetPoint("TOPLEFT", chatFrameBackground, "TOPLEFT", 0, 0)
	artBorder.back:SetPoint("BOTTOMRIGHT", chatFrameBackground, "BOTTOMRIGHT", 0, 0)
	
	function chatframe:SetLastBackgroundParent(me)
	--	chatFrameBackground:SetParent(me)
	--	chatFrameBackground:SetFrameLevel(me:GetFrameLevel()-1)
	end
	
	function chatframe:UpdateChatBackground()		
		chatFrameBackground:SetPoint("TOPLEFT", _G['ChatFrame1'], "TOPLEFT", -E.db.chatPanel.OffsetLeft, E.db.chatPanel.OffsetTop)
		chatFrameBackground:SetPoint("BOTTOMRIGHT", _G['ChatFrame1'], "BOTTOMRIGHT", E.db.chatPanel.OffsetRight, -E.db.chatPanel.OffsetBottom)	
		
		local opts = E.db.chatPanel
		
		artBorder:SetBackdrop({
		  edgeFile = E:GetBorder(opts.border.texture),
		  edgeSize = opts.border.size, 
		})
		artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
		artBorder:SetPoint("TOPLEFT", chatFrameBackground, "TOPLEFT", opts.border.inset, -opts.border.inset)
		artBorder:SetPoint("BOTTOMRIGHT", chatFrameBackground, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

		artBorder.back:SetTexture(E:GetTexture(opts.border.background_texture))
		artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
		artBorder.back:SetPoint("TOPLEFT", chatFrameBackground, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
		artBorder.back:SetPoint("BOTTOMRIGHT", chatFrameBackground, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
	end
	
	GeneralDockManagerOverflowButton:ClearAllPoints()
	GeneralDockManagerOverflowButton:SetPoint('BOTTOMRIGHT', _G['ChatFrame1'], 'TOPRIGHT', 2, 7)
	hooksecurefunc(GeneralDockManagerScrollFrame, 'SetPoint', function(self, point, anchor, attachTo, x, y)
		if anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0 then
			self:SetPoint(point, anchor, attachTo, -2, -6)
		end
	end)
	
	GeneralDockManagerOverflowButtonList:StripTextures()
	E:CreateBackdrop(GeneralDockManagerOverflowButtonList, GeneralDockManagerOverflowButtonList, { 0, 0, 0, 1 }, { 0, 0, 0, 0.6 }, "BACKGROUND")
	
	E.GUI.args.ChatPanel = {
		name = L['Chat'],
		type = "group",
		order = 5,
		expand = true,
		args = {},
	}
	
	E.GUI.args.ChatPanel.args.Blacklist = {
		name = L['Filters'],
		type = "group",
		order = 5,
		embend = false,
		args = {},
	}
	
	E.GUI.args.ChatPanel.args.Blacklist.args.filterType = {	
		name = L['Select filter'],
		order = 1,
		type = "dropdown",
		width = 'full',
		values = {			
			L['Black list - by name'],
			L['Black list - by battleTag'],
			L['Black list - by message'],
		},
		set = function(self, value)
			filterType = value
			filterSelectedToken = nil
			chatframe:UpdateFilterGUI(value)
		end,
		get = function(self)
			return filterType
		end,
	}
	
	E.GUI.args.ChatPanel.args.keyHandler = {		
		name = L['Enable more key link info'],
		type = 'toggle', width = 'full',
		order = 0.1,
		set = function()
			E.db.chatPanel.keyHandler = not E.db.chatPanel.keyHandler
		end,
		get = function()
			return E.db.chatPanel.keyHandler
		end,	
	}
	
	E.GUI.args.ChatPanel.args.HideBackground = {		
		name = L['Enable background'],
		type = 'toggle',
		order = 1,
		set = function()
			E.db.chatPanel.enable_background = not E.db.chatPanel.enable_background
			
			if E.db.chatPanel.enable_background then
				chatFrameBackground:Show()
			else
				chatFrameBackground:Hide()
			end
		end,
		get = function()
			return E.db.chatPanel.enable_background
		end,	
	}
	
	E.GUI.args.ChatPanel.args.RemoveLog = {		
		name = L['Hide combat log tab'],
		type = 'toggle',
		order = 2,
		set = function()
			E.db.chatPanel.disable_chatlog = not E.db.chatPanel.disable_chatlog		
			chatframe:UpdateCombatLogChatSettings()
		end,
		get = function()
			return E.db.chatPanel.disable_chatlog
		end,	
	}
	
	E.GUI.args.ChatPanel.args.SoundAlert = {		
		name = L['Enable sound alert'],
		type = 'toggle',
		order = 2.2,
		set = function()
			E.db.chatPanel.enable_soundAlert = not E.db.chatPanel.enable_soundAlert
		end,
		get = function()
			return E.db.chatPanel.enable_soundAlert
		end,	
	}
	
	E.GUI.args.ChatPanel.args.History = {		
		name = L['Enable message history'],
		type = 'toggle',
		order = 2.3,
		set = function()
			E.db.chatPanel.history = not E.db.chatPanel.history		
			chatframe:ToggleChatHistory()
		end,
		get = function()
			return E.db.chatPanel.history
		end,	
	}
	
	E.GUI.args.ChatPanel.args.LFRsuppress = {		
		name = L['Suppress whispers while in LFR'],
		type = 'toggle',
		order = 2.4,
		width = 'full',
		set = function()
			E.db.chatPanel.LFRsuppres = not E.db.chatPanel.LFRsuppres
		end,
		get = function()
			return E.db.chatPanel.LFRsuppres
		end,	
	}
	
	E.GUI.args.ChatPanel.args.EnableFriendButton = {		
		name = L['Enable friends toast button'],
		type = 'toggle',
		order = 2.5,
		set = function()
			E.db.chatPanel.EnableFriendButton = not E.db.chatPanel.EnableFriendButton
			chatframe:UpdateFriendButton()
		end,
		get = function()
			return E.db.chatPanel.EnableFriendButton
		end,	
	}
	
	E.GUI.args.ChatPanel.args.UnlockFriendButton = {		
		name = L['Unlock friend button'],
		type = 'execute',
		order = 2.6,
		set = function()
			E:UnlockMover('toastButtonMover')
		end,
		get = function()
			return 
		end,	
	}
	
	E.GUI.args.ChatPanel.args.Width = {
		name = L['Width'],
		order = 3,
		type = 'slider',
		min= 140, max = 900, step = 1,
		set = function(info, value)
			E.db.chatPanel.width = value
			updatePosition.elapsed = 0
		end,
		get = function(info)
			return E.db.chatPanel.width
		end,
	}
	
	E.GUI.args.ChatPanel.args.height = {
		name = L['Height'],
		order = 4,
		type = 'slider',
		min= 100, max = 600, step = 1,
		set = function(info, value)
			E.db.chatPanel.height = value
			updatePosition.elapsed = 0
		end,
		get = function(info)
			return E.db.chatPanel.height
		end,
	}

	E.GUI.args.ChatPanel.args.xOffset = {
		name = L['Horizontal offset'],
		order = 4.1,
		type = 'slider',
		min= 0, max = 2000, step = 1,
		set = function(info, value)
			E.db.chatPanel.xOffset = value
			updatePosition.elapsed = 0
		end,
		get = function(info)
			return E.db.chatPanel.xOffset
		end,
	}
	
	E.GUI.args.ChatPanel.args.yOffset = {
		name = L['Vertical offset'],
		order = 4.2,
		type = 'slider',
		min= 0, max = 2000, step = 1,
		set = function(info, value)
			E.db.chatPanel.yOffset = value
			updatePosition.elapsed = 0
		end,
		get = function(info)
			return E.db.chatPanel.yOffset
		end,
	}
	
	E.GUI.args.ChatPanel.args.editBoxxOffset = {
		name = L['Editbox horizontal offset'],
		order = 4.3,
		type = 'slider',
		min= 0, max = 2000, step = 1,
		set = function(info, value)
			E.db.chatPanel.editBoxxOffset = value
			updatePosition.elapsed = 0
		end,
		get = function(info)
			return E.db.chatPanel.editBoxxOffset
		end,
	}
	
	E.GUI.args.ChatPanel.args.editBoxyOffset = {
		name = L['Editbox vertical offset'],
		order = 4.4,
		type = 'slider',
		min= 0, max = 2000, step = 1,
		set = function(info, value)
			E.db.chatPanel.editBoxyOffset = value
			updatePosition.elapsed = 0
		end,
		get = function(info)
			return E.db.chatPanel.editBoxyOffset
		end,
	}
	
	
	
	E.GUI.args.ChatPanel.args.Background = {
		name = L['Background'],
		type = "group",
		order = 5,
		embend = false,
		args = {},
	}
	--[==[
	E.GUI.args.ChatPanel.args.Background.args.Enable = {		
		name = 'Включить',
		type = 'toggle',
		width = 'full',
		order = 1,
		set = function()
			
		end,
		get = function()
			return false
		end,	
	}
	]==]
	E.GUI.args.ChatPanel.args.Background.args.OffsetLeft = {
		name = L['Offset form left'],
		order = 2,
		type = 'slider',
		min= 0, max = 50, step = 1,
		set = function(info, value)
			E.db.chatPanel.OffsetLeft = value
			chatframe:UpdateChatBackground()	
		end,
		get = function(info)
			return E.db.chatPanel.OffsetLeft
		end,
	}
	
	E.GUI.args.ChatPanel.args.Background.args.OffsetRight = {
		name = L['Offset form right'],
		order = 2.1,
		type = 'slider',
		min= 0, max = 50, step = 1,
		set = function(info, value)
			E.db.chatPanel.OffsetRight = value
			chatframe:UpdateChatBackground()	
		end,
		get = function(info)
			return E.db.chatPanel.OffsetRight
		end,
	}
	
	E.GUI.args.ChatPanel.args.Background.args.OffsetTop = {
		name = L['Offset form top'],
		order = 2.2,
		type = 'slider',
		min= 0, max = 50, step = 1,
		set = function(info, value)
			E.db.chatPanel.OffsetTop = value
			chatframe:UpdateChatBackground()	
		end,
		get = function(info)
			return E.db.chatPanel.OffsetTop
		end,
	}
	
	E.GUI.args.ChatPanel.args.Background.args.OffsetBottom = {
		name = L['Offset form bottom'],
		order = 2.3,
		type = 'slider',
		min= 0, max = 50, step = 1,
		set = function(info, value)
			E.db.chatPanel.OffsetBottom = value
			chatframe:UpdateChatBackground()	
		end,
		get = function(info)
			return E.db.chatPanel.OffsetBottom
		end,
	}
	
	E.GUI.args.ChatPanel.args.Background.args.BorderOpts = {
		name = L['Borders'],
		order = 10,
		embend = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.ChatPanel.args.Background.args.BorderOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L['Border texture'],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.chatPanel.border.texture = value;
			chatframe:UpdateChatBackground()
		end,
		get = function(info) return E.db.chatPanel.border.texture end,
	}

	E.GUI.args.ChatPanel.args.Background.args.BorderOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.chatPanel.border.color={ r, g, b, a}; 
			chatframe:UpdateChatBackground()
		end,
		get = function(info) 
			return E.db.chatPanel.border.color[1],
					E.db.chatPanel.border.color[2],
					E.db.chatPanel.border.color[3],
					E.db.chatPanel.border.color[4] 
		end,
	}

	E.GUI.args.ChatPanel.args.Background.args.BorderOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.chatPanel.border.size = val
			chatframe:UpdateChatBackground()
		end,
		get =function(info)
			return E.db.chatPanel.border.size
		end,
	}

	E.GUI.args.ChatPanel.args.Background.args.BorderOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.chatPanel.border.inset = val
			chatframe:UpdateChatBackground()
		end,
		get =function(info)
			return E.db.chatPanel.border.inset
		end,
	}


	E.GUI.args.ChatPanel.args.Background.args.BorderOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Background texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.chatPanel.border.background_texture = value;
			chatframe:UpdateChatBackground()
		end,
		get = function(info) return E.db.chatPanel.border.background_texture end,
	}

	E.GUI.args.ChatPanel.args.Background.args.BorderOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.chatPanel.border.background_color={ r, g, b, a}
			chatframe:UpdateChatBackground()
		end,
		get = function(info) 
			return E.db.chatPanel.border.background_color[1],
					E.db.chatPanel.border.background_color[2],
					E.db.chatPanel.border.background_color[3],
					E.db.chatPanel.border.background_color[4] 
		end,
	}


	E.GUI.args.ChatPanel.args.Background.args.BorderOpts.args.backgroundInset = {
		name = L['Background inset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.chatPanel.border.background_inset = val
			chatframe:UpdateChatBackground()
		end,
		get =function(info)
			return E.db.chatPanel.border.background_inset
		end,
	}
	
	
	local filterGUIs = {
		{
			addNew = {
				name = L['Name'],
				type = 'editbox',
				order = 3,
				width = 'full',
				set = function(info, value)
				
				end,
				get = function(info)
					return
				end
			},
			selecting = {
				name = L['Select'],
				type = 'dropdown',
				order = 4,
				width = 'full',
				values = function()
					local t = {}
					
					for k, v in pairs(	E.db.chatPanel.nameFilter) do					
						t[k] = k
					end
					
					return t
				end,
				set = function(info, value)
					filterSelectedToken = value
					
					E.db.chatPanel.nameFilter[value] = E.db.chatPanel.nameFilter[value] or { enable = true }
				end,
				get = function(info)
					return filterSelectedToken
				end,
			},
			opts = {
				name = L["Settings"],
				type = "group",
				order = 5,
				embend = true,
				args = {
					enable = {
						name = L['Enable'],
						type = 'toggle',
						order = 1, width = 'full',
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.nameFilter[filterSelectedToken] then
									 E.db.chatPanel.nameFilter[filterSelectedToken].enable = not E.db.chatPanel.nameFilter[filterSelectedToken].enable
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.nameFilter[filterSelectedToken] then
									return E.db.chatPanel.nameFilter[filterSelectedToken].enable
								end
							end
							return false
						end,	
					},						
				},	
			},
		},
		{
			addNew = nil,
			selecting = {
				name = L['Select'],
				type = 'dropdown',
				order = 4,
				width = 'full',
				values = function()
					local t = {}
					
					local totalBNet, numBNetOnline = BNGetNumFriends()
					
					for i=1, totalBNet do
						local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, 
							lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, broadcastTime, canSoR = BNGetFriendInfo(i)
						
						
						t[battleTag] = presenceName..' - '..battleTag.. ( noteText and ' - '..noteText or '')
					end
						
					return t
				end,
				set = function(info, value)
					filterSelectedToken = value			
					E.db.chatPanel.battleTagFilter[value] = E.db.chatPanel.battleTagFilter[value] or { enable = true }
				end,
				get = function(info)
					return filterSelectedToken
				end,
			},
			opts = {
				name = L["Settings"],
				type = "group",
				order = 5,
				embend = true,
				args = {				
					enable = {
						name = L['Enable'],
						type = 'toggle',
						order = 1, width = 'full',
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									 E.db.chatPanel.battleTagFilter[filterSelectedToken].enable = not E.db.chatPanel.battleTagFilter[filterSelectedToken].enable
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									return E.db.chatPanel.battleTagFilter[filterSelectedToken].enable
								end
							end
							return false
						end,	
					},	

					inGame1 = {
						name = format(L['Game: |T%s:0:0|t%s'], BNet_GetClientTexture(BNET_CLIENT_WOW), 'World of Warcraft'),
						type = 'toggle',
						order = 2,
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									 E.db.chatPanel.battleTagFilter[filterSelectedToken].game1 = not E.db.chatPanel.battleTagFilter[filterSelectedToken].game1
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									return E.db.chatPanel.battleTagFilter[filterSelectedToken].game1
								end
							end
							return false
						end,	
					},
					inGame2 = {
						name = format(L['Game: |T%s:0:0|t%s'], BNet_GetClientTexture(BNET_CLIENT_D3), 'Diable 3'),
						type = 'toggle',
						order = 3,
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									 E.db.chatPanel.battleTagFilter[filterSelectedToken].game2 = not E.db.chatPanel.battleTagFilter[filterSelectedToken].game2
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									return E.db.chatPanel.battleTagFilter[filterSelectedToken].game2
								end
							end
							return false
						end,	
					},
					inGame3 = {
						name = format(L['Game: |T%s:0:0|t%s'], BNet_GetClientTexture(BNET_CLIENT_SC2), 'Starcraft 2'),
						type = 'toggle',
						order = 4,
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									 E.db.chatPanel.battleTagFilter[filterSelectedToken].game3 = not E.db.chatPanel.battleTagFilter[filterSelectedToken].game3
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									return E.db.chatPanel.battleTagFilter[filterSelectedToken].game3
								end
							end
							return false
						end,	
					},
					inGame4 = {
						name = format(L['Game: |T%s:0:0|t%s'], BNet_GetClientTexture(BNET_CLIENT_WTCG), 'Heartstone'),
						type = 'toggle',
						order = 5,
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									 E.db.chatPanel.battleTagFilter[filterSelectedToken].game4 = not E.db.chatPanel.battleTagFilter[filterSelectedToken].game4
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									return E.db.chatPanel.battleTagFilter[filterSelectedToken].game4
								end
							end
							return false
						end,	
					},
					inGame5 = {
						name = format(L['Game: |T%s:0:0|t%s'], BNet_GetClientTexture(BNET_CLIENT_OVERWATCH), 'Overwatch'),
						type = 'toggle',
						order = 6,
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									 E.db.chatPanel.battleTagFilter[filterSelectedToken].game5 = not E.db.chatPanel.battleTagFilter[filterSelectedToken].game5
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									return E.db.chatPanel.battleTagFilter[filterSelectedToken].game5
								end
							end
							return false
						end,	
					},
					inGame6 = {
						name = format(L['Game: |T%s:0:0|t%s'], BNet_GetClientTexture(BNET_CLIENT_HEROES), 'Heroest of the Storm'),
						type = 'toggle',
						order = 7,
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									 E.db.chatPanel.battleTagFilter[filterSelectedToken].game6 = not E.db.chatPanel.battleTagFilter[filterSelectedToken].game6
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									return E.db.chatPanel.battleTagFilter[filterSelectedToken].game6
								end
							end
							return false
						end,	
					},
					inGame7 = {
						name = format(L['Client: |T%s:0:0|tBattle.Net'], BNet_GetClientTexture()),
						type = 'toggle',
						order = 8,
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									 E.db.chatPanel.battleTagFilter[filterSelectedToken].game7 = not E.db.chatPanel.battleTagFilter[filterSelectedToken].game7
								end
							end
							
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.battleTagFilter[filterSelectedToken] then
									return E.db.chatPanel.battleTagFilter[filterSelectedToken].game7
								end
							end
							return false
						end,	
					},	
				},	
			},
		},
		{
			addNew = {
				name = L["Message"],
				type = 'editbox',
				order = 3,
				width = 'full',
				set = function(info, value)
					filterSelectedToken = value
					
					E.db.chatPanel.msgFilter[value] = E.db.chatPanel.msgFilter[value] or { enable = true }
					
					UpdateFilterMsgList()
				end,
				get = function(info)
					return
				end
			},
			selecting = {
				name = L['Select'],
				type = 'dropdown',
				order = 4,
				width = 'full',
				values = function()
					local t = {}
					
					for k, v in pairs(E.db.chatPanel.msgFilter) do					
						t[k] = k
					end
					
					return t
				end,
				set = function(info, value)
					filterSelectedToken = value					
					E.db.chatPanel.msgFilter[value] = E.db.chatPanel.msgFilter[value] or { enable = true }				
					UpdateFilterMsgList()
				end,
				get = function(info)
					return filterSelectedToken
				end,
			},
			opts = {
				name = L["Settings"],
				type = "group",
				order = 5,
				embend = true,
				args = {
					enable = {
						name = L['Enable'],
						type = 'toggle',
						order = 1, width = 'full',
						set = function()
							if filterSelectedToken then							
								if E.db.chatPanel.msgFilter[filterSelectedToken] then
									E.db.chatPanel.msgFilter[filterSelectedToken].enable = not E.db.chatPanel.msgFilter[filterSelectedToken].enable
								end
							end
							
							UpdateFilterMsgList()
						end,
						get = function()
							if filterSelectedToken then							
								if E.db.chatPanel.msgFilter[filterSelectedToken] then
									return E.db.chatPanel.msgFilter[filterSelectedToken].enable
								end
							end
							return false
						end,	
					},
				},	
			},
		},
	}
	
	function chatframe:UpdateFilterGUI(index)
		E.GUI.args.ChatPanel.args.Blacklist.args.filteraddNew = filterGUIs[index].addNew
		E.GUI.args.ChatPanel.args.Blacklist.args.filterselecting = filterGUIs[index].selecting
		E.GUI.args.ChatPanel.args.Blacklist.args.filterGUI = filterGUIs[index].opts
	end
	
	local lastScale = 0
	
	function chatframe:UpdateCombatLogChatSettings()
		if E.db.chatPanel.disable_chatlog then
			ChatFrame2Tab:SetScale(0.0001)
		else
			ChatFrame2Tab:SetScale(lastScale)
		end	
	end
	
	if ( QuickJoinToastButton ) then 
		QuickJoinToastButton:ClearAllPoints()
		QuickJoinToastButton:SetPoint('CENTER', toastButtonMover, 'CENTER', 0, 0) 
		
		QuickJoinToastButton.Toast2.Text:SetFont(E.media.default_font2, E.media.default_font_size2)
		QuickJoinToastButton.Toast.Text:SetFont(E.media.default_font2, E.media.default_font_size2)
		
		
		hooksecurefunc(QuickJoinToastButton,'SetPoint', function(self,a1,a2,a3,a4,a5)
			if (a1 ~= 'CENTER' or a2 ~= toastButtonMover or a3 ~= 'CENTER' or a4 ~= 0 or a5 ~= 0) then
				QuickJoinToastButton:ClearAllPoints()
				QuickJoinToastButton:SetPoint('CENTER', toastButtonMover, 'CENTER', 0, 0)
			end
		end)

		hooksecurefunc(QuickJoinToastButton.Toast,'SetPoint', function(self,a1,a2,a3,a4,a5)
			if (a1 ~= 'LEFT' or a2 ~= QuickJoinToastButton or a3 ~= 'RIGHT' or a4 ~= 0 or a5 ~= -1) then
				QuickJoinToastButton.Toast:ClearAllPoints()
				QuickJoinToastButton.Toast:SetPoint('LEFT', QuickJoinToastButton, 'RIGHT', 0, -1)
			end
		end)
		hooksecurefunc(QuickJoinToastButton.Toast2,'SetPoint', function(self,a1,a2,a3,a4,a5)
			if (a1 ~= 'LEFT' or a2 ~= QuickJoinToastButton or a3 ~= 'RIGHT' or a4 ~= 0 or a5 ~= -1) then
				QuickJoinToastButton.Toast2:ClearAllPoints()
				QuickJoinToastButton.Toast2:SetPoint('LEFT', QuickJoinToastButton, 'RIGHT', 0, -1)
			end
		end)

		
		function chatframe:UpdateFriendButton()
			if ( QuickJoinToastButton ) then
				if E.db.chatPanel.EnableFriendButton then
					QuickJoinToastButton:SetParent(E.UIParent)
				else
					QuickJoinToastButton:SetParent(E.hidenframe)
				end
			end
		end
	end 

	local function LoadChatSettings()
		
		--E.db.chatPanel.enable_background
		--E.db.chatPanel.disable_chatlog
		
		if E.db.chatPanel.enable_background then
			chatFrameBackground:Show()
		else
			chatFrameBackground:Hide()
		end
		
		if ( chatframe.UpdateFriendButton ) then
			chatframe:UpdateFriendButton()
		end

		lastScale = ChatFrame2Tab:GetScale()
		
		chatframe:UpdateCombatLogChatSettings()
		
		UpdateFilterMsgList()
		
		chatframe:UpdateChatBackground()	
		
		E:Mover(toastButtonMover, 'toastButtonMover')


		--ChatFrameChannelButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
	end
	
	E.UpdateChatSettings = LoadChatSettings
	E:OnInit2(LoadChatSettings)
end