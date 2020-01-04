--Blizzard_TalkingHeadUI


local AddOn, E = ...
local Skins = E:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'talkingHead'
E.default_settings.skins[varName] = true

local mover = CreateFrame('Frame', nil, E.UIParent)
mover:SetSize(570, 155)
--<Size x="570" y="155"/>


E:OnAddonLoad('Blizzard_TalkingHeadUI', function()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end
	TalkingHeadFrame.ignoreFramePositionManager = true
	UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil
	
	TalkingHeadFrame:ClearAllPoints()
	TalkingHeadFrame:SetPoint("BOTTOM", mover,'BOTTOM', 0, 0)
end)

local function SkinTalkingHead()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end
	
	E:Mover(mover, "TalkingHeadMover")
	
	--[==[
	local events = CreateFrame('Frame')
	events:RegisterEvent('PLAYER_REGEN_ENABLED')
	events:RegisterEvent('PLAYER_REGEN_DISABLED')
	events:SetScript('OnEvent', function(self, event)
		if event == 'PLAYER_REGEN_ENABLED' then
			if not TalkingHeadFrame then
				-- UIParent
				UIParent:RegisterEvent("TALKINGHEAD_REQUESTED");
			else
				TalkingHeadFrame:RegisterEvent("TALKINGHEAD_REQUESTED");
			end
		else
			if not TalkingHeadFrame then
				-- UIParent
				UIParent:UnregisterEvent("TALKINGHEAD_REQUESTED");
			else
				if TalkingHeadFrame:IsVisible() then
					TalkingHeadFrame_CloseImmediately()
				end
				TalkingHeadFrame:UnregisterEvent("TALKINGHEAD_REQUESTED");
			end
		end
	end)
	]==]
end

E:OnInit2(SkinTalkingHead)