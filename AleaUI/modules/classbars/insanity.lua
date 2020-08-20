local E = AleaUI
if not E.IsClass("PRIEST") then return end

local CBF = E:Module("ClassBars")


local w, h = 50, 10
local maxw, maxh = 200, 10

local color = { RAID_CLASS_COLORS["PRIEST"].r, RAID_CLASS_COLORS["PRIEST"].g, RAID_CLASS_COLORS["PRIEST"].b, 1 }

local function InsanityBar()
	local f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "insanityFrame")
	
	f.orbs = {}
	f.eventlist = {
		["UNIT_POWER_FREQUENT"]		= "player",
		["UNIT_DISPLAYPOWER"]		= "player",		
		["UNIT_SPELLCAST_STOP"]		= "player",
	--	["UNIT_SPELLCAST_FAILED"]	= "player",
		["UNIT_SPELLCAST_START"]	= "player",
		["UNIT_SPELLCAST_CHANNEL_START"]	= "player",
		["UNIT_SPELLCAST_CHANNEL_UPDATE"]	= "player",
		["UNIT_SPELLCAST_CHANNEL_STOP"]		= "player",
	}
	
	f:SetSize(maxw, 10)
		
	local o = CreateFrame("StatusBar", nil, f)
	o:SetFrameLevel(f:GetFrameLevel()+1)
	o:SetSize(maxw, maxh)
	o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	o:SetPoint("LEFT", f, "LEFT", 0, 0)
	o:SetStatusBarColor(color[1]*0.8,color[2]*0.8,color[3]*0.8, 1)
	o:SetMinMaxValues(0, 100)
	
	o.art = CreateFrame("Frame", nil, o, BackdropTemplateMixin and 'BackdropTemplate')
	o.art:SetFrameLevel(o:GetFrameLevel()-1)
	o.art:SetBackdrop({
	  bgFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeSize = 1, 
	})
	o.art:SetBackdropColor(color[1]*0.2,color[2]*0.2,color[3]*0.2, 1)
	o.art:SetBackdropBorderColor(0,0,0,1)
	o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
	o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)
	
	o.texture = o:GetStatusBarTexture()
	
	o.overlay = o:CreateTexture(nil, 'OVERLAY')
	o.overlay:SetPoint('LEFT', o.texture, 'RIGHT', 0, 0)
	o.overlay:SetPoint('TOP', o.texture, 'TOP', 0,0)
	o.overlay:SetPoint('BOTTOM', o.texture, 'BOTTOM', 0,0)
	o.overlay:Hide()
	o.overlay:SetColorTexture(0.4, 0.4, 0.4, 1)
	
	o.text = o:CreateFontString(nil, 'OVERLAY')
	o.text:SetPoint('CENTER', o, 'CENTER', 0, 0)
	o.text:SetFontObject('GameFontWhite')
	o.text:SetShadowColor(0,0,0,1)
	o.text:SetShadowOffset(1, -1)
	o.text:SetText('0(0)')
	
	f.bar = o

	
	function f:UNIT_POWER_FREQUENT(event, unit, powerType)	
		if unit ~= 'player' then return end
		if powerType ~= E.PowerTypeString.Insanity then return end
		
		local value = UnitPower('player', E.PowerType.Insanity)
		
		f.bar:SetValue(value)
		
		f:UpdateOverlay()
	end
	
	function f:UNIT_SPELLCAST_START(event, unit)
		local cost = 0;

		if event == "UNIT_SPELLCAST_START" then
			local spellID = select(9, UnitCastingInfo("player"));
			
			cost = f:GetSpellCost(spellID)
		elseif event == 'UNIT_SPELLCAST_CHANNEL_START' or event == 'UNIT_SPELLCAST_CHANNEL_UPDATE' then
			local name = UnitChannelInfo("player");
			cost = f:GetSpellCost(name)
		end	
		
		self.predictedPowerCost = cost;
		
		f:UpdateOverlay()
	end		
	
	f.UNIT_SPELLCAST_STOP = f.UNIT_SPELLCAST_START
	f.UNIT_SPELLCAST_FAILED = f.UNIT_SPELLCAST_START
		
	f.UNIT_SPELLCAST_CHANNEL_START = f.UNIT_SPELLCAST_START
	f.UNIT_SPELLCAST_CHANNEL_UPDATE = f.UNIT_SPELLCAST_START
	f.UNIT_SPELLCAST_CHANNEL_STOP = f.UNIT_SPELLCAST_START
	
	function f:UpdateOverlay()
		local cost = self.predictedPowerCost or 0
		
		local maxValue = 100 - f.bar:GetValue()
		if cost > maxValue then
			cost = maxValue
		end

		if cost > 0 then
		
			local width = cost/100*CBF:GetOptions().width
		
			self.bar.overlay:SetWidth(width)
			self.bar.overlay:Show()
		else
			self.bar.overlay:Hide()
		end
		
		if cost > 0 then
			o.text:SetFormattedText('%d|cFF808080+%d|r', f.bar:GetValue(), cost)
		else
			o.text:SetFormattedText('%d', f.bar:GetValue())
		end
	
		if AuraUtil.FindAuraByName((GetSpellInfo(193223)), 'player', "HELPFUL") and f.bar:GetValue() < ( AuraUtil.FindAuraByName((GetSpellInfo(10060)), 'player', "HELPFUL") and 25 or 35 ) then	
			f.bar:SetStatusBarColor(color[1]*0.8,color[2]*0.2,color[3]*0.2, 1)			
			f.bar.overlay:SetColorTexture(0.4, 0.4, 0.4, 1)
		elseif not AuraUtil.FindAuraByName((GetSpellInfo(228264)), 'player', "HELPFUL") and E.IsTalentKnown(193225) and f.bar:GetValue() + ( self.predictedPowerCost or 0 ) >= 60 then		
			f.bar:SetStatusBarColor(color[1]*0.2,color[2]*0.6,color[3]*0.2, 1)			
			f.bar.overlay:SetColorTexture(0.3, 0.5, 0.3, 1)
		else
			f.bar:SetStatusBarColor(color[1]*0.8,color[2]*0.8,color[3]*0.8, 1)
			f.bar.overlay:SetColorTexture(0.4, 0.4, 0.4, 1)
		end
	end
	
	local baseCost = {
		[8092] = 15,
		[34914] = 6,
		[263346] = 30,
		[205351] = 15,
	--	[GetSpellInfo(15407)] = 3,
	}
	function f:GetSpellCost(spellID)
		local cost = baseCost[spellID] or 0
		
		if spellID == 8092 then			
			local _, _, _, count = AuraUtil.FindAuraByName((GetSpellInfo(247226)), 'player', "HELPFUL")
			
			if count then
				cost = cost + count
			end
		end
		
		local modif = 1
		if AuraUtil.FindAuraByName((GetSpellInfo(193223)), 'player', "HELPFUL") then
			modif = modif + 1
		end
		if AuraUtil.FindAuraByName((GetSpellInfo(10060)), 'player', "HELPFUL") then
			modif = modif + 0.25
		end
		
	
		return cost * modif
	end
		
	f.UNIT_DISPLAYPOWER = f.UNIT_POWER_FREQUENT
	f.PLAYER_REGEN_ENABLED = f.PLAYER_REGEN_ENABLED
	
	f:UNIT_POWER_FREQUENT(_, "player", E.PowerTypeString.Insanity)
	
	function f:UpdateStyle()
		local opts = CBF:GetOptions()
		f:SetSize(opts.width, opts.height)
		f.bar:SetSize(opts.width, opts.height)
		f.bar:SetStatusBarTexture(E:GetTexture(opts.texture))
	end
	
	f.Update = function(self)
		self:UNIT_POWER_FREQUENT(_, "player", E.PowerTypeString.Insanity)
		
		f:UpdateStyle()
	end
	
	f:Update()
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = E.L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("insanityFrame") 
		end,
		get = function(self)end
	}
	
	E.GUI.args.unitframes.args.classBars.args.width = {
		name = E.L['Width'],
		order = 3,
		type = 'slider',
		min=1, max = 600, step = 1,
		set = function(info, value)
			CBF:SetOptions('width', value)
			f:UpdateStyle()
		end,
		get = function(info)
			return CBF:GetOptions('width')
		end,
	}
	
	E.GUI.args.unitframes.args.classBars.args.height = {
		name = E.L['Height'],
		order = 4,
		type = 'slider',
		min=1, max = 600, step = 1,
		set = function(info, value)
			CBF:SetOptions('height', value)
			f:UpdateStyle()
		end,
		get = function(info)
			return CBF:GetOptions('height')
		end,
	}
	
	E.GUI.args.unitframes.args.classBars.args.texture = {
		order = 5,
		type = 'statusbar',
		name = E.L['Texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			CBF:SetOptions('texture', value)
			f:UpdateStyle()
		end,
		get = function(info) 
			return CBF:GetOptions('texture')
		end,
	}

	return f
end

CBF:AddClassBar('PRIEST', 3, InsanityBar)