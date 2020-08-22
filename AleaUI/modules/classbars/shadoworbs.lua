local addonName, E = ...
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "PRIEST" then return end
if E.IsLegion then return end

local defaults = {
	width = 200,
	height = 10,
	color = { 1, 1, 1, 1},
	border = {
		["background_texture"] = E.media.default_bar_texture_name3,
		["size"] = 1,
		["inset"] = 0,
		["color"] = { 0, 0,  0,  0, },
		["background_inset"] = 0,
		["background_color"] = { 0,  0,  0,  0, },
		["texture"] = E.media.default_bar_texture_name3,
	},
	
	enable_as = true,
	as_point = 'RIGHT',
}


local w, h = 200, 10

local SHADOW_ORBS_SHOW_LEVEL = E:CheckLevelBonus(157217) and 5 or 3
local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS

local f

local AS_module = CreateFrame('Frame')
AS_module:Hide()

local OnEvent = function(self, event)

	if not f then return end

	if E:CheckLevelBonus(157217) then		
		SHADOW_ORBS_SHOW_LEVEL = 5
	else
		SHADOW_ORBS_SHOW_LEVEL = 3
	end
	
	if IsSpellKnown(155271) then
		AS_module:EnableAs()
	else
		AS_module:DisableAs()
	end
	
	for i=1, 4 do		
		f.bar.separators[i]:Hide()
	end
	
	for i=1, SHADOW_ORBS_SHOW_LEVEL-1 do
		f.bar.separators[i]:ClearAllPoints()
		f.bar.separators[i]:SetPoint('LEFT', f.bar, 'LEFT', w/SHADOW_ORBS_SHOW_LEVEL*i, 0)
		f.bar.separators[i]:Show()	
	end
	
	f.bar:SetMinMaxValues(0,SHADOW_ORBS_SHOW_LEVEL)
end

local function CreateShadowOrbBar()

	f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "shadoworbFrame", w, h)

	f._AS_String = f:CreateFontString()
	f._AS_String:SetFont(E.media.default_font, 12, 'OUTLINE')
	f._AS_String:SetPoint('LEFT', f, 'RIGHT', 2, 0)
	f._AS_String:SetJustifyH('CENTER')
	f._AS_String:SetWidth(15)
	f._AS_String:SetText(0)
	
	f._AS_String.background = f:CreateTexture()
	f._AS_String.background:SetAllPoints(f._AS_String)
	f._AS_String.background:SetColorTexture(0, 0, 0, 0.7)

	f.eventlist = { 
		["UNIT_POWER_FREQUENT"]		= "player",
		["UNIT_DISPLAYPOWER"]		= "player",
		["PLAYER_ENTERING_WORLD"]	= true,
		['ZONE_CHANGED']            = true,
		['ZONE_CHANGED_NEW_AREA']   = true,
		['ZONE_CHANGED_INDOORS']    = true,
		}

	f:SetSize(w, h)
	
	local o = CreateFrame("StatusBar", nil, f)
	o:SetSize(w, h)
	o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	o:SetPoint("LEFT", f, "LEFT", 0, 0)
	o:SetStatusBarColor(1,1,1,1)
	o:SetMinMaxValues(0,SHADOW_ORBS_SHOW_LEVEL)
	o:SetValue(0)
	o:SetStatusBarColor(1*0.7,1*0.7,1*0.7, 1)
	
	o.art = CreateFrame("Frame", nil, o)
	o.art:SetFrameLevel(o:GetFrameLevel()-1)
	o.art:SetBackdrop({
	  bgFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeSize = 1, 
	})
	o.art:SetBackdropColor(1*0.4,1*0.4,1*0.4, 1)
	o.art:SetBackdropBorderColor(0,0,0,1)
	o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
	o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)
	
	f.bar = o
	
	f.bar.separators = {}
	
	for i=1, 4 do
		local s = f.bar:CreateTexture()
		s:SetDrawLayer('ARTWORK', 1)
		s:SetSize(1, h)
		s:SetColorTexture(0,0,0,1)
		s:SetPoint('LEFT', f.bar, 'LEFT', w/SHADOW_ORBS_SHOW_LEVEL*i, 0)
		
		f.bar.separators[i] = s
	end
	
	function f:UNIT_POWER_FREQUENT(event, unit, power)	
		if unit ~= "player" then return end
		
		local numOrbs = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
	
		f.bar:SetValue(numOrbs)
	end
	
	f.UNIT_DISPLAYPOWER = f.UNIT_POWER_FREQUENT
	f.PLAYER_ENTERING_WORLD = function(self)
		self:UNIT_POWER_FREQUENT(nil, "player")	
	end
	
	f:UNIT_POWER_FREQUENT(_, "player")	
	f.ZONE_CHANGED = f.PLAYER_ENTERING_WORLD
	f.ZONE_CHANGED_INDOORS = f.ZONE_CHANGED
	f.ZONE_CHANGED_NEW_AREA = f.ZONE_CHANGED
	
	OnEvent()
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = "Разблокировать",
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("shadoworbFrame") 
		end,
		get = function(self)end
	}
	
	return f
end

local eventframe = CreateFrame("Frame")
eventframe:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player",'')
eventframe:RegisterEvent("PLAYER_TALENT_UPDATE")
eventframe:RegisterEvent("PLAYER_LEVEL_UP")
eventframe:RegisterEvent("SPELLS_CHANGED")

eventframe:SetScript("OnEvent", OnEvent)

CBF:AddClassBar("PRIEST", 3, CreateShadowOrbBar)

-- Auspicious Spirits / Shadowy Apparition tracker. -- By Twintop - Kel'Thuzad-US, 2015/03/15

local SA_STATS = {}
local SA_TOTAL = 0
local SA_NUM_UNITS = 0
local SA_DEAD = {}
local LAST_CONTINUITY_CHECK = GetTime()
local WA_SA_NUM_UNITS = 0

function AS_module:EnableAs()

	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')	
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	AS_module:Show()
	f._AS_String:Show()
	f._AS_String.background:Show()
end

function AS_module:DisableAs()
	
	self:UnregisterAllEvents()
	AS_module:Hide()
	f._AS_String:Hide()
	f._AS_String.background:Hide()
end


function AS_module:SA_Cleanup(guid)
	if SA_STATS[guid] then
		SA_TOTAL = SA_TOTAL - SA_STATS[guid].Count;
		
		if SA_TOTAL < 0 then
			SA_TOTAL = 0;
		end
		
		SA_STATS[guid].Count = nil;
		SA_STATS[guid].LastUpdate = nil;
		SA_STATS[guid] = nil;
		
		SA_NUM_UNITS = SA_NUM_UNITS - 1;
		
		if SA_NUM_UNITS < 0 then
			SA_NUM_UNITS = 0;
		end
	end
end 
	
AS_module:SetScript('OnUpdate', function(self, elapsed)
	self.elapsed = ( self.elapsed or 0 ) + elapsed
	if self.elapsed < 0.1 then return end
	self.elapsed = 0
	
	local RETURN = -1;
	local totalSAs = 0;    
	local LastTime = GetTime();
	local CurrentTime = GetTime();
	local color = "FFFFFFFF";
	local orbCount = UnitPower("player", SPELL_POWER_SHADOW_ORBS, forceUpdate);
	
	SA_NUM_UNITS = SA_NUM_UNITS or 0;
	
	if SA_NUM_UNITS > 0 then
		for guid,count in pairs(SA_STATS) do
			totalSAs = totalSAs + SA_STATS[guid].Count;
			LastTime = SA_STATS[guid].LastUpdate;
		end
		
		if totalSAs > SA_TOTAL then
			RETURN = SA_TOTAL or 0;
		else
			RETURN = totalSAs or 0;
		end
	else
		RETURN = -2;
	end
	
	if RETURN <= 0 then
		f._AS_String:SetText(string.format("|c%s%s|r",color,'0'))
		return;
	end
	
	if (orbCount + RETURN) >= 5 and orbCount >= 3 then
		color = "FFFF0000";
	else
		color = "FFFFFFFF";
	end

	f._AS_String:SetText(string.format("|c%s%s|r",color,RETURN))
end)

AS_module:SetScript('OnEvent', function(self, event)
    local CurrentTime = GetTime();

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local time,type,_,sourceGUID,sourcename,_,_,destGUID,destname,_,_,spellid,spellname,_,_,_,_,_,_,_,spellcritical,_,_,_,spellmultistrike = CombatLogGetCurrentEventInfo()
		
		if sourceGUID == UnitGUID("player") then
			if spellid == 147193 and type == "SPELL_CAST_SUCCESS" then -- Shadowy Apparition Spawned
				if not SA_STATS[destGUID] or SA_STATS[destGUID] == nil then
					SA_STATS[destGUID] = {};
					SA_STATS[destGUID].Count = 0;
					SA_NUM_UNITS = SA_NUM_UNITS + 1;
				end
				
				SA_TOTAL = SA_TOTAL + 1;
				SA_STATS[destGUID].Count = SA_STATS[destGUID].Count + 1;
				SA_STATS[destGUID].LastUpdate = CurrentTime;
			elseif spellid == 155521 and type == "SPELL_CAST_SUCCESS" then -- Auspicious Spirit Hit
				SA_TOTAL = SA_TOTAL - 1;
				if SA_STATS[destGUID] and SA_STATS[destGUID].Count > 0 then   
					SA_STATS[destGUID].Count = SA_STATS[destGUID].Count - 1;
					SA_STATS[destGUID].LastUpdate = CurrentTime;
					
					if SA_STATS[destGUID].Count <= 0 then
						AS_module:SA_Cleanup(destGUID);
					end
				end
			end
		end
		
		if (type == "UNIT_DIED" or type == "UNIT_DESTROYED" or type == "SPELL_INSTAKILL") then -- Unit Died, remove them from the target list.
			AS_module:SA_Cleanup(destGUID);
		end
    end
    
    if SA_TOTAL < 0 then
        SA_TOTAL = 0;
    end
    
    for guid,count in pairs(SA_STATS) do
        if (CurrentTime - SA_STATS[guid].LastUpdate) > 10 then
            --If we haven't had a new SA spawn in 10sec, that means all SAs that are out have hit the target (usually), or, the target disappeared.
            AS_module:SA_Cleanup(guid);
        end
    end
    
    if UnitIsDeadOrGhost("player") or not UnitAffectingCombat("player") or event == "PLAYER_REGEN_ENABLED" then -- We died, or, exited combat, go ahead and purge the list
        for guid,count in pairs(SA_STATS) do 
            AS_module:SA_Cleanup(guid);
        end
        
        SA_STATS = {};
        SA_NUM_UNITS = 0;
        SA_TOTAL = 0;
    end
    
    if CurrentTime - LAST_CONTINUITY_CHECK > 10 then --Force check of unit count every 10sec
        local newUnits = 0;
        for guid,count in pairs(SA_STATS) do
            newUnits = newUnits + 1;
        end
        SA_NUM_UNITS = newUnits;
        LAST_CONTINUITY_CHECK = CurrentTime;
    end
    
    if SA_NUM_UNITS > 0 then 
        local totalSAs = 0;
        
        for guid,count in pairs(SA_STATS) do
            if SA_STATS[guid].Count <= 0 or (UnitIsDeadOrGhost(guid)) then
                SA_DEAD[guid] = true;
            else
                totalSAs = totalSAs + SA_STATS[guid].Count;
            end
        end
        
        if totalSAs > 0 and SA_TOTAL > 0 then
            return true;
        end
    end
    
    return false;
end)