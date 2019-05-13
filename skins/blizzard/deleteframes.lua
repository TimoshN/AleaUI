
local AleaUI_KillFrame = function(frame)
	if not _G[frame] then return end

	if not _G[frame].Kill then
		print('No kill for ', frame)
		return
	end
	
	_G[frame]:Kill()
	
	if( _G[frame].manabar ) then _G[frame].manabar:Kill() end
	if( _G[frame].healthbar ) then _G[frame].healthbar:Kill() end
	if( _G[frame].spellbar ) then _G[frame].spellbar:Kill() end
	if( _G[frame].powerBarAlt ) then _G[frame].powerBarAlt:Kill() end

end

local function KillBlizzardArenaUI()
	for i=1, 5 do
		AleaUI_KillFrame(('ArenaEnemyFrame%d'):format(i))
		AleaUI_KillFrame(('ArenaPrepFrame%d'):format(i))
		AleaUI_KillFrame(('ArenaEnemyFrame%dPetFrame'):format(i))
	end
	
	Arena_LoadUI = function() end
	SetCVar('showArenaEnemyFrames', '0', 'SHOW_ARENA_ENEMY_FRAMES_TEXT')
end

local event_frame = CreateFrame("Frame")
event_frame:SetScript("OnEvent", function(self, event, addon, ...)
	if addon == 'Blizzard_ArenaUI' then
		KillBlizzardArenaUI()
	end
end)

local framelist = {
	['PlayerFrame'] = true,
	['ComboFrame'] = true,
	['TargetFrame'] = true,
	['TargetFrameToT'] = true,
	['FocusFrame'] = true,
	['FocusFrameToT'] = true,
	
	['Boss1TargetFrame'] = true,
	['Boss2TargetFrame'] = true,
	['Boss3TargetFrame'] = true,
	['Boss4TargetFrame'] = true,
	['Boss5TargetFrame'] = true,

	['PetFrame'] = true,
	
	['PaladinPowerBar'] = true,
	['PriestBarFrame'] = true,
	['EclipseBarFrame'] = true,
	['ShardBarFrame'] = true,
	['RuneFrame'] = true,
	['MonkHarmonyBar'] = true,
	['WarlockPowerFrame'] = true,
	['CastingBarFrame'] = false,
	['PetCastingBarFrame'] = false,	
}

if AleaUI.IsLegion then
	framelist['PaladinPowerBar'] = nil
end

local function KillBlizzard()
	for frame, params in pairs(framelist) do
		AleaUI_KillFrame(frame, params)
	end
	
	if not IsAddOnLoaded('Blizzard_ArenaUI') then
		event_frame:RegisterEvent("ADDON_LOADED")
		Arena_LoadUI = function() end
		SetCVar('showArenaEnemyFrames', '0', 'SHOW_ARENA_ENEMY_FRAMES_TEXT')
	else
		KillBlizzardArenaUI()
	end	
end

AleaUI:OnInit(KillBlizzard)
--[[
do
	local function ToggleAddOn(v)
		local f = v and EnableAddOn or DisableAddOn
		f("Blizzard_CompactRaidFrames")
		f("Blizzard_CUFProfiles")
	end
	
	local hidenparent = CreateFrame("Frame")
	hidenparent:RegisterEvent("PLAYER_LOGIN")
	hidenparent:RegisterEvent("ADDON_LOADED")
	hidenparent:SetScript("OnEvent", function(self, event, unit)
		if ( event == "ADDON_LOADED" and unit == "AleaUI" ) or event == "PLAYER_LOGIN" then

			self:UnregisterEvent("PLAYER_LOGIN")
			self:UnregisterEvent("ADDON_LOADED")
			
			if not IsAddOnLoaded("AleaUI-RaidFrames") then
				ToggleAddOn(true)
			end
		end
	end)
end
]]