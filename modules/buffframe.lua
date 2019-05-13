local addon, E = ...
local _
local L = E.L
local config ={
    buffAnchor = { "TOPRIGHT", "UIParent", "TOPRIGHT", -15, -15 },
    debuffAnchor = { "TOPRIGHT", "UIParent", "TOPRIGHT", -15, -135 },

    -- horizontal distance between icons in a row 
    -- (positive values -> to the right, negative values -> to the left)
    buffXoffset = -35,
    debuffXoffset = -35,

    -- vertical distance between icons in a row 
    -- (positive values -> up, negative values -> down)
    buffYoffset = 0,
    debuffYoffset = 0,

    -- maximum number of icons in one row before a new row starts
    buffIconsPerRow = 10,
    debuffIconsPerRow = 10,

    -- maximum number of rows
    buffMaxWraps = 10,
    debuffMaxWraps = 10,

    -- horizontal offset when starting a new row
    -- (positive values -> to the right, negative values -> to the left)
    buffWrapXoffset = 0,
    debuffWrapXoffset = 0,

    -- vertical offset when starting a new row
    -- (positive values -> up, negative values -> down)
    buffWrapYoffset = -55,
    debuffWrapYoffset = -55,

    -- scale
    buffScale = 1,
    debuffScale = 1,
	
	timeformat = 1,
	
    sortMethod = "INDEX",            -- how to sort the buffs/debuffs, possible values are "NAME", "INDEX" or "TIME"
    sortReverse = false,             -- reverse sort order
    showWeaponEnch = true,          -- show or hide temporary weapon enchants
    showDurationTimers = true,      -- show or hide the duration text timers
    coloredBorder = true,           -- highlight debuffs and weapon enchants with a different border color
    borderBrightness = 0,        -- brightness of the default non-colored icon border ( 0 -> black, 1 -> white )
    blinkTime = 6,                  -- a buff/debuff icon will blink when it expires in less than x seconds, set to 0 to disable
    blinkSpeed = 1.2,              -- blinking speed as number of blink cycles per second


    -- position of duration text
    -- possible values are "TOP", "BOTTOM", "LEFT" or "RIGHT"
    durationPos = "BOTTOM",
    durationXoffset = 0,
    durationYoffset = 0,

    -- position of stack counter
    stacksXoffset = 0,
    stacksYoffset = 0,

    -- font settings
    -- style can be "MONOCHROME", "OUTLINE", "THICKOUTLINE" or nil
    -- color table as { r, g, b, a }
    
    -- duration text
    durationFont = "Gothic-Bold", --"Interface\\AddOns\\AleaUI\\media\\RobotoCondensed.ttf",
    durationFontColor = { 1.0, 1.0, 1.0, 1 },
    durationFontStyle = "OUTLINE",
    durationFontSize = 11,

    -- stack count text
    stackFont = "Gothic-Bold",
    stackFontColor = { 1.0, 1.0, 1.0, 1 },
    stackFontStyle = "OUTLINE",
    stackFontSize = 11,
	
	["border"] = {
		["background_texture"] = AleaUI.media.default_bar_texture_name3,
		["size"] = 1,
		["inset"] = 0,
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
			0.6,  
		},
		["texture"] = AleaUI.media.default_bar_texture_name3,
	}
}

E.default_settings.buffframe = {}
E.default_settings.buffframe.config = config

local grey = config.borderBrightness

-- init secure aura headers
local buffHeader = CreateFrame("Frame", "AleaUIBuffs_Buffs", E.UIParent, "SecureAuraHeaderTemplate")
local debuffHeader = CreateFrame("Frame", "AleaUIBuffs_Debuffs", E.UIParent, "SecureAuraHeaderTemplate")

local buffHeaderMover = CreateFrame('Frame', nil, E.UIParent)
	buffHeaderMover:SetSize(1,1)
	
	buffHeader:SetPoint('TOPRIGHT', buffHeaderMover, TOPRIGHT, 0, 0)
	
local debuffHeaderMover = CreateFrame('Frame', nil, E.UIParent)
	debuffHeaderMover:SetSize(1,1)
	
	debuffHeader:SetPoint('TOPRIGHT', debuffHeaderMover, TOPRIGHT, 0, 0)
	
local DEFAULT_AURA_COLOR = {
	[""] = {r = 0.8, g = 0, b = 0 },
	["Disease"] = { r= 0.6, g = 0.4, b = 0 },
	["Poison"] = { r = 0, g = 0.6, b = 0 },
	["Curse"] = { r = 0.6, g = 0, b = 1},
	["Magic"] = { r = 0.2, g = 0.6, b = 1},
	["none"] = { r = 0.8, g = 0, b = 0},
}

do
    local child

    local function btn_iterator(self, i)
        i = i + 1
        child = self:GetAttribute("child" .. i)
        if child and child:IsShown() then return i, child, child:GetAttribute("index") end
    end

    function buffHeader:ActiveButtons() return btn_iterator, self, 0 end
    function debuffHeader:ActiveButtons() return btn_iterator, self, 0 end
	
	
	local function ButtonInterator(self, func)
		
		local i = 0
		
		while true do
			i = i + 1
			local btn = self:GetAttribute("child" .. i)
			
			if not btn then 
				return
			end
			
			if btn[func] then btn[func](btn) end
		end
	end
	
	buffHeader.ButtonInterator = ButtonInterator
	debuffHeader.ButtonInterator = ButtonInterator
end

E.CreateAuraButtonArtwork = function(...)end

local createAuraButton
do
    local s, b = 1, 3 / 28
    local ic, tx, cd, br, bd, bg, vf, dr, st
	local helpful_backdrop = { 
		edgeFile =	[[Interface\Buttons\WHITE8x8]],
		edgeSize = 1,
	}
	local harmful_backdrop = { 
		bgFile = [[Interface\Buttons\WHITE8x8]], 
		edgeFile =	[[Interface\Buttons\WHITE8x8]],
		edgeSize = 1,
		insets = {
			left = -1,
			right = -1,
			top = -1,
			bottom = -1
		}
	}
	
	local function UpdateStyle(self)
		
		local n = E.db.buffframe.config
		local dX, dY = n.durationXoffset, n.durationYoffset

        self.text:SetTextColor(n.durationFontColor[1], n.durationFontColor[2],n.durationFontColor[3],1)
        self.text:SetFont(E:GetFont(n.durationFont), n.durationFontSize, n.durationFontStyle)
	
		
		if n.durationPos == "TOP" then self.text:SetPoint("BOTTOM", self.icon, "TOP", dX, 2 + dY)
        elseif n.durationPos == "LEFT" then self.text:SetPoint("RIGHT", self.icon, "LEFT", dX - 2, dY)
        elseif n.durationPos == "RIGHT" then self.text:SetPoint("LEFT", self.icon, "RIGHT", 2 + dX, dY)
        else self.text:SetPoint("TOP", self.icon, "BOTTOM", dX,  dY - 2) end
		
		self.stacks:SetPoint("BOTTOMRIGHT", self.icon, "BOTTOMRIGHT", 4 + n.stacksXoffset, n.stacksYoffset - 2)
        self.stacks:SetTextColor(n.stackFontColor[1],n.stackFontColor[2],n.stackFontColor[3],1)
        self.stacks:SetFont(E:GetFont(n.stackFont), n.stackFontSize, n.stackFontStyle)
		
		self.icon.artBorder:SetBackdrop({
		  edgeFile = E:GetBorder(n.border.texture),
		  edgeSize = n.border.size, 
		})
		self.icon.artBorder:SetBackdropBorderColor(n.border.color[1],n.border.color[2],n.border.color[3],n.border.color[4])
		self.icon.artBorder:SetPoint("TOPLEFT", self.icon, "TOPLEFT", n.border.inset, -n.border.inset)
		self.icon.artBorder:SetPoint("BOTTOMRIGHT", self.icon, "BOTTOMRIGHT", -n.border.inset, n.border.inset)

		self.icon.artBorder.back:SetTexture(E:GetTexture(n.border.background_texture))
		self.icon.artBorder.back:SetVertexColor(n.border.background_color[1],n.border.background_color[2],n.border.background_color[3],n.border.background_color[4])
		self.icon.artBorder.back:SetPoint("TOPLEFT", self.icon, "TOPLEFT", n.border.background_inset, -n.border.background_inset)
		self.icon.artBorder.back:SetPoint("BOTTOMRIGHT", self.icon, "BOTTOMRIGHT", -n.border.background_inset, n.border.background_inset)
		
	end
	
    createAuraButton = function(btn, filter)
        -- subframe for icon and border
		
		local n = E.db.buffframe.config
		local dX, dY = n.durationXoffset, n.durationYoffset
		
        ic = CreateFrame("Button", nil, btn)
        ic:SetAllPoints(btn)
        ic:SetFrameLevel(btn:GetFrameLevel()+2)
        ic:EnableMouse(false)
		--[==[
		if filter == 'HARMFUL' then
			
			ic.border = CreateFrame('Frame', nil, btn)
			ic.border:SetFrameLevel(btn:GetFrameLevel()+1)
			ic.border:SetOutside(btn)
			ic.border:SetBackdrop(harmful_backdrop)
			ic.border:SetBackdropColor(0,0,0,1)
			ic.border:SetBackdropBorderColor(1,1,0,1)
		
		else
			ic.border = CreateFrame('Frame', nil, btn)
			ic.border:SetFrameLevel(btn:GetFrameLevel()+1)
			ic.border:SetOutside(btn, 0,0)
			ic.border:SetBackdrop(helpful_backdrop)
			ic.border:SetBackdropBorderColor(1,1,0,1)
			
		end
		]==]
		
		ic.artBorder = CreateFrame("Frame", nil, ic)
		ic.artBorder:SetFrameLevel(ic:GetFrameLevel()+1)
		ic.artBorder:SetBackdrop({
		  edgeFile = E:GetBorder(n.border.texture),
		  edgeSize = n.border.size, 
		})
		ic.artBorder:SetBackdropBorderColor(n.border.color[1],n.border.color[2],n.border.color[3],n.border.color[4])
		ic.artBorder:SetPoint("TOPLEFT", ic, "TOPLEFT", n.border.inset, -n.border.inset)
		ic.artBorder:SetPoint("BOTTOMRIGHT", ic, "BOTTOMRIGHT", -n.border.inset, n.border.inset)

		ic.artBorder.back = ic:CreateTexture()
		ic.artBorder.back:SetDrawLayer('BACKGROUND', -2)
		ic.artBorder.back:SetTexture(E:GetTexture(n.border.background_texture))
		ic.artBorder.back:SetVertexColor(n.border.background_color[1],n.border.background_color[2],n.border.background_color[3],n.border.background_color[4])
		ic.artBorder.back:SetPoint("TOPLEFT", ic, "TOPLEFT", n.border.background_inset, -n.border.background_inset)
		ic.artBorder.back:SetPoint("BOTTOMRIGHT", ic, "BOTTOMRIGHT", -n.border.background_inset, n.border.background_inset)
		
		
        btn.icon = ic

        -- icon texture
        tx = ic:CreateTexture(nil, "ARTWORK")
        tx:SetPoint("TOPLEFT", s, -s)
        tx:SetPoint("BOTTOMRIGHT", -s, s)
        tx:SetTexCoord(b, 1-b, b, 1-b)
		
        btn.icon.tex = tx
		
        -- subframe for value texts
		
        vf = CreateFrame("Frame", nil, btn)
        vf:SetAllPoints(btn)
        vf:SetFrameLevel(20)
        btn.vFrame = vf
		
		
        -- duration text
        dr = vf:CreateFontString(nil, "OVERLAY")
        dr:SetFontObject(GameFontNormalSmall)
        dr:SetTextColor(n.durationFontColor[1], n.durationFontColor[2],n.durationFontColor[3],1)
        dr:SetFont(E:GetFont(n.durationFont), n.durationFontSize, n.durationFontStyle)
        btn.text = dr

        if n.durationPos == "TOP" then dr:SetPoint("BOTTOM", ic, "TOP", dX, 2 + dY)
        elseif n.durationPos == "LEFT" then dr:SetPoint("RIGHT", ic, "LEFT", dX - 2, dY)
        elseif n.durationPos == "RIGHT" then dr:SetPoint("LEFT", ic, "RIGHT", 2 + dX, dY)
        else dr:SetPoint("TOP", ic, "BOTTOM", dX,  dY - 2) end

        -- stack count
        st = vf:CreateFontString(nil, "OVERLAY")
        st:SetPoint("BOTTOMRIGHT", ic, "BOTTOMRIGHT", 4 + n.stacksXoffset, n.stacksYoffset - 2)
        st:SetFontObject(GameFontNormalSmall)
        st:SetTextColor(n.stackFontColor[1],n.stackFontColor[2],n.stackFontColor[3],1)
        st:SetFont(E:GetFont(n.stackFont), n.stackFontSize, n.stackFontStyle)
        btn.stacks = st

        btn.lastUpdate = 0
        btn.filter = filter
        btn.created = true
        btn.cAlpha = 1
		
		btn.UpdateStyle = UpdateStyle
		
		E.CreateAuraButtonArtwork(btn, filter)
    end
end


local formatTimeRemaining
do
	
	local hour, minute = 3600, 60
	local format = string.format
    local ceil = math.ceil
	local floor = math.floor
	local fmod = math.fmod
	
    formatTimeRemaining = function(msecs)
        if not config.showDurationTimers then return "" end
		if msecs < 0 then msecs = 0 end
		
		if E.db.buffframe.config.timeformat == 2 then
			if msecs >= hour then
				return format("%dч", ceil(msecs / hour))
			else
				return ("%d:%0.2d"):format(msecs/60, fmod(msecs, 60))
			end
		else
			if msecs >= hour then
				return format("%dч", ceil(msecs / hour))
			elseif msecs >= minute then
				return format("%dм", ceil(msecs / minute))
			else
				return format("%dс", floor(msecs))
			end
		end
    end
end

local function updateBlink(btn)
    if btn.cAlpha >= 1 then btn.increasing = false elseif btn.cAlpha <= 0.3 then btn.increasing = true end
    btn.cAlpha = btn.cAlpha + (btn.increasing and config.blinkStep or -config.blinkStep)
    btn:SetAlpha(btn.cAlpha)
end

local UpdateAuraButtonCD
do
    local name, duration, eTime, msecs

    UpdateAuraButtonCD = function(btn, elapsed)
        if btn.lastUpdate < btn.freq then btn.lastUpdate = btn.lastUpdate + elapsed; return end
        btn.lastUpdate = 0

        name, _, _, _, duration, eTime = UnitAura("player", btn:GetID(), btn.filter)
        if name and duration > 0 then 
            msecs = eTime - GetTime()
            btn.text:SetText(E.FormatTime(E.db.buffframe.config.timeformat, msecs))

            btn.rTime = msecs
            if btn.rTime < btn.bTime then btn.freq = .05 end
            if btn.rTime <= config.blinkTime then updateBlink(btn) end
        end
    end
end

local UpdateWeaponEnchantButtonCD
do
    local r1, r2, rTime

    UpdateWeaponEnchantButtonCD = function(btn, elapsed)
        if btn.lastUpdate < btn.freq then btn.lastUpdate = btn.lastUpdate + elapsed; return end
        btn.lastUpdate = 0

        _, r1, _, _, r2 = GetWeaponEnchantInfo()
        rTime = (btn.slotID == 16) and r1 or r2

        btn.rTime = rTime / 1000
        btn.text:SetText(formatTimeRemaining(btn.rTime))

        if btn.rTime < btn.bTime then btn.freq = .05 end
        if btn.rTime <= config.blinkTime then updateBlink(btn) end
    end
end

local updateAuraButtonStyle
do
    local name, icon, count, dType, duration, eTime, cond
	--local n = E.db.buffframe.config
	--n.border.color[1],n.border.color[2],n.border.color[3],n.border.color[4]
    updateAuraButtonStyle = function(btn, filter)
        if not btn.created then createAuraButton(btn, filter) end
		local n = E.db.buffframe.config
		
        name, icon, count, dType, duration, eTime = UnitAura("player", btn:GetID(), filter)
        if name then
            btn.icon.tex:SetTexture(icon)
			
            cond = (filter == "HARMFUL") and config.coloredBorder
		
			local r, g, b, a = n.border.color[1],n.border.color[2],n.border.color[3],n.border.color[4]

			if dType and cond then 
				r, g, b = DEFAULT_AURA_COLOR[dType].r, DEFAULT_AURA_COLOR[dType].g, DEFAULT_AURA_COLOR[dType].b
			elseif cond then
				r, g, b = 0.8, 0, 0
			end
		
            btn.icon.artBorder:SetBackdropBorderColor(r, g, b, a)

            if duration > 0 then 
                btn:SetAlpha(1)
                btn.rTime = eTime - GetTime()
                btn.bTime = config.blinkTime + 1.1
                btn.freq = 1
                btn:SetScript("OnUpdate", UpdateAuraButtonCD)
                UpdateAuraButtonCD(btn, 5)
            else
                btn.text:SetText("")
                btn:SetAlpha(1)
                btn:SetScript("OnUpdate", nil)
            end
            btn.stacks:SetText((count > 1) and count or "")
        else
            btn.text:SetText("")
            btn.stacks:SetText("")
            btn:SetScript("OnUpdate", nil)
        end
    end
end

local updateWeaponEnchantButtonStyle
do
    local icon, r, g, b, c

    updateWeaponEnchantButtonStyle = function(btn, slot, hasEnchant, rTime)
        if not btn.created then createAuraButton(btn) end
		
	--	print('T', 'updateWeaponEnchantButtonStyle', slot, hasEnchant, rTime)
		
    --    if hasEnchant then
            btn.slotID = GetInventorySlotInfo(slot)
            icon = GetInventoryItemTexture("player", btn.slotID)
            btn.icon.tex:SetTexture(icon)
			
            r, g, b = grey, grey, grey
            c = GetInventoryItemQuality("player", slotid)
            if config.coloredBorder then r, g, b = GetItemQualityColor(c or 1) end

			btn.icon.artBorder:SetBackdropBorderColor(r, g, b, 1)
			
            btn.rTime = 0 / 1000
            btn.bTime = config.blinkTime + 1.1
            btn.freq = 1

            btn.duration = 1800
            btn:SetAlpha(1)

            btn:SetScript("OnUpdate", UpdateWeaponEnchantButtonCD)
            UpdateWeaponEnchantButtonCD(btn, 5)
    --   else
    --        btn.text:SetText("")
    --        btn:SetScript("OnUpdate", nil)
   --     end
    end
end

local updateStyle
do
    local hasMHe, MHrTime, hasOHe, OHrTime, wEnch1, wEnch2

    updateStyle = function(header, event, unit)
        if unit ~= "player" and unit ~= "vehicle" and event ~= "PLAYER_ENTERING_WORLD" then return end

        for _,btn in header:ActiveButtons() do 
			updateAuraButtonStyle(btn, header.filter) 			
		end
		
        if header.filter == "HELPFUL" then
            hasMHe, MHrTime, _, _, hasOHe, OHrTime = GetWeaponEnchantInfo()

            wEnch1 = buffHeader:GetAttribute("tempEnchant1")
         --   wEnch2 = buffHeader:GetAttribute("tempEnchant2")
		--	print('T0', hasMHe, MHrTime, wEnch1)
			
            if wEnch1 then updateWeaponEnchantButtonStyle(wEnch1, "MainHandSlot", hasMHe, MHrTime) end
         --   if wEnch2 then updateWeaponEnchantButtonStyle(wEnch2, "SecondaryHandSlot", hasOHe, OHrTime) end
        end
    end
end

local function setHeaderAttributes(header, template, isBuff, init)
    local n = E.db.buffframe.config

    header:SetAttribute("unit", "player")
    header:SetAttribute("filter", isBuff and "HELPFUL" or "HARMFUL")
    header:SetAttribute("template", template)
    header:SetAttribute("separateOwn", 0)
    header:SetAttribute("minWidth", 100)
    header:SetAttribute("minHeight", 100)
	
    header:SetAttribute("point", isBuff and n.buffAnchor[1] or n.debuffAnchor[1])
    header:SetAttribute("xOffset", isBuff and n.buffXoffset or n.debuffXoffset)
    header:SetAttribute("yOffset", isBuff and n.buffYoffset or n.debuffYoffset)
    header:SetAttribute("wrapAfter", isBuff and n.buffIconsPerRow or n.debuffIconsPerRow)
    header:SetAttribute("wrapXOffset", isBuff and n.buffWrapXoffset or n.debuffWrapXoffset)
    header:SetAttribute("wrapYOffset", isBuff and n.buffWrapYoffset or n.debuffWrapYoffset)
    header:SetAttribute("maxWraps", isBuff and n.buffMaxWraps or n.debuffMaxWraps)

    header:SetAttribute("sortMethod", n.sortMethod)
    header:SetAttribute("sortDirection", n.sortReverse and "-" or "+")

    if isBuff and n.showWeaponEnch then
        header:SetAttribute("includeWeapons", 1)
        header:SetAttribute("weaponTemplate", "AleaUIBuffButtonTemplate")
    end

    header:SetScale(isBuff and n.buffScale or n.debuffScale)
    header.filter = isBuff and "HELPFUL" or "HARMFUL"

    header:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	if init then
		header:HookScript("OnEvent", updateStyle)
	end
end

local function LoadBuffFrame()
	config.blinkStep = config.blinkSpeed / 12

    -- hide blizz auras
    BuffFrame:Kill()
	TemporaryEnchantFrame:Kill()
	
	if not E.db.buffframe then
		E.db.buffframe = {}
		E.db.buffframe.config = config
	end

	E.GUI.args.buffframe = {		
		name = L['Buffs and debuffs'],
		order = 3,
		expand = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.buffframe.args.BorderOpts = {
		name = L['Borders'],
		order = 10,
		embend = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.buffframe.args.BorderOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L['Border texture'],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.buffframe.config.border.texture = value;
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(info) return E.db.buffframe.config.border.texture end,
	}

	E.GUI.args.buffframe.args.BorderOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.buffframe.config.border.color={ r, g, b, a}; 
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(info) 
			return E.db.buffframe.config.border.color[1],
					E.db.buffframe.config.border.color[2],
					E.db.buffframe.config.border.color[3],
					E.db.buffframe.config.border.color[4] 
		end,
	}

	E.GUI.args.buffframe.args.BorderOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.buffframe.config.border.size = val
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get =function(info)
			return E.db.buffframe.config.border.size
		end,
	}

	E.GUI.args.buffframe.args.BorderOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.buffframe.config.border.inset = val
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get =function(info)
			return E.db.buffframe.config.border.inset
		end,
	}


	E.GUI.args.buffframe.args.BorderOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Background texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.buffframe.config.border.background_texture = value;
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(info) return E.db.buffframe.config.border.background_texture end,
	}

	E.GUI.args.buffframe.args.BorderOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.buffframe.config.border.background_color={ r, g, b, a}
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(info) 
			return E.db.buffframe.config.border.background_color[1],
					E.db.buffframe.config.border.background_color[2],
					E.db.buffframe.config.border.background_color[3],
					E.db.buffframe.config.border.background_color[4] 
		end,
	}


	E.GUI.args.buffframe.args.BorderOpts.args.backgroundInset = {
		name = L['Background inset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.buffframe.config.border.background_inset = val
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get =function(info)
			return E.db.buffframe.config.border.background_inset
		end,
	}
	
	E.GUI.args.buffframe.args.timeText = {
		name = L['Time text'],
		order = 1,
		embend = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.buffframe.args.timeText.args.timeFormat = {
		name = L['Format'],
		order = 0.1,
		type = "dropdown",
		values = E.TimeFormatListBuffs,
		set = function(self, value)
			E.db.buffframe.config.timeformat = value
		end,
		get = function(self)
			return E.db.buffframe.config.timeformat
		end,
	}
	
	E.GUI.args.buffframe.args.timeText.args.Xoffset = {
		name = L['Horizontal offset'],
		order = 1,
		type = "slider",
		min = -50, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.durationXoffset = value		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.durationXoffset
		end,
	}
	E.GUI.args.buffframe.args.timeText.args.Yoffse = {
		name = L['Vertical offset'],
		order = 1,
		type = "slider",
		min = -50, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.durationYoffset = value		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.durationYoffset
		end,
	}
	
	E.GUI.args.buffframe.args.timeText.args.font = {
		name = L['Font'],
		order = 1,
		type = "font",
		values = E.GetFontList,
		set = function(self, value)
			E.db.buffframe.config.durationFont = value		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.durationFont
		end,
	}
	
	E.GUI.args.buffframe.args.timeText.args.color = {
		name = L['Color'],
		order = 1,
		type = "color",
		set = function(self, r,g,b)
			E.db.buffframe.config.durationFontColor = { r, g, b, 1 }		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.durationFontColor[1], E.db.buffframe.config.durationFontColor[2], E.db.buffframe.config.durationFontColor[3], 1
		end,
	}
	
	E.GUI.args.buffframe.args.timeText.args.fontStyle = {
		name = L['Outline'],
		order = 1,
		type = "dropdown",
		values = {			
			[""] = NO,
			["OUTLINE"] = "OUTLINE",
		},
		set = function(self, value)
			E.db.buffframe.config.durationFontStyle = value	
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.durationFontStyle
		end,
	}
	
	E.GUI.args.buffframe.args.timeText.args.size = {
		name = L['Size'],
		order = 1,
		type = "slider",
		min = 1, max = 32, step = 1,
		set = function(self, value)
			E.db.buffframe.config.durationFontSize = value		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.durationFontSize
		end,
	}
	E.GUI.args.buffframe.args.stackText = {
		name = L['Stack text'],
		order = 2,
		embend = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.buffframe.args.stackText.args.Xoffset = {
		name = L['Horizontal offset'],
		order = 1,
		type = "slider",
		min = -50, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.stacksXoffset = value		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.stacksXoffset
		end,
	}
	E.GUI.args.buffframe.args.stackText.args.Yoffse = {
		name = L['Vertical offset'],
		order = 1,
		type = "slider",
		min = -50, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.stacksYoffset = value		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.stacksYoffset
		end,
	}
	
	E.GUI.args.buffframe.args.stackText.args.font = {
		name = L["Font"],
		order = 1,
		type = "font",
		values = E.GetFontList,
		set = function(self, value)
			E.db.buffframe.config.stackFont = value		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.stackFont
		end,
	}
	
	E.GUI.args.buffframe.args.stackText.args.color = {
		name = L["Color"],
		order = 1,
		type = "color",
		set = function(self, r,g,b)
			E.db.buffframe.config.stackFontColor = { r, g, b, 1 }		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.stackFontColor[1], E.db.buffframe.config.stackFontColor[2], E.db.buffframe.config.stackFontColor[3], 1
		end,
	}
	
	E.GUI.args.buffframe.args.stackText.args.fontStyle = {
		name = L['Outline'],
		order = 1,
		type = "dropdown",
		values = {			
			[""] = NO,
			["OUTLINE"] = "OUTLINE",
		},
		set = function(self, value)
			E.db.buffframe.config.stackFontStyle = value	
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.stackFontStyle
		end,
	}
	
	E.GUI.args.buffframe.args.stackText.args.size = {
		name = L["Size"],
		order = 1,
		type = "slider",
		min = 1, max = 32, step = 1,
		set = function(self, value)
			E.db.buffframe.config.stackFontSize = value		
			buffHeader:ButtonInterator("UpdateStyle")
			debuffHeader:ButtonInterator("UpdateStyle")
		end,
		get = function(self)
			return E.db.buffframe.config.stackFontSize
		end,
	}

	E.GUI.args.buffframe.args.buffs = {
		name = L['Buffs'],
		order = 1,
		embend = false,
		type = "group",
		args = {}
	}
	
	E.GUI.args.buffframe.args.buffs.args.Xoffset = {
		name = L['Horizontal icon gap'],
		order = 1,
		type = "slider",
		min = -50, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.buffXoffset = value
			setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true)
		end,
		get = function(self)		
			return E.db.buffframe.config.buffXoffset
		end,	
	}
	
	E.GUI.args.buffframe.args.buffs.args.Yoffset = {
		name = L['Vertical icon gap'],
		order = 1,
		type = "slider",
		min = -50, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.buffYoffset = value
			setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true)
		end,
		get = function(self)		
			return E.db.buffframe.config.buffYoffset
		end,	
	}
	
	E.GUI.args.buffframe.args.buffs.args.IconsPerRow = {
		name = L['Icons per row'],
		order = 1,
		type = "slider",
		min = 1, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.buffIconsPerRow = value
			setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true)
		end,
		get = function(self)		
			return E.db.buffframe.config.buffIconsPerRow
		end,	
	}
	
	E.GUI.args.buffframe.args.buffs.args.MaxWraps = {
		name = L['Rows'],
		order = 1,
		type = "slider",
		min = 1, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.buffMaxWraps = value
			setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true)
		end,
		get = function(self)		
			return E.db.buffframe.config.buffMaxWraps
		end,	
	}
	
	E.GUI.args.buffframe.args.buffs.args.WrapXoffset = {
		name = L['Horizontal row offset'],
		order = 1,
		type = "slider",
		min = -55, max = 55, step = 1,
		set = function(self, value)
			E.db.buffframe.config.buffWrapXoffset = value
			setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true)
		end,
		get = function(self)		
			return E.db.buffframe.config.buffWrapXoffset
		end,	
	}
	
	E.GUI.args.buffframe.args.buffs.args.WrapYoffset = {
		name = L['Vertical row offset'],
		order = 1,
		type = "slider",
		min = -55, max = 55, step = 1,
		set = function(self, value)
			E.db.buffframe.config.buffWrapYoffset = value
			setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true)
		end,
		get = function(self)		
			return E.db.buffframe.config.buffWrapYoffset
		end,	
	}
	
	E.GUI.args.buffframe.args.buffs.args.scale = {
		name = L['Scale'],
		order = 1,
		type = "slider",
		min = 0.1, max = 2, step = 0.1,
		set = function(self, value)
			E.db.buffframe.config.buffScale = value
			setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true)
		end,
		get = function(self)		
			return E.db.buffframe.config.buffScale
		end,	
	}
	
	E.GUI.args.buffframe.args.buffs.args.unlock = {
		name = L['Unlock'],
		order = 1,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("buffframeHeader")
		end,
		get = function(self) end,	
	}
	
	E.GUI.args.buffframe.args.debuffs = {
		name = L['Debuffs'],
		order = 2,
		embend = false,
		type = "group",
		args = {}
	}
	
	E.GUI.args.buffframe.args.debuffs.args.Xoffset = {
		name = L['Horizontal icon gap'],
		order = 1,
		type = "slider",
		min = -50, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.debuffXoffset = value
			setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false)
		end,
		get = function(self)		
			return E.db.buffframe.config.debuffXoffset
		end,	
	}
	
	E.GUI.args.buffframe.args.debuffs.args.Yoffset = {
		name = L['Vertical icon gap'],
		order = 1,
		type = "slider",
		min = -50, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.debuffYoffset = value
			setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false)
		end,
		get = function(self)		
			return E.db.buffframe.config.debuffYoffset
		end,	
	}
	
	E.GUI.args.buffframe.args.debuffs.args.IconsPerRow = {
		name = L['Icons per row'],
		order = 1,
		type = "slider",
		min = 1, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.debuffIconsPerRow = value
			setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false)
		end,
		get = function(self)		
			return E.db.buffframe.config.debuffIconsPerRow
		end,	
	}
	
	E.GUI.args.buffframe.args.debuffs.args.MaxWraps = {
		name = L['Rows'],
		order = 1,
		type = "slider",
		min = 1, max = 50, step = 1,
		set = function(self, value)
			E.db.buffframe.config.debuffMaxWraps = value
			setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false)
		end,
		get = function(self)		
			return E.db.buffframe.config.debuffMaxWraps
		end,	
	}
	
	E.GUI.args.buffframe.args.debuffs.args.WrapXoffset = {
		name = L['Horizontal row offset'],
		order = 1,
		type = "slider",
		min = -55, max = 55, step = 1,
		set = function(self, value)
			E.db.buffframe.config.debuffWrapXoffset = value
			setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false)
		end,
		get = function(self)		
			return E.db.buffframe.config.debuffWrapXoffset
		end,	
	}
	
	E.GUI.args.buffframe.args.debuffs.args.WrapYoffset = {
		name = L['Vertical row offset'],
		order = 1,
		type = "slider",
		min = -55, max = 55, step = 1,
		set = function(self, value)
			E.db.buffframe.config.debuffWrapYoffset = value
			setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false)
		end,
		get = function(self)		
			return E.db.buffframe.config.debuffWrapYoffset
		end,	
	}
	
	E.GUI.args.buffframe.args.debuffs.args.scale = {
		name = L['Scale'],
		order = 1,
		type = "slider",
		min = 0.1, max = 2, step = 0.1,
		set = function(self, value)
			E.db.buffframe.config.debuffScale = value
			setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false)
		end,
		get = function(self)		
			return E.db.buffframe.config.debuffScale
		end,	
	}
	
	E.GUI.args.buffframe.args.debuffs.args.unlock = {
		name = L['Unlock'],
		order = 1,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("debuffframeHeader")
		end,
		get = function(self) end,	
	}
	
	
    -- init headers
    setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true, true)
    buffHeader:Show()
	
	E:Mover(buffHeaderMover, "buffframeHeader", 30, 30, "TOPRIGHT")
	
    setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false, true)
    debuffHeader:Show()
	
	E:Mover(debuffHeaderMover, "debuffframeHeader", 30, 30, "TOPRIGHT")
	
	buffHeader:ButtonInterator("UpdateStyle")
	debuffHeader:ButtonInterator("UpdateStyle")
	
	E.OnLSMUpdateRegister(function()
		buffHeader:ButtonInterator("UpdateStyle")
		debuffHeader:ButtonInterator("UpdateStyle")
	end)	
end

function E:UpdateBuffFrameSettings()
	
	setHeaderAttributes(debuffHeader, "AleaUIDebuffButtonTemplate", false)
	setHeaderAttributes(buffHeader, "AleaUIBuffButtonTemplate", true)
	
	buffHeader:ButtonInterator("UpdateStyle")
	debuffHeader:ButtonInterator("UpdateStyle")
	
end

E:OnInit2(LoadBuffFrame)