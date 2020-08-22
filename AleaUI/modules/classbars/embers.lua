local addonName, E = ...
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "WARLOCK" then return end
if E.IsLegion then return end

local w, h = 50, 10
local maxw, maxh = 200, 10

local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local NUM_SOUL_SHARDS = 4
local SOUL_SHARD_POWER_WORD = 'SOUL_SHARDS'

local color = { 255/255, 114/255, 80/255, 1 }
local color2 = { 41/255, 174/255, 45/255, 1 }

--[[
	data[37] = data[37] + (val-data[37])/options.bar_smooth_value_v2	
	self._maxvalue = options.maximumtime and options.maximumtime_value or data[1]
]]

local function EmbersOnUpdate(f, elapsed)
	local self = f:GetParent()
	local step = (self._currentEmbers - self._lastEmbers)/GetFramerate()
		
	self._lastEmbers = self._lastEmbers + ( step * 6.5)	
	
	if self._lastEmbers > 40 then
		self._lastEmbers = 40
	end
	if self._lastEmbers < 0 then
		self._lastEmbers = 0
	end
	
	self.orbs[1]:SetValue(self._lastEmbers)	
	self.orbs[1].glowIndicator:SetAlpha(self._lastEmbers/40)
	
	self.orbs[1].text:SetText(self._currentEmbers)
end

local function Embers()

	local f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "embersFrame", 200, 10)

	f.orbs = {}
	f.eventlist = {
		["UNIT_POWER_FREQUENT"]		= "player",
		["UNIT_DISPLAYPOWER"]		= "player",
	--	["PLAYER_REGEN_ENABLED"]	= "",
		}
	
	f.bg = f:CreateTexture()
	f.bg:SetColorTexture(0,0,0,1)
	f.bg:SetAllPoints(f)
	f:SetScript("OnUpdate", SoulShardRegen)
	f._lastEmbers = 0

	f:SetSize(maxw, 10)
	
	local o = CreateFrame("StatusBar", nil, f)
	o:SetFrameLevel(f:GetFrameLevel()+1)
	o:SetSize(maxw, 10)
	o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	o:SetPoint("LEFT", f, "LEFT", 0, 0)
	o:SetStatusBarColor(unpack(color))
	o:SetMinMaxValues(0,40)
	o:SetBackdrop({
	  bgFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeFile = [[Interface\Buttons\WHITE8x8]], 
	  tile = false, tileSize = 0, edgeSize = 1, 
	  insets = { left = -1, right = -1, top = -1, bottom = -1}
	})
	o:SetBackdropColor(0,0,0,1)
	o:SetBackdropBorderColor(0,0,0,1)
	
	o:SetScript("OnUpdate", EmbersOnUpdate)
	
	o.text = o:CreateFontString(nil, "OVERLAY")
	o.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	o.text:SetPoint("LEFT", o, "RIGHT", 3, 0)
	o.text:SetJustifyH('LEFT')
	o.text:SetTextColor(unpack(color))
		
	f.orbs[1] = o
	
	f.orbs[1].separator = {}
		
	for i=1, NUM_SOUL_SHARDS-1 do
		
		f.orbs[1].separator[i] = f.orbs[1]:CreateTexture(nil, 'OVERLAY')
		f.orbs[1].separator[i]:SetPoint("LEFT", f, "LEFT", floor(( maxw/NUM_SOUL_SHARDS-1)*(i))+(1*i), 0)
		f.orbs[1].separator[i]:SetSize(1, 10)
		f.orbs[1].separator[i]:SetColorTexture(0, 0, 0, 1)
		
	end
	
	f.orbs[1].glowIndicator = CreateFrame("Frame", nil, f.orbs[1])
	f.orbs[1].glowIndicator:SetFrameStrata("LOW")
	f.orbs[1].glowIndicator:SetBackdrop( {	
 		edgeFile = "Interface\\AddOns\\AleaUI\\media\\glow", edgeSize = 3,
 		insets = {left = 5, right = 5, top = 5, bottom = 5},
 	})		
	f.orbs[1].glowIndicator:SetBackdropBorderColor(unpack(color))
	f.orbs[1].glowIndicator:SetScale(2)
	f.orbs[1].glowIndicator:SetPoint("TOPLEFT", f.orbs[1], "TOPLEFT", -3, 3)
	f.orbs[1].glowIndicator:SetPoint("BOTTOMRIGHT", f.orbs[1], "BOTTOMRIGHT", 3, -3)
	f.orbs[1].glowIndicator:SetAlpha(0)

	function f:PLAYER_REGEN_ENABLED(event, unit)
		soulshard_rege[prev_num+1] = GetTime()
	end
	
	local xeratchcodex = nil
	
	function f:UNIT_POWER_FREQUENT(event, unit, powerType)
		if("player" ~= unit or (powerType and powerType ~= "BURNING_EMBERS")) then return end

	--	local numOrbs = UnitPower("player",SPELL_POWER_BURNING_EMBERS, true)

	--	f.orbs[1]:SetValue(numOrbs)
	
		if IsSpellKnown(101508) then
			if xeratchcodex ~= true then
				xeratchcodex = true
				
				f.orbs[1].glowIndicator:SetBackdropBorderColor(color2[1], color2[2], color2[3], color2[4])
				f.orbs[1]:SetStatusBarColor(color2[1], color2[2], color2[3], color2[4])
			end
		else
			if xeratchcodex ~= false then
				xeratchcodex = false			
				f.orbs[1].glowIndicator:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
				f.orbs[1]:SetStatusBarColor(color[1], color[2], color[3], color[4])
			end
		end
	
		f._gettime = GetTime()
		f._currentEmbers = UnitPower("player",SPELL_POWER_BURNING_EMBERS, true)
	end
	
	f.UNIT_DISPLAYPOWER = f.UNIT_POWER_FREQUENT
	
	f:UNIT_POWER_FREQUENT(_, "player", "BURNING_EMBERS")
	
	f.Update = function(self)
		self:UNIT_POWER_FREQUENT(_, "player", "BURNING_EMBERS")
	end
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = "Разблокировать",
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("embersFrame") 
		end,
		get = function(self)end
	}
	
	return f
end



CBF:AddClassBar(class, 3, Embers)