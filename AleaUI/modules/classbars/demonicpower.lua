local E = AleaUI
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "WARLOCK" then return end
if E.IsLegion then return end

local defaults = {
	width = 200,
	height = 10,
	color = { },
	border = {
		["background_texture"] = AleaUI.media.default_bar_texture_name3,
		["size"] = 1,
		["inset"] = 0,
		["color"] = { 0, 0,  0,  0, },
		["background_inset"] = 0,
		["background_color"] = { 0,  0,  0,  0, },
		["texture"] = AleaUI.media.default_bar_texture_name3,
	},
}

local w, h = 50, 10
local maxw, maxh = 200, 10

local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY
local NUM_SOUL_SHARDS = 1
local DEMONIC_FURY = 'DEMONIC_FURY'

local color = { 174/255, 134/255, 217/255, 1 }
 -- 174, 134, 217 purple
 -- 177, 217, 134 green

local demonboltColor_good_bg = { 0, 0.3, 0, 1 }
local demonboltColor_good = { 0, 0.7, 0, 1  }
local demonboltColor_bad_bg = { 0.5, 0, 0, 1}
local demonboltColor_bad = { 0.8, 0, 0, 1}

local demonboltCost = 80
local demonboltName = GetSpellInfo(157695)
local IsSpellKnown = IsSpellKnown

local function DemoboltUpdate(self, value, power, timer)	
	self:ClearAllPoints()
	
	local dims = ( value * 200 ) / 1000
	
	self:SetWidth(dims)
	self:SetValue(timer)
	
	if power > value then
		self:SetStatusBarColor(demonboltColor_good_bg[1], demonboltColor_good_bg[2],demonboltColor_good_bg[3], demonboltColor_good_bg[4])
		self.tx:SetColorTexture(demonboltColor_good[1], demonboltColor_good[2],demonboltColor_good[3], demonboltColor_good[4])
		self:SetPoint("RIGHT", self.relative2, "RIGHT", 0, 0)
	else
		self:SetStatusBarColor(demonboltColor_bad_bg[1], demonboltColor_bad_bg[2],demonboltColor_bad_bg[3], demonboltColor_bad_bg[4])
		self.tx:SetColorTexture(demonboltColor_bad[1], demonboltColor_bad[2],demonboltColor_bad[3], demonboltColor_bad[4])
		self:SetPoint("LEFT", self.relative1, "LEFT", 0, 0)
	end
end

local function Embers()

	local f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "demonicFrame", 200, 10)

	f.eventlist = {
		["UNIT_POWER_FREQUENT"]		= "player",
		["UNIT_DISPLAYPOWER"]		= "player",
		["PLAYER_TALENT_UPDATE"]  = '',
		["PLAYER_LOGIN"]  = '',
		}
	
	f.bg = f:CreateTexture()
	f.bg:SetColorTexture(0,0,0,1)
	f.bg:SetAllPoints(f)
	f:SetScript("OnUpdate", SoulShardRegen)
	
	for i=1, NUM_SOUL_SHARDS do
		f:SetSize(maxw, 10)
		
		local o = CreateFrame("StatusBar", nil, f)
		o:SetFrameLevel(f:GetFrameLevel()+2)
		o:SetSize(maxw, 10)
		o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
		o:SetPoint("LEFT", f, "LEFT", 0, 0)
		o:SetStatusBarColor(color[1]*0.7,color[2]*0.7,color[3]*0.7, 1)
		o:SetMinMaxValues(0,1000)

		o.art = CreateFrame("Frame", nil, o)
		o.art:SetFrameLevel(o:GetFrameLevel()-1)
		o.art:SetBackdrop({
		  bgFile = [[Interface\Buttons\WHITE8x8]], 
		  edgeFile = [[Interface\Buttons\WHITE8x8]], 
		  edgeSize = 1, 
		})
		o.art:SetBackdropColor(color[1]*0.4,color[2]*0.4,color[3]*0.4, 1)
		o.art:SetBackdropBorderColor(0,0,0,1)
		o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
		o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)
		
		local demoboltOverlay = CreateFrame("StatusBar", nil, f)
		demoboltOverlay.relative1 = o
		demoboltOverlay.relative2 = o:GetStatusBarTexture()
		demoboltOverlay:SetFrameLevel(f:GetFrameLevel()-1)
		demoboltOverlay:SetSize(maxw/NUM_SOUL_SHARDS-1, 20)
		demoboltOverlay:SetPoint("LEFT", o, "LEFT", 0, 0)
		demoboltOverlay:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
		demoboltOverlay:SetStatusBarColor(0.6, 0.6, 0.6, 1)
		demoboltOverlay:SetMinMaxValues(0,1)
		demoboltOverlay:SetReverseFill(true)
		demoboltOverlay:SetValue(1)
		demoboltOverlay.Update = DemoboltUpdate
		demoboltOverlay:SetScript("OnUpdate", function(self, elapsed)
		
			local numOrbs = UnitPower("player",SPELL_POWER_DEMONIC_FURY, true)
			local name, icon, count, debuffType, duration, expirationTime = UnitAura("player", demonboltName, nil, "HARMFUL|PLAYER")		
			local tempCost = demonboltCost*( ( count or 0 ) + 1)
			self:Update(tempCost, numOrbs, ( duration and ( expirationTime - GetTime())/duration ) or 0 )
		end)
		
		demoboltOverlay.tx = demoboltOverlay:CreateTexture(nil, "BACKGROUND")
		demoboltOverlay.tx:SetAllPoints()
		demoboltOverlay.tx:SetColorTexture(1,1,1, 1)
		
		demoboltOverlay.bg = demoboltOverlay:CreateTexture(nil, "BACKGROUND", nil, -1)
		demoboltOverlay.bg:SetPoint("TOPLEFT",demoboltOverlay, "TOPLEFT", -1, 1) 
		demoboltOverlay.bg:SetPoint("BOTTOMRIGHT",demoboltOverlay, "BOTTOMRIGHT", 1, -1)
		demoboltOverlay.bg:SetColorTexture(0,0,0,1)
		
		local numOrbs = UnitPower("player",SPELL_POWER_DEMONIC_FURY, true)	
		local name, icon, count, debuffType, duration, expirationTime = UnitAura("player", demonboltName, nil, "HARMFUL|PLAYER")		
		local tempCost = demonboltCost*( ( count or 0 ) + 1)
		demoboltOverlay:Update(tempCost, numOrbs, ( duration and ( expirationTime - GetTime())/duration ) or 0 )
		
		f.demoboltOverlay = demoboltOverlay
		o.text = o:CreateFontString(nil, "OVERLAY")
		o.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
		o.text:SetPoint("CENTER", o, "CENTER")
		o.text:SetTextColor(unpack(color))
	
		f.bar = o
	end
	 
	function f:UNIT_POWER_FREQUENT(event, unit, powerType)
		if("player" ~= unit or (powerType and powerType ~= DEMONIC_FURY)) then return end

		local numOrbs = UnitPower("player",SPELL_POWER_DEMONIC_FURY, true)
		
		local name, icon, count, debuffType, duration, expirationTime = UnitAura("player", demonboltName, nil, "HARMFUL|PLAYER")
		
		local tempCost = demonboltCost*( ( count or 0 ) + 1)
		f.demoboltOverlay:Update(tempCost, numOrbs, ( duration and ( expirationTime - GetTime())/duration ) or 0 )
		
		f.bar.text:SetText(numOrbs)
		f.bar:SetValue(numOrbs)
	end
	
	f.UNIT_DISPLAYPOWER = f.UNIT_POWER_FREQUENT
	
	f:UNIT_POWER_FREQUENT(_, "player", DEMONIC_FURY)
	
	function f:PLAYER_TALENT_UPDATE()
	
		self:UNIT_POWER_FREQUENT(_, "player", DEMONIC_FURY)
		
		if not IsSpellKnown(157695) then 
			self.demoboltOverlay:Hide()
			return
		else
			self.demoboltOverlay:Show()
		end
	
		local numOrbs = UnitPower("player",SPELL_POWER_DEMONIC_FURY, true)		
		local name, icon, count, debuffType, duration, expirationTime = UnitAura("player", demonboltName, nil, "HARMFUL|PLAYER")		
		local tempCost = demonboltCost*( ( count or 0 ) + 1)
		self.demoboltOverlay:Update(tempCost, numOrbs, ( duration and ( expirationTime - GetTime())/duration ) or 1 )	
	end
	
	f.PLAYER_LOGIN = f.PLAYER_TALENT_UPDATE
	
	f:PLAYER_LOGIN()
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = "Разблокировать",
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("demonicFrame") 
		end,
		get = function(self)end
	}
	
	return f
end



CBF:AddClassBar(class, 2, Embers)