local E = AleaUI
local L = E.L
local CB = E:Module("CastBar")
local UF = E:Module("UnitFrames")
local w, h

local pingWorkAround = true

local UnitChannelInfo = UnitChannelInfo
local UnitCastingInfo = UnitCastingInfo

if ( E.isClassic ) then 
	UnitChannelInfo = function(unit) 
		if UnitIsUnit(unit, 'player') then 
			return ChannelInfo()
		end
	end

	UnitCastingInfo = function(unit) 
		if UnitIsUnit(unit, 'player') then 
			return CastingInfo()
		end
	end
end 

CB.rightTextPattern_channel = " %s | %s + %.1f "
CB.rightTextPattern_cast = " %s | %s "
CB.rightTextPatternMS_channel = " |cFFFF0000ms:%d|r %s | %s + %.1f "
CB.rightTextPatternMS_cast = " |cFFFF0000ms:%d|r %s | %s "

local deafult_texture = "Interface\\AddOns\\AleaUI\\media\\Minimalist.tga"

local events = {
	"UNIT_SPELLCAST_CHANNEL_START",
	"UNIT_SPELLCAST_CHANNEL_STOP",
	"UNIT_SPELLCAST_CHANNEL_UPDATE",
	
	--"UNIT_SPELLCAST_SENT",
	"UNIT_SPELLCAST_START",
	"UNIT_SPELLCAST_DELAYED",
	--"UNIT_SPELLCAST_FAILED",
	
	-- FAILED
	"UNIT_SPELLCAST_INTERRUPTED",
	"UNIT_SPELLCAST_STOP",
--	"UNIT_SPELLCAST_SUCCEEDED",
	
	"UNIT_SPELLCAST_INTERRUPTIBLE",
	"UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
}	

local colors = {
	["notinterruptible"] = {.6, .2, .2, 1},
	["interruptible"] = {0.2,0.2,0.2,1},
	
	["ping"] = { 1, 1, 1, 0.5 },
	["ticks"] = {150/255, 225/255, 239/255, 1},
	["insanity"] = { 0,83/255,100/255,1},
	
	['background'] = { 0.3,0.3,0.3,1 },
}

CB.colors = colors

local spelldb = {
	[15407]  = { ticks = 4, amount = 4, every = 3/4, haste = true },
	[48045]  = { ticks = 5, amount = 5, every = 1, haste = true }, -- Mind Sear Normal
--	[179338]  = { ticks = 5, amount = 5, every = 1, haste = true }, -- Mind Sear Normal
	
	
	[129197] = { ticks = 4, amount = 4, every = 1, haste = true },	
	[103103] = { ticks = 4, amount = 4, every = 1, haste = true },
	
	[47540] = { ticks = 1, amount = 1, every = 1, haste = true },
	[64843] = { ticks = 4, amount = 4, every = 1, haste = true },
	
	[205065] = { ticks = 4, amount = 4, every = 1, haste = true },

}

local channeling_info = {}

local function Round(num) return math.floor(num+.5) end --.5

local function getbarpos(bar, tik)
	local minValue, maxValue = bar:GetMinMaxValues()
	if tik >= 0 then
		return tik / maxValue * bar:GetWidth()
	else
		return (maxValue+tik) / maxValue * bar:GetWidth()
	end
end

local bordersize = 1

local function SameUnit(u1,u2)
	if u1 and u2 and UnitIsUnit(u1, u2) then
		return false
	end
	return true
end

local SetPing = function(self, value)

	if not value then 
		self:Hide()
		return 
	end
	
	if value >= 0.25 then
		value = 0.25
	end

	local minv, maxv = self.parent:GetMinMaxValues()
	local width, height = self.parent:GetWidth(), self.parent:GetHeight()
	local mywidth = width/maxv*value

	self:SetSize(mywidth, height)
	
	if self.pos then
	
		local freeSize = width-self.pos
		
	--	print('isCast=',self.isCast, 'pos=',self.pos, 'width=',width, 'freeSize=',freeSize)
		
		if freeSize < mywidth then
			self:SetSize(freeSize, height)
		end
	end
	
	self:Show()
end

local function DrawLatency(f, name)	
	if f.parent.unit ~= "player" then return end
--	print('T', name)
	if channeling_info[name] then
		for i=1, #f.tiks do
			if f.tiks[i]:IsShown() then
				f.tiks[i].latensy:SetPing(f.ping)
			else
				f.tiks[i].latensy:Hide()
			end
		end
		f.channelLatency:SetPing(f.ping)
		f.castLatency:Hide()
	else
		for i=1, #f.tiks do		
			f.tiks[i].latensy:Hide()
		end		
		f.channelLatency:Hide()
		f.castLatency:SetPing(f.ping)
	end
end

local function CreateTicks(f)
	local h = f:GetHeight()
	
	local tick = f.ticksparent:CreateTexture(nil, "ARTWORK")
	tick:SetAlpha(1)
	tick:SetWidth(1)
	tick:SetHeight(h)

	tick:SetColorTexture(f.opts.colors.ticks[1],f.opts.colors.ticks[2],f.opts.colors.ticks[3],f.opts.colors.ticks[4])
	
	local lat3 = f.ticksparent:CreateTexture(nil, "ARTWORK")
	lat3.parent = f
	lat3:SetHeight(h)
	lat3:SetPoint("LEFT", tick, "RIGHT")
	lat3.SetPing = SetPing
	lat3:SetColorTexture(f.opts.colors.ping[1],f.opts.colors.ping[2],f.opts.colors.ping[3],f.opts.colors.ping[4])

	tick.latensy = lat3
	
	return tick
end
local function DrawTicks(f, name)	

	for i=1, #f.tiks do
		f.tiks[i]:Hide()
	end

	if f.parent.unit ~= "player" then return end
	
	if channeling_info[name] then
	
	--	print(f.parent.unit)
		
		local haste = f.haste or UnitSpellHaste("player")
		local tick_every, amount_to_show
		local tick = channeling_info[name].every
		local duration = f.duration
		
		if channeling_info[name].haste then
			tick_every	= tick/(1+(haste/100))
		else
			tick_every	= tick
		end
		
		amount_to_show = Round(duration/tick_every)-1
			
		if f.duration2 > 0 then			
			amount_to_show = amount_to_show + 1
		end
		
	--	print("T2", format("%.2f", amount_to_show), format("%.2f", f.duration2), format("%.2f", f.duration), format("%.2f", duration), format("%.2f", tick_every), haste)

		
		for i=1, amount_to_show do
			w,h = f:GetWidth(), f:GetHeight()
			
			f.tiks[i] = f.tiks[i] or CreateTicks(f)
			local tick_position = floor(getbarpos(f, tick_every*i))
			
			if tick_position < w then
				if false then
					f.tiks[i]:SetPoint("LEFT",f,"LEFT", -(tick_position)+w, 0)		
					f.tiks[i].pos = -(tick_position)+w
					f.tiks[i].latensy.pos = -(tick_position)+w
				else
					f.tiks[i]:SetPoint("LEFT",f,"LEFT", (tick_position), 0)
					f.tiks[i].pos = tick_position
					f.tiks[i].latensy.pos = tick_position
				end
				
				f.tiks[i]:Show()
			end
		end
	end
end

local function CastBarOnUpdate(f, elapsed)
	local curtime = GetTime()
	if curtime > f.endTime then
		f:Hide()
		return  
	end
	
	f.value = f.value + elapsed
	local curdur
	
	if f.nap == 1 then -- cast
		curdur = curtime - f.startTime
	else -- channel
		curdur = f.endTime - curtime
	end
	local difTime = f.duration2-f.duration
	
	local i = 0	

	for k,v in pairs(f.tiks) do
		if v:IsShown() then
			i = i + 1
		end
	end

	if not f.showTextLatency and f.unit == "player" then --f.opts.ping
		if difTime > 0 then
			f.rightText:SetFormattedText(CB.rightTextPatternMS_channel, f.ping*1000, E.FormatTime(5, curdur), E.FormatTime(5, f.duration), difTime)
		else
			f.rightText:SetFormattedText(CB.rightTextPatternMS_cast, f.ping*1000, E.FormatTime(5, curdur), E.FormatTime(5, f.duration))
		end
	else
		if difTime > 0 then
			f.rightText:SetFormattedText(CB.rightTextPattern_channel, E.FormatTime(5, curdur), E.FormatTime(5, f.duration), difTime)
		else
			f.rightText:SetFormattedText(CB.rightTextPattern_cast, E.FormatTime(5, curdur), E.FormatTime(5, f.duration))
		end
	end
	
	if f.showTextLatency then
		if f.nap == 1 then
			f.channelLatency.text:Hide()
			f.castLatency.text:Show()
		else
			f.channelLatency.text:Show()
			f.castLatency.text:Hide()
		end
	
		f.castLatency.text:SetFormattedText('ms%d', f.ping*1000)
		f.channelLatency.text:SetFormattedText('ms%d', f.ping*1000)
	else
		f.castLatency.text:SetText('')
		f.channelLatency.text:SetText('')
	end
	
	f:SetValue(curdur)
end

-- name, subText, text, texture, startTime / 1000, endTime / 1000, isTradeSkill, notInterruptible = UnitChannelInfo("unit")
-- name, subText, text, texture, startTime / 1000, endTime / 1000, isTradeSkill, castID, notInterruptible = UnitCastingInfo("unit")

local function CustomCastBar(f, unit, name, texture, startTime, endTime, notInterruptible, reverted)
	if not startTime or not endTime then 
		f:Hide()
		return 
	end
	
	f.startTime		= startTime
	f.endTime		= endTime
	f.duration		= f.endTime - f.startTime
	f.duration2		= 0
	f.nap			= reverted and -1 or 1

	f.value			= 0
	
	if pingWorkAround then
		local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
		f.ping		= f.castTime_Start and latencyWorld*0.001 or 0
	else
		f.ping		= f.castTime_Start and ( f.startTime - f.castTime_Start ) or 0
	end

	if false and f.curTarget then -- f.opts.target_name
		f.leftText:SetText(name.." -> "..f.curTarget)
	else		
		f.leftText:SetText(name)
	end
	
	--print("OnCast")
	
	f.icon:SetTexture(texture)
	f:SetMinMaxValues(0, f.duration)
	f:DrawTicks(name)
	f:UpdateIntrerruptState(notInterruptible, name)
	f:DrawLatency(name)

	f:Show()
end

local function OnCast(f, unit)
	
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)	
	if name then
		f:ShowGCD(name)	
	end
	
	if not startTime or not endTime then 
		f:Hide()
		return 
	end
	
	f.customBar 	= false
	f.startTime		= startTime*0.001
	f.endTime		= endTime*0.001
	f.duration		= f.endTime - f.startTime
	f.duration2		= 0
	f.nap			= 1

	f.value			= 0
	
	if pingWorkAround then
		local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
		f.ping			= f.castTime_Start and latencyWorld*0.001 or 0
	else
		f.ping			= f.castTime_Start and ( f.startTime - f.castTime_Start ) or 0
	end

	if false and f.curTarget then -- f.opts.target_name
		f.leftText:SetText(name.." -> "..f.curTarget)
	else		
		f.leftText:SetText(name)
	end
	
	--print("OnCast")
	
	f.icon:SetTexture(texture)
	f:SetMinMaxValues(0, f.duration)
	f:DrawTicks(name)
	f:UpdateIntrerruptState(notInterruptible, name)
	f:DrawLatency(name)

	f:Show()
end

local function OnCastUpdate(f, unit)
	
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
	if not startTime or not endTime then 
		f:Hide()
		return 
	end
	
	f.customBar 	= false
	
	f.startTime		= startTime/1000
	f.endTime		= endTime/1000
	f.nap			= 1
	
	f.duration2		= f.endTime - f.startTime
	
	--print("OnCastUpdate")
	
	f.icon:SetTexture(texture)
	if false and f.curTarget then -- f.opts.target_name
		f.leftText:SetText(name.." -> "..f.curTarget)
	else
		f.leftText:SetText(name)
	end
	f:DrawTicks(name)
	f:SetMinMaxValues(0, f.duration2)
	f:UpdateIntrerruptState(notInterruptible, name)
	f:DrawLatency(name)

	f:Show()
end

local function OnChannel(f, unit)
	
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
	if not startTime or not endTime then 
		f:Hide()
		return 
	end
	
--	print("OnChannel")
	
	f.customBar 	= false
	
	f.startTime		= startTime*0.001
	f.endTime		= endTime*0.001
	f.duration		= f.endTime - f.startTime
	f.duration2		= 0
	f.nap			= -1
	f.haste			= UnitSpellHaste("player")

	f.value			= 0
	
	if pingWorkAround then
		local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
		f.ping			= f.castTime_Start and latencyWorld*0.001 or 0
	else
		f.ping			= f.castTime_Start and ( f.startTime - f.castTime_Start ) or 0
	end
	
	
	f.icon:SetTexture(texture)
	if false and f.curTarget then -- f.opts.target_name
		f.leftText:SetText(name.." -> "..f.curTarget)
	else
		f.leftText:SetText(name)
	end
	f:SetMinMaxValues(0, f.duration)
	f:DrawTicks(name)
	f:UpdateIntrerruptState(notInterruptible, name)
	f:DrawLatency(name)

	
	f:Show()
end

local function OnChannelUpdate(f, unit)
	
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
	if not startTime or not endTime then 
		f:Hide()
		return 
	end
	
--	print("OnChannelUpdate", f.endTime, endTime/1000, (endTime/1000)-f.endTime, f.parent.unit)
	
	f.customBar 	= false
	
	f.startTime		= startTime*0.001
	f.endTime		= endTime*0.001
	
	f.duration2 	= f.endTime - f.startTime --f.duration + abs((endTime/1000)-f.endTime) f.duration + abs((endTime/1000)-f.endTime)
	
	f.nap			= -1
	
	f.icon:SetTexture(texture)
	f.leftText:SetText(name)
	f:SetMinMaxValues(0, f.duration2)
	f:UpdateIntrerruptState(notInterruptible, name)

	f:DrawTicks(name)
	f:DrawLatency(name)

	f:Show()
end

local test_bar = false
local function TestCastBar(f)
	
	if not test_bar then
		f.customBar 	= false
		
		f.value			= GetTime()
		f.startTime		= GetTime()-90
		f.endTime		= GetTime()+90
		f.duration		= f.endTime - f.startTime
		f.duration2		= 0
		f.nap			= 1

		if pingWorkAround then
			local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
			f.ping			= f.castTime_Start and latencyWorld*0.001 or 0
		else
			f.ping			= f.castTime_Start and ( f.startTime - f.castTime_Start ) or 0
		end

		f.icon:SetTexture("Interface\\Icons\\spell_shadow_shadowwordpain")
		f.leftText:SetText("TestCastBar more more word for test")
		f:SetMinMaxValues(0, f.duration)
		f:DrawTicks(name)
		f:UpdateIntrerruptState(true)
		f:DrawLatency(name)

		f:Show()
	else
		f:Hide()
	end
end

local function Disable(f)
	f:Hide()
	f:UnregisterAllEvents()
	f.parent:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

local function Enable(f)

	for i, event in ipairs(events) do
		pcall(f.RegisterEvent, f, event)
	end
	
	if f.unit == "player" then		
		f:RegisterEvent("UNIT_SPELLCAST_SENT")
		f.parent:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
	
	if f.unit == "target" or f.unit == "targettarget" then
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
	end
	
	if string.match(f.unit, "(boss)%d")  then
		f:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	end
	
	if string.match(f.unit, "(arena)%d") then
		f:RegisterEvent("ARENA_OPPONENT_UPDATE")
	end
	
	if f.unit == "focus" then
		f:RegisterEvent("PLAYER_FOCUS_CHANGED")
	end
end

local function UpdateSettings(frame, opts, mover)
	local w, h = opts.width, opts.height
	
	if mover then
		frame.mover:ClearAllPoints()
		frame.mover:SetPoint(opts.point, frame.parent, opts.point, opts.pos[1], opts.pos[2])
	end
	
	frame.opts = opts
	frame.mover:SetSize(w,h)
	frame.castLatency:SetHeight(h)
	frame.channelLatency:SetHeight(h)
	frame:SetStatusBarColor(unpack(opts.colors["interruptible"]))
	
	frame.bg:SetColorTexture(unpack(opts.colors["background"]))
	
	frame.castLatency:SetStatusBarColor(unpack(opts.colors.ping))
--	frame.castLatency.text:SetFont(E:GetFont(opts.font), opts.fontSize-1, opts.fontOutline)
	frame.channelLatency:SetStatusBarColor(unpack(opts.colors.ping))
--	frame.channelLatency.text:SetFont(E:GetFont(opts.font), opts.fontSize-1, opts.fontOutline)
	
	frame.leftText:SetFont(E:GetFont(opts.font), opts.fontSize, opts.fontOutline)
	frame.rightText:SetFont(E:GetFont(opts.font), opts.fontSize, opts.fontOutline)
	
	frame:SetStatusBarTexture(E:GetTexture(opts.texture))
	
	frame:SetAlpha(opts.alpha)
	frame.mover:SetAlpha(opts.alpha)
	
	frame.gcd:SetPoint("BOTTOMLEFT", frame.mover, "TOPLEFT", 1, opts.gcdoffset)
	frame.gcd:SetPoint("BOTTOMRIGHT", frame.mover, "BOTTOMRIGHT", -1, opts.gcdoffset)
	if opts.gcdoffset and opts.gcdoffset >= 0 then 
		frame.gcd.text:SetPoint('BOTTOMLEFT', frame.gcd, 'TOPLEFT', 0, 0)
	else
		frame.gcd.text:SetPoint('TOPLEFT', frame.gcd, 'BOTTOMLEFT', 0, 0)
	end
	
	frame.artBorder:SetBackdrop({
	  edgeFile = AleaUI:GetBorder(opts.border.texture),
	  edgeSize = opts.border.size, 
	})
	frame.artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
	frame.artBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", opts.border.inset, -opts.border.inset)
	frame.artBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

	frame.artBorder.back:SetTexture(AleaUI:GetTexture(opts.border.background_texture))
	frame.artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
	frame.artBorder.back:SetPoint("TOPLEFT", frame, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
	frame.artBorder.back:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
	
	if opts.showIcon then
		frame.icon:SetSize(h-bordersize-bordersize,h-bordersize-bordersize)
		frame.icon:Show()
		frame.icon.artBorder:Show()
		frame.icon.artBorder.back:Show()
		frame:SetSize(w-h-bordersize-bordersize-bordersize, h-bordersize-bordersize)
		
		frame.icon.artBorder:SetBackdrop({
		  edgeFile = AleaUI:GetBorder(opts.border.texture),
		  edgeSize = opts.border.size, 
		})
		frame.icon.artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
		frame.icon.artBorder:SetPoint("TOPLEFT", frame.icon, "TOPLEFT", opts.border.inset, -opts.border.inset)
		frame.icon.artBorder:SetPoint("BOTTOMRIGHT", frame.icon, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

		frame.icon.artBorder.back:SetTexture(AleaUI:GetTexture(opts.border.background_texture))
		frame.icon.artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
		frame.icon.artBorder.back:SetPoint("TOPLEFT", frame.icon, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
		frame.icon.artBorder.back:SetPoint("BOTTOMRIGHT", frame.icon, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
	
	else
		frame.icon:Hide()
		frame.icon.artBorder:Hide()
		frame.icon.artBorder.back:Hide()
		frame:SetSize(w-bordersize-bordersize, h-bordersize-bordersize)		
	end
	
	for i=1, #frame.tiks do		
		local tik = frame.tiks[i]
		tik.latensy:SetColorTexture(opts.colors.ping[1],opts.colors.ping[2],opts.colors.ping[3],opts.colors.ping[4])
		tik.latensy:SetHeight(h)

		tik:SetColorTexture(opts.colors.ticks[1],opts.colors.ticks[2],opts.colors.ticks[3],opts.colors.ticks[4])
		tik:SetHeight(h)
	end
end

function CB.UpdateByLSM()
	for f in pairs(UF.handledFrames['unitframes']) do
		if f.castBar and f.castBar.opts then
			local opts = f.castBar.opts			
			f.castBar:SetStatusBarTexture(E:GetTexture(opts.texture))
		--	f.castBar.castLatency.text:SetFont(E:GetFont(opts.font), opts.fontSize-1, opts.fontOutline)
		--	f.castBar.channelLatency.text:SetFont(E:GetFont(opts.font), opts.fontSize-1, opts.fontOutline)
			f.castBar.leftText:SetFont(E:GetFont(opts.font), opts.fontSize, opts.fontOutline)
			f.castBar.rightText:SetFont(E:GetFont(opts.font), opts.fontSize, opts.fontOutline)
		end
	end	
end

E.OnLSMUpdateRegister(CB.UpdateByLSM)	

function UF:CreateCastBar(frame, w, h, drawticks)
	w, h = w or 200, h or 20
	
	for spellid, db in pairs(spelldb) do
		local id = GetSpellInfo(spellid)
		if id then
			channeling_info[id] = db
		end
	end
	
	local mover = CreateFrame("StatusBar", nil, frame)
	mover:SetSize(w,h)
	mover:SetPoint("TOP", frame, "BOTTOM", 0, -h)
	mover:SetFrameStrata("LOW")
	
	local f = CreateFrame("StatusBar", nil, mover)
	f:SetFrameLevel(mover:GetFrameLevel()+1)
	
	f.opts = {
		enable = true,
		width = w,
		height = h,
		colors = CB.colors,
		texture = AleaUI.media.default_bar_texture_name1,
		font = AleaUI.media.default_font_name,
		fontSize = AleaUI.media.default_font_size,
		fontOultine = 'OUTLINE',
	}
	
	f.parent = frame
	f:SetStatusBarTexture(E:GetTexture(f.opts.texture))
	f:GetStatusBarTexture():SetDrawLayer("ARTWORK")
	f:SetFrameStrata("LOW")
	f:SetStatusBarColor(unpack(f.opts.colors["interruptible"]))
	f:SetPoint("TOPRIGHT", mover, "TOPRIGHT", -bordersize, -bordersize)
	f:SetPoint("BOTTOMRIGHT", mover, "BOTTOMRIGHT", -bordersize, bordersize)
	f:SetSize(w-h-bordersize-bordersize-bordersize, h-bordersize-bordersize)
	f.mover = mover
	f.ticksparent = CreateFrame("Frame", nil, f)
	f.ticksparent:SetFrameLevel(f:GetFrameLevel()+2)
	f.tiks = {}
	
	f:SetScript("OnEvent", function(self, event, ...)
		self[event](self, event, ...)
	end)
	
	f.unit = frame.unit
	
	local lat1 = CreateFrame("StatusBar", nil, f)
	lat1:SetFrameLevel(f:GetFrameLevel()+1)
	lat1.parent = f
	lat1:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	lat1:GetStatusBarTexture():SetDrawLayer("ARTWORK")
	lat1:SetFrameStrata("LOW")
	lat1:SetStatusBarColor(unpack(f.opts.colors.ping))
	lat1:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -0)
	lat1:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
	lat1:SetSize(40, h)
	lat1.SetPing = SetPing
	lat1:Hide()
	
	lat1.text = f.ticksparent:CreateFontString(nil, "ARTWORK", nil, 3)
	lat1.text:SetFont("Fonts\\ARIALN.TTF", f.opts.fontSize-1, f.opts.fontOutline)
	lat1.text:SetJustifyH("LEFT")
	lat1.text:SetJustifyV("BOTTOM")
	lat1.text:SetTextColor(1,0,0)
	lat1.text:SetPoint("BOTTOMLEFT", lat1, "BOTTOMLEFT", 1,1)
	lat1.text:SetSize(40,12)
	lat1.text:SetShadowColor(0,0,0,1)
	lat1.text:SetShadowOffset(1,-1)	
	lat1.pos = 0
	lat1.isCast = false
	
	f.channelLatency = lat1
	
	local lat2 = CreateFrame("StatusBar", nil, f)
	lat2:SetFrameLevel(f:GetFrameLevel()+1)
	lat2.parent = f
	lat2:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	lat2:GetStatusBarTexture():SetDrawLayer("ARTWORK")
	lat2:SetFrameStrata("LOW")
	lat2:SetStatusBarColor(unpack(f.opts.colors.ping))
	lat2:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
	lat2:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
	lat2:SetSize(40, h)
	lat2.isCast = true
	lat2.SetPing = SetPing
	lat2:Hide()

	local gcd = CreateFrame("StatusBar", nil, mover)
--	gcd:SetFrameLevel(f:GetFrameLevel()+3)
	gcd.parent = f
	gcd:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	gcd:SetStatusBarColor(1, 1, 1, 0.5)
	
	gcd:GetStatusBarTexture():SetDrawLayer("ARTWORK")
	gcd:SetPoint("BOTTOMLEFT", mover, "TOPLEFT", 1, 1)
	gcd:SetPoint("BOTTOMRIGHT", mover, "BOTTOMRIGHT", -1, 1)
	gcd:SetSize(2,2)
	gcd:Hide()
	gcd:SetScript("OnUpdate", function(self, elapsed)
		
		local num = GetTime() - self._startTime
		self:SetValue(num)

		if num > self._duration then
			self._startTime = 0
			self._duration = 0
			self:Hide()
		else		
			self.text:SetText(format('%.1f/%.1f', num, self._duration))
		end
	end)
	
	gcd.text = gcd:CreateFontString(nil, "ARTWORK", nil, 3)
	gcd.text:SetFont("Fonts\\ARIALN.TTF", 8, 'NONE')
	gcd.text:SetTextColor(1,1,1)
	gcd.text:SetShadowColor(0,0,0,1)
	gcd.text:SetShadowOffset(1,-1)
	
	f.gcd = gcd
	
	lat2.text = f.ticksparent:CreateFontString(nil, "ARTWORK", nil, 3)
	lat2.text:SetFont("Fonts\\ARIALN.TTF", f.opts.fontSize-1, f.opts.fontOutline)
	lat2.text:SetJustifyH("RIGHT")
	lat2.text:SetJustifyV("BOTTOM")
	lat2.text:SetTextColor(1,0,0)
	lat2.text:SetPoint("BOTTOMRIGHT", lat2, "BOTTOMRIGHT", 1,1)
	lat2.text:SetSize(40,12)
	lat2.text:SetShadowColor(0,0,0,1)
	lat2.text:SetShadowOffset(1,-1)
	
	f.castLatency = lat2
	
	f.artBorder = CreateFrame("Frame", nil, f)
	f.artBorder:SetFrameStrata("LOW")
	f.artBorder:SetBackdrop({
	  edgeFile = [[Interface\Buttons\WHITE8x8]],
	  edgeSize = 1, 
	})
	f.artBorder:SetBackdropBorderColor(0,0,0,1)
	f.artBorder:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -0)
	f.artBorder:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -0, 0)

	f.artBorder.back = f:CreateTexture()
	f.artBorder.back:SetDrawLayer('BACKGROUND', -2)
	f.artBorder.back:SetColorTexture(0, 0, 0, 0)
	f.artBorder.back:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	f.artBorder.back:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
	
	local bg = f:CreateTexture()
	bg:SetDrawLayer('BACKGROUND', 1)
	bg:SetTexture([[Interface\Buttons\WHITE8x8]])
	bg:SetAllPoints(f)
	bg:SetColorTexture(unpack(f.opts.colors['background']))
	
	f.bg = bg
	
	--[==[
	f.border = CreateFrame("Frame", nil, f)
	
	f.border:SetBackdrop({
		edgeFile = [[Interface\Buttons\WHITE8x8]], 
		edgeSize = bordersize, 
	})
	f.border:SetBackdropBorderColor(0,0,0,1)
	f.border:SetPoint("LEFT", -bordersize, 0)		
	f.border:SetPoint("RIGHT", bordersize, 0)
	f.border:SetPoint("TOP", 0, bordersize)		
	f.border:SetPoint("BOTTOM", 0, -bordersize)
	]==]
	
	f.UpdateIntrerruptState = function(self, state, name)
		-- true if notinterruptible
		-- false if interruptible
		if state then
			self:SetStatusBarColor(unpack(f.opts.colors["notinterruptible"]))
		else
			if self.unit == "player" and ( name == GetSpellInfo(129197) or name == GetSpellInfo(179338) ) then
				self:SetStatusBarColor(unpack(f.opts.colors["insanity"]))
			else
				self:SetStatusBarColor(unpack(f.opts.colors["interruptible"]))
			end
		end
	end
	
	
	f.CustomCastBar = CustomCastBar
	f.DrawTicks = DrawTicks
	f.DrawLatency = DrawLatency
	f.OnChannelUpdate = OnChannelUpdate
	f.OnCast = OnCast
	f.OnCastUpdate = OnCastUpdate
	f.OnChannel = OnChannel
	f.CastBarOnUpdate = CastBarOnUpdate
	f.UpdateSettings = UpdateSettings
	f.TestCastBar = TestCastBar
	f.Disable = Disable
	f.Enable = Enable
	f.ShowGCD = function(self, name)
		
		if self.unit ~= "player" then return end
		if not true then return end -- enable gcd

		local start, duration, enabled  = GetSpellCooldown(61304) -- name
	
		if start and start > 0 and duration <= 1.5 then
			self.gcd:SetMinMaxValues(0, duration)
			self.gcd._startTime = start
			self.gcd._duration = duration
			
			self.gcd:Show()
		end
	end
	
	local icon = f:CreateTexture(nil,"ARTWORK")
	icon:SetTexture([[Interface\Buttons\WHITE8x8]])
	icon:SetSize(h-bordersize-bordersize,h-bordersize-bordersize)
	icon:SetPoint("TOPRIGHT", f, "TOPLEFT", -bordersize-bordersize-bordersize, 0)
	icon:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", -bordersize-bordersize-bordersize, 0)
	icon:SetTexCoord(unpack(AleaUI.media.texCoord))
	f.icon = icon
	
	--[==[
	bg = f:CreateTexture(nil,"BACKGROUND")
	bg:SetTexture([[Interface\Buttons\WHITE8x8]])
	bg:SetAllPoints(f.icon)
	bg:SetColorTexture(0,0,0,1)
	
	f.icon.bg = bg	
	]==]
	
	f.icon.artBorder = CreateFrame("Frame", nil, f)
	f.icon.artBorder:SetBackdrop({
	  edgeFile = [[Interface\Buttons\WHITE8x8]],
	  edgeSize = 1, 
	})
	f.icon.artBorder:SetBackdropBorderColor(0,0,0,1)
	f.icon.artBorder:SetPoint("TOPLEFT", f.icon, "TOPLEFT", 0, -0)
	f.icon.artBorder:SetPoint("BOTTOMRIGHT", f.icon, "BOTTOMRIGHT", -0, 0)

	f.icon.artBorder.back = f.icon.artBorder:CreateTexture()
	f.icon.artBorder.back:SetDrawLayer('BACKGROUND', -2)
	f.icon.artBorder.back:SetColorTexture(0, 0, 0, 0)
	f.icon.artBorder.back:SetPoint("TOPLEFT", f.icon, "TOPLEFT", 0, 0)
	f.icon.artBorder.back:SetPoint("BOTTOMRIGHT", f.icon, "BOTTOMRIGHT", 0, 0)
	
	
	--[==[
	f.icon.border = CreateFrame("Frame", nil, f)
	f.icon.border:SetBackdrop({
		edgeFile = [[Interface\Buttons\WHITE8x8]], 
		edgeSize = bordersize, 
	})
	f.icon.border:SetBackdropBorderColor(0,0,0,1)
	f.icon.border:SetPoint("LEFT", f.icon,"LEFT",-bordersize, 0)		
	f.icon.border:SetPoint("RIGHT", f.icon,"RIGHT", bordersize, 0)
	f.icon.border:SetPoint("TOP", f.icon,"TOP",0, bordersize)		
	f.icon.border:SetPoint("BOTTOM", f.icon,"BOTTOM",0, -bordersize)
	]==]
	
	for i, event in ipairs(events) do
		pcall(f.RegisterEvent, f, event)
	end

	local rightText = f.ticksparent:CreateFontString(nil, "ARTWORK", nil, 4);
	rightText.parent = f
	rightText:SetPoint("RIGHT", f, "RIGHT")
	rightText:SetFont("Fonts\\ARIALN.TTF", f.opts.fontSize, f.opts.fontOutline)
	rightText:SetWordWrap(false)
	rightText:SetJustifyH("CENTER")
	rightText:SetShadowColor(0,0,0,1)
	rightText:SetShadowOffset(1,-1)
	
	local leftText = f.ticksparent:CreateFontString(nil, "ARTWORK", nil, 4);
	leftText.parent = f
	leftText:SetPoint("LEFT", f, "LEFT")
	leftText:SetPoint("RIGHT", rightText, "LEFT")
	leftText:SetFont("Fonts\\ARIALN.TTF", f.opts.fontSize, f.opts.fontOutline)
	leftText:SetWordWrap(false)
	leftText:SetJustifyH("LEFT")
	leftText:SetShadowColor(0,0,0,1)
	leftText:SetShadowOffset(1,-1)
	
	f.leftText = leftText
	f.rightText = rightText
	
	
	f:Hide()
	
	frame.castBar = f
	
	f:SetScript("OnUpdate", f.CastBarOnUpdate)

	
	function f:UNIT_SPELLCAST_CHANNEL_START(event, unit)
		--if SameUnit(self.unit, unit) then return end
		if ( self.parent.displayerUnit or self.parent.unit ) ~= unit then return end
		self:OnChannel(unit)	
	end
	
	if f.unit == "player" then		
		f:RegisterEvent("UNIT_SPELLCAST_SENT")
		
		function f:UNIT_SPELLCAST_SENT(event, unit, spell, rank, target)	

			if ( self.parent.displayerUnit or self.parent.unit ) ~= unit then return end
			
			self.curTarget = (target and target ~= "") and target or nil
			self.castTime_Start = GetTime()
		end
		
		frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		function frame:UNIT_SPELLCAST_SUCCEEDED(event, unitID, spell, rank, lineID, spellID)	
			if unitID == 'player' then		
				if spell then
					f:ShowGCD(spell)	
				end
			end
		end
		--[==[		
		f:RegisterEvent('UNIT_AURA')
		function f:UNIT_AURA(event, unitID)	
			if unitID == 'player' then		
				
				local name, _, icon, _, _, duration, expires = UnitBuff('player', (GetSpellInfo(225141)))
				if name then
					self.customBar = true
					self:CustomCastBar(unitID, name, icon, expires-duration, expires, true, true)
				elseif self.customBar then
					self.customBar = false
					self:Hide()
				end
			end
		end
		]==]
		
	end
	
	if f.unit == "target" or f.unit == "targettarget" then
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
		function f:PLAYER_TARGET_CHANGED()
			if not UnitExists(( self.parent.displayerUnit or self.parent.unit )) then 
				self:Hide()
				return
			end
			self:CastBarUpdate()
		end
	end
	
	if string.match(f.unit, "(boss)%d")  then
		f:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		function f:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
			if not UnitExists(( self.parent.displayerUnit or self.parent.unit )) then return end
			self:CastBarUpdate()
		end
	end
	
	if string.match(f.unit, "(arena)%d") then
		f:RegisterEvent("ARENA_OPPONENT_UPDATE")
		function f:ARENA_OPPONENT_UPDATE()
			if not UnitExists(( self.parent.displayerUnit or self.parent.unit )) then 
				self:Hide()
				return 
			end
			self:CastBarUpdate()
		end
	end
	
	if f.unit == "focus" then
		f:RegisterEvent("PLAYER_FOCUS_CHANGED")
		function f:PLAYER_FOCUS_CHANGED()
			if not UnitExists(( self.parent.displayerUnit or self.parent.unit )) then return end
			self:CastBarUpdate()
		end
	end
	
	function f:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unit)
		if ( self.parent.displayerUnit or self.parent.unit ) ~= unit then return end
		self:OnChannelUpdate(unit)	
	end
	
	function f:UNIT_SPELLCAST_START(event, unit)
		if ( self.parent.displayerUnit or self.parent.unit ) ~= unit then return end
		self:OnCast(unit)
	end
	
	function f:UNIT_SPELLCAST_DELAYED(event, unit)
		if ( self.parent.displayerUnit or self.parent.unit ) ~= unit then return end
		self:OnCastUpdate(unit)
	end

	function f:UNIT_SPELLCAST_INTERRUPTED(event, unit)
		if ( self.parent.displayerUnit or self.parent.unit ) ~= unit then return end
		self:Hide()
	end
	
	f.UNIT_SPELLCAST_STOP = f.UNIT_SPELLCAST_INTERRUPTED
	f.UNIT_SPELLCAST_FAILED = f.UNIT_SPELLCAST_INTERRUPTED
	f.UNIT_SPELLCAST_CHANNEL_STOP = f.UNIT_SPELLCAST_INTERRUPTED
	
	function f:UNIT_SPELLCAST_INTERRUPTIBLE(event, unit)
		if ( self.parent.displayerUnit or self.parent.unit ) ~= unit then return end
		self:UpdateIntrerruptState(false)
	end
	
	function f:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(event, unit)
		if ( self.parent.displayerUnit or self.parent.unit ) ~= unit then return end
		local name
		
		if unit == 'player' then
			name = UnitCastingInfo(unit) or UnitChannelInfo(unit)
		end
		
		self:UpdateIntrerruptState(true, name)
	end

	f.CastBarUpdate = function(self)
		self:Hide()
		
		local unit = self.parent.displayerUnit or self.parent.unit
		if UnitChannelInfo(unit) then self:UNIT_SPELLCAST_CHANNEL_START(_, unit) end
		if UnitCastingInfo(unit) then self:UNIT_SPELLCAST_START(_, unit) end
	end
	
	frame.CastBarUpdate = function(self)
		self.castBar:CastBarUpdate()
	end
	
	return mover
end

function CB:GetCastBarOptions(unit, func, unlockname, dir)

	E.GUI.args.unitframes.args[dir].args['CastBarGo'] = {
		name = L['Casting bar']..' - '..L['Go'],
		order = 5,
		type = "execute",
		width = 'full',
		set = function()
			AleaUI_GUI:SelectGroup("AleaUI", "unitframes", dir, 'castBar')
		end,
		get = function()
		
		end,
	}
		
	local t = {
		name = L['Casting bar'],
		order = 10,
	--	embend = true,
		type = "group",
		args = {}
	}
	
	t.args.goback = {
		name = L['Back'],
		order = 0.1,
		type = "execute",
		width = 'full',
		set = function()
			AleaUI_GUI:SelectGroup("AleaUI", "unitframes", dir)
		end,
		get = function()
		
		end,
	}

	t.args.unlockcastbar = {
		name = L['Unlock'],
		order = 1.1,
		type = "execute",
		set = function(self, value) E:UnlockMover(unlockname) end,
		get = function(self) end
	}
	
	t.args.Enable = {
		name = L['Enable'],
		order = 1,
		type = "toggle",
		set = function(self, value)				
			E.db.unitframes.unitopts[unit].castBar.enable = not E.db.unitframes.unitopts[unit].castBar.enable
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.enable
		end
	
	}
	
	t.args.ShowIcon = {
		name = L['Show icon'],
		order = 1.2,
		width = 'full',
		type = "toggle",
		set = function(self, value)				
			E.db.unitframes.unitopts[unit].castBar.showIcon = not E.db.unitframes.unitopts[unit].castBar.showIcon
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.showIcon
		end
	
	}
	
	t.args.notinterruptible = {
		name = L['Not interruptible'],
		order = 2,
		type = 'color',
		set = function(info, r,g,b,a)
			E.db.unitframes.unitopts[unit].castBar.colors['notinterruptible'] = { r, g, b, 1 }
			UF[func]()
		end,
		get = function(info)
			return 	E.db.unitframes.unitopts[unit].castBar.colors['notinterruptible'][1],
					E.db.unitframes.unitopts[unit].castBar.colors['notinterruptible'][2],
					E.db.unitframes.unitopts[unit].castBar.colors['notinterruptible'][3],
					1
		end,
	}
	
	t.args.interruptible = {
		name = L['Interruptible'],
		order = 3,
		type = 'color',
		set = function(info, r,g,b,a)
			E.db.unitframes.unitopts[unit].castBar.colors['interruptible'] = { r, g, b, 1 }
			UF[func]()
		end,
		get = function(info)
			return 	E.db.unitframes.unitopts[unit].castBar.colors['interruptible'][1],
					E.db.unitframes.unitopts[unit].castBar.colors['interruptible'][2],
					E.db.unitframes.unitopts[unit].castBar.colors['interruptible'][3],
					1
		end,
	}
	
	t.args.background = {
		name = L['Background'],
		order = 2.1,
		type = 'color',
		set = function(info, r,g,b,a)
			E.db.unitframes.unitopts[unit].castBar.colors['background'] = { r, g, b, 1 }
			UF[func]()
		end,
		get = function(info)
			return 	E.db.unitframes.unitopts[unit].castBar.colors['background'][1],
					E.db.unitframes.unitopts[unit].castBar.colors['background'][2],
					E.db.unitframes.unitopts[unit].castBar.colors['background'][3],
					1
		end,
	}
	
	t.args.texture = {	
		name = L['Texture'],
		order = 3.1,
		type = "statusbar",
		values = E.GetTextureList,
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.texture = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.texture
		end,
	}
	
	t.args.font = {	
		name = L['Font'],
		order = 3.2,
		type = "font",
		values = E.GetFontList,
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.font = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.font
		end,
	}
	t.args.fontOutline = {	
		name = L['Outline'],
		order = 3.3,
		type = "dropdown",
		values = {			
			[""] = NO,
			["OUTLINE"] = "OUTLINE",
		},
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.fontOutline = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.fontOutline
		end,
	}
	t.args.fontSize = {	
		name = L['Size'],
		order = 3.4,
		type = "slider",
		min = 1, max = 32, step = 1,
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.fontSize = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.fontSize
		end,
	}
	
	t.args.width = {
		name = L['Width'],
		order = 3.5,
		type = 'slider',
		min = 1, max = 600, step = 1,
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.width = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.width
		end,	
	}
	t.args.height = {
		name = L['Height'],
		order = 3.6,
		type = 'slider',
		min = 1, max = 600, step = 1,
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.height = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.height
		end,	
	}
	
	t.args.Alpha = {	
		name = L['Transparency'],
		order = 3.7,
		type = "slider",
		min = 0, max = 1, step = 0.1,
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.alpha = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.alpha
		end,
	}
	
	if unit == 'player' then
		
		t.args.ticks = {
			name = L['Ticks'],
			order = 6,
			type = 'color',
			hasAlpha = true,
			set = function(info, r,g,b,a)
				E.db.unitframes.unitopts[unit].castBar.colors['ticks'] = { r, g, b, a }
				UF[func]()
			end,
			get = function(info)
				return 	E.db.unitframes.unitopts[unit].castBar.colors['ticks'][1],
						E.db.unitframes.unitopts[unit].castBar.colors['ticks'][2],
						E.db.unitframes.unitopts[unit].castBar.colors['ticks'][3],
						E.db.unitframes.unitopts[unit].castBar.colors['ticks'][4]
			end,
		}
		
		t.args.ping = {
			name = L['Ping'],
			order = 5,
			type = 'color',
			hasAlpha = true,
			set = function(info, r,g,b,a)
				E.db.unitframes.unitopts[unit].castBar.colors['ping'] = { r, g, b, a }
				UF[func]()
			end,
			get = function(info)
				return 	E.db.unitframes.unitopts[unit].castBar.colors['ping'][1],
						E.db.unitframes.unitopts[unit].castBar.colors['ping'][2],
						E.db.unitframes.unitopts[unit].castBar.colors['ping'][3],
						E.db.unitframes.unitopts[unit].castBar.colors['ping'][4]
			end,
		}
		
		t.args.gcdoffset = {
			name = L['GCD offset'],
			order = 5,
			type = 'slider',
			min = -60, max = 60, step = 1,
			set = function(info, value)
				E.db.unitframes.unitopts[unit].castBar.gcdoffset = value
				UF[func]()
			end,
			get = function(info)
				return E.db.unitframes.unitopts[unit].castBar.gcdoffset
			end,		
		}
	end
	--[==[
	t.args.level = {
		name = 'Уровень слоя',
		order = 7,
		type = 'slider',
		min = 0, max = 5, step = 1,
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.level = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.level
		end,
	}
	]==]
	t.args.BorderOpts = {
		name = L['Borders'],
		order = 10,
		embend = true,
		type = "group",
		args = {}
	}
	
	t.args.BorderOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L['Border texture'],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.unitframes.unitopts[unit].castBar.border.texture = value;
			UF[func]()
		end,
		get = function(info) return E.db.unitframes.unitopts[unit].castBar.border.texture end,
	}

	t.args.BorderOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.unitframes.unitopts[unit].castBar.border.color={ r, g, b, a}; 
			UF[func]()
		end,
		get = function(info) 
			return E.db.unitframes.unitopts[unit].castBar.border.color[1],
					E.db.unitframes.unitopts[unit].castBar.border.color[2],
					E.db.unitframes.unitopts[unit].castBar.border.color[3],
					E.db.unitframes.unitopts[unit].castBar.border.color[4] 
		end,
	}

	t.args.BorderOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.unitframes.unitopts[unit].castBar.border.size = val
			UF[func]()
		end,
		get =function(info)
			return E.db.unitframes.unitopts[unit].castBar.border.size
		end,
	}

	t.args.BorderOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.unitframes.unitopts[unit].castBar.border.inset = val
			UF[func]()
		end,
		get =function(info)
			return E.db.unitframes.unitopts[unit].castBar.border.inset
		end,
	}


	t.args.BorderOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Border texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.unitframes.unitopts[unit].castBar.border.background_texture = value;
			UF[func]()
		end,
		get = function(info) return E.db.unitframes.unitopts[unit].castBar.border.background_texture end,
	}

	t.args.BorderOpts.args.BackgroundColor = {
		order = 6,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.unitframes.unitopts[unit].castBar.border.background_color={ r, g, b, a}
			UF[func]()
		end,
		get = function(info) 
			return E.db.unitframes.unitopts[unit].castBar.border.background_color[1],
					E.db.unitframes.unitopts[unit].castBar.border.background_color[2],
					E.db.unitframes.unitopts[unit].castBar.border.background_color[3],
					E.db.unitframes.unitopts[unit].castBar.border.background_color[4] 
		end,
	}


	t.args.BorderOpts.args.backgroundInset = {
		name = L['Background inset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.unitframes.unitopts[unit].castBar.border.background_inset = val
			UF[func]()
		end,
		get =function(info)
			return E.db.unitframes.unitopts[unit].castBar.border.background_inset
		end,
	}
	
	
	return t
end

function CB:GetGroupedCastBarOptions(unit, func, dir)
	
	E.GUI.args.unitframes.args[dir].args['castingBarGo'] = {
		name = L['Casting bar']..' - '..L['Go'],
		order = 5,
		type = "execute",
		width = 'full',
		set = function()
			AleaUI_GUI:SelectGroup("AleaUI", "unitframes", dir, 'castBar')
		end,
		get = function()
		
		end,
	}
			
	local t = {
		name = L['Casting bar'],
		order = 5,
		embend = false,
		type = "group",
		args = {}
	}
	
	t.args.goback = {
		name = L['Back'],
		order = 0.1,
		type = "execute",
		width = 'full',
		set = function()
			AleaUI_GUI:SelectGroup("AleaUI", "unitframes", dir)
		end,
		get = function()
		
		end,
	}
					
	t.args.Enable = {
		name = L['Enable'],
		order = 0.2,
		width = 'full',
		type = "toggle",
		set = function(self, value)				
			E.db.unitframes.unitopts[unit].castBar.enable = not E.db.unitframes.unitopts[unit].castBar.enable
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.enable
		end
	
	}
	
	t.args.ShowIcon = {
		name = L['Show icon'],
		order = 0.3,
		width = 'full',
		type = "toggle",
		set = function(self, value)				
			E.db.unitframes.unitopts[unit].castBar.showIcon = not E.db.unitframes.unitopts[unit].castBar.showIcon
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.showIcon
		end
	
	}
	
	t.args.notinterruptible = {
		name = L['Not interruptible'],
		order = 0.4,
		type = 'color',
		set = function(info, r,g,b,a)
			E.db.unitframes.unitopts[unit].castBar.colors['notinterruptible'] = { r, g, b, 1 }
			UF[func]()
		end,
		get = function(info)
			return 	E.db.unitframes.unitopts[unit].castBar.colors['notinterruptible'][1],
					E.db.unitframes.unitopts[unit].castBar.colors['notinterruptible'][2],
					E.db.unitframes.unitopts[unit].castBar.colors['notinterruptible'][3],
					1
		end,
	}
	
	t.args.interruptible = {
		name = L['Interruptible'],
		order = 0.5,
		type = 'color',
		set = function(info, r,g,b,a)
			E.db.unitframes.unitopts[unit].castBar.colors['interruptible'] = { r, g, b, 1 }
			UF[func]()
		end,
		get = function(info)
			return 	E.db.unitframes.unitopts[unit].castBar.colors['interruptible'][1],
					E.db.unitframes.unitopts[unit].castBar.colors['interruptible'][2],
					E.db.unitframes.unitopts[unit].castBar.colors['interruptible'][3],
					1
		end,
	}
	
	t.args.background = {
		name = L['Background'],
		order = 0.6,
		type = 'color',
		set = function(info, r,g,b,a)
			E.db.unitframes.unitopts[unit].castBar.colors['background'] = { r, g, b, 1 }
			UF[func]()
		end,
		get = function(info)
			return 	E.db.unitframes.unitopts[unit].castBar.colors['background'][1],
					E.db.unitframes.unitopts[unit].castBar.colors['background'][2],
					E.db.unitframes.unitopts[unit].castBar.colors['background'][3],
					1
		end,
	}
	
	t.args.texture = {	
		name = L['Texture'],
		order = 0.7,
		type = "statusbar",
		values = E.GetTextureList,
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.texture = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.texture
		end,
	}
	
	t.args.font = {	
		name = L['Font'],
		order = 0.8,
		type = "font",
		values = E.GetFontList,
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.font = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.font
		end,
	}
	t.args.fontOutline = {	
		name = L['Outline'],
		order = 0.9,
		type = "dropdown",
		values = {			
			[""] = NO,
			["OUTLINE"] = "OUTLINE",
		},
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.fontOutline = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.fontOutline
		end,
	}
	t.args.fontSize = {	
		name = L['Size'],
		order = 1,
		type = "slider",
		min = 1, max = 32, step = 1,
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.fontSize = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.fontSize
		end,
	}
						
	t.args.width = {
		name = L['Width'],
		order = 1.1,
		type = 'slider',
		min = 1, max = 600, step = 1,
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.width = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.width
		end,	
	}
	t.args.height = {
		name = L['Height'],
		order = 2,
		type = 'slider',
		min = 1, max = 600, step = 1,
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.height = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.height
		end,	
	}
				
	t.args.xOffset = {
		name = L['Horizontal offset'],
		order = 3,
		type = 'slider',
		min = -600, max = 600, step = 1,
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.pos[1] = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.pos[1]
		end,
	}
	t.args.yOffset = {
		name = L['Vertical offset'],
		order = 4,
		type = 'slider',
		min = -600, max = 600, step = 1,
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.pos[2] = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.pos[2]
		end,
	}
	
	t.args.Alpha = {	
		name = L['Transparency'],
		order = 4.1,
		type = "slider",
		min = 0, max = 1, step = 0.1,
		set = function(self, value)
			E.db.unitframes.unitopts[unit].castBar.alpha = value
			UF[func]()
		end,
		get = function(self)
			return E.db.unitframes.unitopts[unit].castBar.alpha
		end,
	}
	
	t.args.point = {
		name = L['Fixation point'],
		order = 5,
		type = 'dropdown',
		values = {		
			['LEFT'] = L['Left'],
			['RIGHT'] = L['Right'],
			['CENTER'] = L['Center'],	
		},
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.point = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.point
		end,
	
	}
	--[==[
	t.args.level = {
		name = 'Уровень слоя',
		order = 7,
		type = 'slider',
		min = 0, max = 5, step = 1,
		set = function(info, value)
			E.db.unitframes.unitopts[unit].castBar.level = value
			UF[func]()
		end,
		get = function(info)
			return E.db.unitframes.unitopts[unit].castBar.level
		end,
	}
	]==]
	t.args.BorderOpts = {
		name = L['Borders'],
		order = 10,
		embend = true,
		type = "group",
		args = {}
	}
	
	t.args.BorderOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L['Border texture'],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.unitframes.unitopts[unit].castBar.border.texture = value;
			UF[func]()
		end,
		get = function(info) return E.db.unitframes.unitopts[unit].castBar.border.texture end,
	}

	t.args.BorderOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.unitframes.unitopts[unit].castBar.border.color={ r, g, b, a}; 
			UF[func]()
		end,
		get = function(info) 
			return E.db.unitframes.unitopts[unit].castBar.border.color[1],
					E.db.unitframes.unitopts[unit].castBar.border.color[2],
					E.db.unitframes.unitopts[unit].castBar.border.color[3],
					E.db.unitframes.unitopts[unit].castBar.border.color[4] 
		end,
	}

	t.args.BorderOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.unitframes.unitopts[unit].castBar.border.size = val
			UF[func]()
		end,
		get =function(info)
			return E.db.unitframes.unitopts[unit].castBar.border.size
		end,
	}

	t.args.BorderOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.unitframes.unitopts[unit].castBar.border.inset = val
			UF[func]()
		end,
		get =function(info)
			return E.db.unitframes.unitopts[unit].castBar.border.inset
		end,
	}


	t.args.BorderOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Background texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.unitframes.unitopts[unit].castBar.border.background_texture = value;
			UF[func]()
		end,
		get = function(info) return E.db.unitframes.unitopts[unit].castBar.border.background_texture end,
	}

	t.args.BorderOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.unitframes.unitopts[unit].castBar.border.background_color={ r, g, b, a}
			UF[func]()
		end,
		get = function(info) 
			return E.db.unitframes.unitopts[unit].castBar.border.background_color[1],
					E.db.unitframes.unitopts[unit].castBar.border.background_color[2],
					E.db.unitframes.unitopts[unit].castBar.border.background_color[3],
					E.db.unitframes.unitopts[unit].castBar.border.background_color[4] 
		end,
	}


	t.args.BorderOpts.args.backgroundInset = {
		name = L['Background inset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.unitframes.unitopts[unit].castBar.border.background_inset = val
			UF[func]()
		end,
		get =function(info)
			return E.db.unitframes.unitopts[unit].castBar.border.background_inset
		end,
	}
	return t
end