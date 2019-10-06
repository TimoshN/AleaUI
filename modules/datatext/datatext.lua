local addonName, E = ...
local L = E.L
local datatext = E:Module("DataText")

local defaults = {
	['minimap'] = {
		enable = true,
		datas = { 'Friends', 'Guild', 'NONE', 'NONE', "NONE", "NONE", "NONE", "NONE" },
		amount = 2,
		width = 138,
		height = 20,
		background = true,
		autoWidth = false,
		background_color = { 0, 0, 0, 0.8 },
		background_texture = '',
		["border"] = {
			["background_texture"] = E.media.default_bar_texture_name3,
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
				0.8,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},
	},
	['leftSide'] = {
		enable = true,
		datas = { 'Talent/Loot Specialization', 'Durability', 'Combat/Arena Time', 'NONE', "NONE", "NONE", "NONE", "NONE" },
		amount = 3,
		width = 392,
		height = 20,
		background = true,
		autoWidth = false,
		background_color = { 0, 0, 0, 0.8 },
		background_texture = '',
		["border"] = {
			["background_texture"] = E.media.default_bar_texture_name3,
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
				0.8,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},
	},
	['rightSide'] = {
		enable = true,
		datas = { 'System', 'Time', 'Gold', 'NONE', "NONE", "NONE", "NONE", "NONE"  },
		amount = 3,
		width = 392,
		height = 20,
		autoWidth = false,
		background = true,
		background_color = { 0, 0, 0, 0.8 },
		background_texture = '',
		["border"] = {
			["background_texture"] = E.media.default_bar_texture_name3,
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
				0.8,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},
	},
}

E.default_settings.datatexts = defaults

local dataTextList_Sorted = {}
local dataTextID_to_Name = {}
local dataTextName_to_ID = {}

local UpdateAmoutDropDowns, availibleMenu

local GlowList = {}
local GlowFrame = CreateFrame('Frame')

local function RemoveGlowFrame(frame)
	local index = 1
	while ( GlowList[index] ) do	
		if GlowList[index] == frame then
			table.remove(GlowList, index)
			break
		else
			index = index + 1
		end
	end
	
	if #GlowList == 0  then
		GlowFrame:SetScript('OnUpdate', nil)
	end
end

local function GlowFrame_OnUpdate(self, elapsed)
	local index = 1
	local frame
	while ( GlowList[index] ) do
		frame = GlowList[index]
		
		frame.duration = ( frame.duration or 0 ) + ( elapsed * frame.dir )
		
		if frame.duration > 0.7 then
			frame.duration = 0.7
			frame.dir = -0.5
		elseif frame.glowing_stop then
			if frame.duration < 0 then
				frame.duration = 0
				frame:SetAlpha(0)
				RemoveGlowFrame(frame)
			end
		elseif frame.duration < 0.2 then
			frame.duration = 0.2
			frame.dir = 0.5
		end

		frame:SetAlpha(frame.duration)
		
		index = index + 1
	end
	
	if #GlowList == 0  then
		GlowFrame:SetScript('OnUpdate', nil)
	end
end

local function AddGlowFrame(frame)
	GlowList[#GlowList+1] = frame
	GlowFrame:SetScript('OnUpdate', GlowFrame_OnUpdate)
end

local function StartGlowing(self)
	if not self.glowing then
		self.glowing = true
		self.dir = 1
		AddGlowFrame(self)
	end
end

local function EndGlowing(self, forceStop)
	if forceStop then
		RemoveGlowFrame(self)
		self.glowing = nil
	else
		if self.glowing then
			self.glowing_stop = true
		end
	end
end

local function AutoWidthHandler(self)

	--print( self.text:GetStringWidth() )
	
	--self.frame:SetWidth(self.text:GetStringWidth())
end

local HookTextst 
do
	local frame = CreateFrame('Frame', nil, UIParent)
	frame:SetSize(200,200)
	frame:SetPoint("CENTER")
	frame:Hide()

	local str = frame:CreateFontString()
	str:SetTextColor(1,1,1)
	str:SetPoint('CENTER')
	str:SetJustifyH("CENTER")
	
	local texture = frame:CreateTexture()
	texture:SetPoint("TOPLEFT", str, 'TOPLEFT', 0, 0)
	texture:SetPoint("BOTTOMRIGHT", str, 'BOTTOMRIGHT', 0, 0)
	texture:SetColorTexture(1, 0, 0, 0.3)

	local function UpdateParentSpacing(self)
		local parent = self:GetParent():GetParent()
		local texts = parent.texts
		local num = E.db.datatexts[parent.settings].amount

		local totalWidth = 0
		for i=1, num do 
			totalWidth = totalWidth + texts[i]:GetWidth()
		end


		local leftWidht = parent:GetWidth() - totalWidth
		local offset = 10

		if ( leftWidht > 0 ) then
			offset = leftWidht/num
		end

	--	print('num=', num, 'parent:GetWidth()=', parent:GetWidth(), 'totalWidth=', totalWidth, 'offset=', offset)

		for i=1, num do 
			texts[i]:SetPoint("LEFT", parent.texts[i-1] or parent, parent.texts[i-1] and 'RIGHT' or 'LEFT', parent.texts[i-1] and offset or offset, 0)
		end
	end

	function HookTextst(obj)
		if not obj.hooked then
			obj.hooked = true
		
			obj._oldSetText = obj.SetText
			obj.SetText = function(self, text)
			
				if not self.opts.autoWidth then
					self:_oldSetText( text )
					return
				end
				
				if str.last ~= self then
					str.last = self
					
					local fontName, fontSize, fontOutline = self:GetFont()
					
					if self.lastfontName ~= fontName or 
						self.lastfontSize ~= fontSize or
						self.lastfontOutline ~= fontOutline then
						
						self.lastfontName = fontName
						self.lastfontSize = fontSize
						self.lastfontOutline = fontOutline
						
						str:SetFont(self:GetFont())					
					end
				end
				
				str:SetText( text )
			
				local prev = self:GetParent():GetWidth()

				self:GetParent():SetWidth( str:GetStringWidth() )
				self:_oldSetText( text )

			--	print(self:GetParent():GetParent().texts)

				if ( prev ~= str:GetStringWidth() ) then
					UpdateParentSpacing(self)
				end
			end
			
			obj._oldSetFormattedText = obj.SetFormattedText
			obj.SetFormattedText = function(self, pattern, ...)
					
				if not self.opts.autoWidth then
					self:_oldSetFormattedText( pattern, ... )
					return
				end
				
				if str.last ~= self then
					str.last = self
					
					local fontName, fontSize, fontOutline = self:GetFont()
					
					if self.lastfontName ~= fontName or 
						self.lastfontSize ~= fontSize or
						self.lastfontOutline ~= fontOutline then
						
						self.lastfontName = fontName
						self.lastfontSize = fontSize
						self.lastfontOutline = fontOutline
						
						str:SetFont(self:GetFont())					
					end
				end
				
				str:SetFormattedText( pattern, ... )
		
				local prev = self:GetParent():GetWidth()

				self:GetParent():SetWidth( str:GetStringWidth() )
				self:_oldSetFormattedText( pattern, ... )

				if ( prev ~= str:GetStringWidth() ) then
					UpdateParentSpacing(self)
				end
			end
		end
	end

end

function datatext:CreateDataTextPanel(w,h, num, settings)

	num = num or 1
	
	local f = CreateFrame("Frame", nil, E.UIParent)
	f:SetSize(w, h)
	f.settings = settings
	f.texts = {}
				
	local opts = E.db.datatexts[settings]
	
	f.artBorder = CreateFrame("Frame", nil, f)
	f.artBorder:SetFrameLevel(f:GetFrameLevel())
	f.artBorder:SetBackdrop({
	  edgeFile = E:GetBorder(opts.border.texture),
	  edgeSize = opts.border.size, 
	})
	f.artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
	f.artBorder:SetPoint("TOPLEFT", f, "TOPLEFT", opts.border.inset, -opts.border.inset)
	f.artBorder:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)
	
	f.artBorder.back = f:CreateTexture()
	f.artBorder.back:SetDrawLayer('BACKGROUND', -2)
	f.artBorder.back:SetTexture(E:GetTexture(opts.border.background_texture))
	f.artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
	f.artBorder.back:SetPoint("TOPLEFT", f, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
	f.artBorder.back:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
			
			
	f:SetFrameStrata('LOW')
	
	f.bg = bg
	
	for i=1, #opts.datas do	
		local f1 = CreateFrame("Frame", nil, f)
		f1:ClearAllPoints()
		
		--[==[
		f1.bg = f1.bg or f1:CreateTexture()
		f1.bg:SetColorTexture(1, 0, 0, 1)
		f1.bg:SetAllPoints()
		]==]
		
		if opts.autoWidth then
			f1:SetPoint("LEFT", f.texts[i-1] or f, f.texts[i-1] and 'RIGHT' or 'LEFT', f.texts[i-1] and 10 or 10, 0)
			f1:SetSize(20, h)
		else
			f1:SetPoint("LEFT", f, 'LEFT', (w/num)*(i-1), 0)
			f1:SetSize(w/num, h)
		end
		
		
		local f1t = f1:CreateFontString() --nil, "BACKGROUND")
		f1t:SetFont(E.media.default_font, E.media.default_font_size, "OUTLINE")
		f1t:SetTextColor(1,1,1)
		f1t:SetPoint('CENTER')
		--f1t:SetWidth(50)
		--f1t:SetHeight(24)
		f1t:SetText("Text"..num)
		f1t:SetJustifyH("CENTER")
		f1t.opts = opts
		
		HookTextst(f1t)
		
		--[==[
		f1.sizer = CreateFrame('Frame', nil, f1)
		f1.sizer:SetAllPoints(f1t)
		f1.sizer.text = f1t
		f1.sizer.frame = f1
		f1.sizer.latestWidth = nil
		f1.sizer:SetScript('OnSizeChanged', opts.autoWidth and  AutoWidthHandler or nil)
		if opts.autoWidth then AutoWidthHandler(f1.sizer) end
		]==]
		
		local glow = f1:CreateTexture()
		glow:SetTexture('Interface\\ChatFrame\\ChatFrameTab-NewMessage')
		glow:SetVertexColor(1,1,1,1)
		glow:SetBlendMode('ADD')
		glow:SetPoint('BOTTOM', f1, 'BOTTOM', 0, 0)
		glow:SetSize(60, 18)
		glow:SetAlpha(0)
		glow:Show()
		glow.StartGlowing = StartGlowing
		glow.EndGlowing = EndGlowing
		
		f1.glow = glow
		f1.text = f1t
		f.texts[i] = f1
	end
	
	f.DisabeDataPanel = function(self)
		self:Hide()
		for i=1, #self.texts do
			self.texts[i]:UnregisterAllEvents()	
			self.texts[i].glow:EndGlowing(true)	
			self.texts[i]:SetScript("OnEvent", nil)
			self.texts[i]:SetScript("OnUpdate", nil)
			self.texts[i]:SetScript("OnEnter", nil)
			self.texts[i]:SetScript("OnLeave", nil)
			self.texts[i]:SetScript("OnMouseUp", nil)
			self.texts[i].text:Hide()
		end
	end
	
	f.UpdateDataPanel = function(self)
		local w = E.db.datatexts[self.settings].width
		local h = E.db.datatexts[self.settings].height
		local num = E.db.datatexts[self.settings].amount
		local background = E.db.datatexts[self.settings].background
		local opts = E.db.datatexts[self.settings]
		
		self:SetSize(w, h)
		
		if background then
			self.artBorder:Show()
			self.artBorder.back:Show()
	
			self.artBorder:SetBackdrop({
			  edgeFile = E:GetBorder(opts.border.texture),
			  edgeSize = opts.border.size, 
			})
			self.artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
			self.artBorder:SetPoint("TOPLEFT", self, "TOPLEFT", opts.border.inset, -opts.border.inset)
			self.artBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

			self.artBorder.back:SetTexture(E:GetTexture(opts.border.background_texture))
			self.artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
			self.artBorder.back:SetPoint("TOPLEFT", self, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
			self.artBorder.back:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
		
		
		else
			self.artBorder:Hide()
			self.artBorder.back:Hide()
		end
		
		for i=1, num do	
			local f1 = self.texts[i] or CreateFrame("Frame", nil, self)
			f1:ClearAllPoints()
			
			--[==[
			f1.bg = f1.bg or f1:CreateTexture()
			f1.bg:SetColorTexture(1, 0, 0, 1)
			f1.bg:SetAllPoints()
			]==]
		
			if opts.autoWidth then
				f1:SetPoint("LEFT", self.texts[i-1] or self, self.texts[i-1] and 'RIGHT' or 'LEFT', self.texts[i-1] and 10 or 10, 0)
				f1:SetSize(20, h)
			else
				f1:SetPoint("LEFT", self, 'LEFT', (w/num)*(i-1), 0)
				f1:SetSize(w/num, h)
			end

			local f1t = f1.text or f1:CreateFontString() --nil, "BACKGROUND")
			f1t:SetFont(E.media.default_font, E.media.default_font_size, "OUTLINE")
			f1t:SetTextColor(1,1,1)
			f1t:SetPoint('CENTER')
			f1t:SetText("Text"..num)
			--f1t:SetWidth(50)
			--f1t:SetHeight(24)
			f1t:SetJustifyH("CENTER")
			f1t:Show()
			f1t.opts = opts
			
			HookTextst(f1t)
			--[==[
			f1.sizer = f1.sizer or CreateFrame('Frame', nil, f1)
			f1.sizer:SetAllPoints(f1t)
			f1.sizer.text = f1t
			f1.sizer.frame = f1
			f1.sizer.latestWidth = nil
			f1.sizer:SetScript('OnSizeChanged', opts.autoWidth and  AutoWidthHandler or nil)
			if opts.autoWidth then AutoWidthHandler(f1.sizer) end
			]==]
			local glow = f1.glow or f1:CreateTexture()
			glow:SetTexture('Interface\\ChatFrame\\ChatFrameTab-NewMessage')
			glow:SetVertexColor(1,1,1,1)
			glow:SetBlendMode('ADD')
			glow:SetPoint('BOTTOM', f1, 'BOTTOM', 0, 0)
			glow:SetSize(60, 18)
			glow:SetAlpha(0)
			glow:Show()
			glow.StartGlowing = StartGlowing
			glow.EndGlowing = EndGlowing
			
			f1.glow = glow
			f1.text = f1t
		end
		
		for i=num+1, #self.texts do
			self.texts[i]:UnregisterAllEvents()	
			self.texts[i].glow:EndGlowing(true)	
			self.texts[i]:SetScript("OnEvent", nil)
			self.texts[i]:SetScript("OnUpdate", nil)
			self.texts[i]:SetScript("OnEnter", nil)
			self.texts[i]:SetScript("OnLeave", nil)
			self.texts[i]:SetScript("OnMouseUp", nil)
			self.texts[i].text:Hide()
		end
	end
	
	return f
end

local function HideToolTip()
	if datatext.tooltip then
		datatext.tooltip:Hide()
	end
end

local datatexts = {}
function datatext:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	if not datatexts[name] then
		datatexts[name] = {}
		datatexts[name].onEvent = events
		datatexts[name].onEventFunc = eventFunc
		
		datatexts[name].onUpdateFunc = updateFunc
		datatexts[name].onClickFunc = clickFunc
		datatexts[name].onEnterFunc = onEnterFunc
		datatexts[name].onLeaveFunc = onLeaveFunc or HideToolTip
		
	end
end

function datatext:ApplyDataText(frame, name, index)
	
	frame:Show()
	
	if ( datatexts[name] ) then
		if datatexts[name].onEvent then
			for i, event in pairs(datatexts[name].onEvent) do		
				pcall(frame.texts[index].RegisterEvent, frame.texts[index], event)
			end
		end
		frame.texts[index]:SetScript("OnEvent", datatexts[name].onEventFunc)
		frame.texts[index]:SetScript("OnUpdate", datatexts[name].onUpdateFunc)
		frame.texts[index]:SetScript("OnEnter", datatexts[name].onEnterFunc)
		frame.texts[index]:SetScript("OnLeave", datatexts[name].onLeaveFunc)
		frame.texts[index]:SetScript("OnMouseUp", datatexts[name].onClickFunc)
		
		if datatexts[name].onUpdateFunc then
			datatexts[name].onUpdateFunc(frame.texts[index], 61)
		end
		if datatexts[name].onEventFunc then
			datatexts[name].onEventFunc(frame.texts[index], 'PLAYER_ENTERING_WORLD')
		end
	else 
		print('[DATATEXT] Cant find', name)
	end
end

function datatext:GetTooltipAnchor(parent)

	local ResolutionH = E.UIParent:GetRight()
	local ResolutionV = E.UIParent:GetTop()
	
	local HPoint = ResolutionH*0.5
	local VPoint = ResolutionV*0.5
	
	local p1, p2, p3, p4 = nil, nil, nil, nil
	local p5, p6 = 0, 0
	if ResolutionH - parent:GetRight() > HPoint then
		p2 = 'RIGHT'
		p4 = 'LEFT'
	else
		p2 = 'LEFT'
		p4 = 'RIGHT'
	end
	
	if ResolutionV - parent:GetTop() > VPoint then
		p1 = 'TOP'
		p3 = 'BOTTOM'
		p6 = 3
	else
		p1 = 'BOTTOM'
		p3 = 'TOP'
		p6 = -3
	end
	
	return	p1, p2, p3, p4, p5, p6
end


function datatext:SetupTooltip(self)
	if not datatext.tooltip then
		datatext.tooltip = CreateFrame("GameTooltip", "AleaUIDataTextGameToolTip", E.UIParent, "GameTooltipTemplate"); -- Tooltip name cannot be nil	
		datatext.tooltip:SetBackdrop({ bgFile = nil, edgeFile = nil})
	--	datatext.tooltip:SetScale(1)
		datatext.tooltip:SetBackdropColor(1,1,1,0)
		datatext.tooltip:SetBackdropBorderColor(1,1,1,0)
		
		local border = CreateFrame("Frame", nil, datatext.tooltip)
		border:SetAllPoints()
		border:SetFrameLevel(datatext.tooltip:GetFrameLevel()-1)
		
		datatext.tooltip.border = border
		
		hooksecurefunc(datatext.tooltip, 'SetBackdrop', function(self, a)
			if ( a ~= nil ) then
				self:SetBackdrop(nil)
			end
		end)
		
		hooksecurefunc(datatext.tooltip, 'SetBackdropBorderColor', function(self,r,g,b,a)
			if ( r==1 and g==1 and b==1 ) then
				self:SetBackdropBorderColor(0,0,0,0)
			end
		end)
	
		E:CreateBackdrop(border, border, {0, 0, 0, 1}, {20/255, 20/255, 20/255, 0.8}, "BACKGROUND")
		
		datatext.tooltip:Show()
		datatext.tooltip:Hide()
	end
	
	local parent = self:GetParent()
	datatext.tooltip:Hide()
	
	if parent.customPos then
		parent.customPos(datatext.tooltip)
	else
		datatext.tooltip:SetOwner(parent, 'ANCHOR_PRESERVE')
		
		local p1, p2, p3, p4, p5, p6 = datatext:GetTooltipAnchor(parent)
		
		datatext.tooltip:ClearAllPoints()
		datatext.tooltip:SetPoint(p3, self, p1, p5, p6)
	end
	
	datatext.tooltip:ClearLines()
	datatext.tooltip:SetAlpha(1)
	datatext.tooltip.border:SetUIBackgroundColor(20/255, 20/255, 20/255, 0.8)
	datatext.tooltip.border:SetUIBackdropBorderColor(0, 0, 0, 1)
	
	GameTooltip:Hide() -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
end

local function UpdateDataTexts()
	UpdateAmoutDropDowns('minimap')
	UpdateAmoutDropDowns('leftSide')
	UpdateAmoutDropDowns('rightSide')
	
	datatext.MinimapDataTextPanel:DisabeDataPanel()
	datatext.LeftDataTextPanel:DisabeDataPanel()
	datatext.RightDataTextPanel:DisabeDataPanel()
	
	if E.db.datatexts.minimap.enable then
		
		E:Mover(datatext.MinimapDataTextPanel, "MinimapDataTextPanel")

		datatext.MinimapDataTextPanel:UpdateDataPanel()
		
		for i=1, E.db.datatexts.minimap.amount do
			if E.db.datatexts.minimap.datas[i] ~= 'NONE' then
				datatext:ApplyDataText(datatext.MinimapDataTextPanel, E.db.datatexts.minimap.datas[i], i)
			end
		end
	end

	if E.db.datatexts.leftSide.enable then	
		
		E:Mover(datatext.LeftDataTextPanel, "LeftDataTextPanel")
		
		datatext.LeftDataTextPanel:UpdateDataPanel()
			
		for i=1, E.db.datatexts.leftSide.amount do
			if E.db.datatexts.leftSide.datas[i] ~= 'NONE' then
				datatext:ApplyDataText(datatext.LeftDataTextPanel, E.db.datatexts.leftSide.datas[i], i)
			end
		end
	end
	
	if E.db.datatexts.rightSide.enable then
		
		E:Mover(datatext.RightDataTextPanel, "RightDataTextPanel")
		
		datatext.RightDataTextPanel:UpdateDataPanel()
			
		for i=1, E.db.datatexts.rightSide.amount do
			if E.db.datatexts.rightSide.datas[i] ~= 'NONE' then
				datatext:ApplyDataText(datatext.RightDataTextPanel, E.db.datatexts.rightSide.datas[i], i)
			end
		end
	end
end

local dataTextList_Sorted = {}
local dataTextID_to_Name = {}

local function GetDataTextList()
	wipe(dataTextList_Sorted)
	wipe(dataTextID_to_Name)
	wipe(dataTextName_to_ID)
	
	dataTextList_Sorted[1] = 'Нет'
	dataTextID_to_Name[1] = 'NONE'
	dataTextName_to_ID['NONE'] = 1
	
	local index = 2
	
	for name in pairs(datatexts) do
		dataTextList_Sorted[index] = name
		dataTextID_to_Name[index] = name
		dataTextName_to_ID[name] = index
		
		index = index + 1
	end
	
	return dataTextList_Sorted
end

function UpdateAmoutDropDowns(dir)
	
	for i = 1, E.db.datatexts[dir].amount do
		availibleMenu[dir].args['datas'..i] = {
		
			name = 'datas'..i,
			order = 5+i,
			width = 'full',
			type = 'dropdown',
			values = GetDataTextList,
			set = function(info, value)
				E.db.datatexts[dir].datas[i] = dataTextID_to_Name[value]
				UpdateDataTexts()
			end,
			get = function(info)
				return dataTextName_to_ID[E.db.datatexts[dir].datas[i] or 1] or 1
			end,		
		}
	end

	for i=E.db.datatexts[dir].amount+1, #defaults[dir].datas do
		availibleMenu[dir].args['datas'..i] = nil
	end
end

local function InitDataTexts()
	local md = datatext:CreateDataTextPanel(140,20,2,'minimap')
	md:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, 0)
	md:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 1, 0)
	md.pos = "ANCHOR_BOTTOMLEFT"

	local leftrightwidth = 392
	
	local bd = datatext:CreateDataTextPanel(leftrightwidth,20,3, 'rightSide')
	bd:SetPoint("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", -3, 3)
	bd.pos = "ANCHOR_TOPLEFT"

	local ldt = datatext:CreateDataTextPanel(leftrightwidth,20,3,'leftSide')
	ldt:SetPoint("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 3, 3)
	ldt.pos = "ANCHOR_TOPLEFT"

	datatext.MinimapDataTextPanel = md
	datatext.RightDataTextPanel = bd
	datatext.LeftDataTextPanel = ldt
	
	UpdateDataTexts()
end

datatext.UpdateDataTexts = UpdateDataTexts

E:OnInit(InitDataTexts)

local selectedMenu = nil
availibleMenu = {
	['minimap'] = {
		name = L['Minimap'],
		order = 2,
		embend = true,
		type = "group",
		args = {
			Enable = {
				name = L['Enable'],
				order = 1,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.minimap.enable = not E.db.datatexts.minimap.enable
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.minimap.enable
				end,
			},
			Amount = {
				name = L['Module amount'],
				order = 2,
				type = 'slider',
				min=1, max = 3, step = 1,
				set = function(info, value)
					E.db.datatexts.minimap.amount = value
					UpdateDataTexts()
					UpdateAmoutDropDowns('minimap')
				end,
				get = function(info)
					return E.db.datatexts.minimap.amount
				end,
			},
			width = {
				name = L['Width'],
				order = 3,
				type = 'slider',
				min=100, max = 1000, step = 1,
				set = function(info, value)
					E.db.datatexts.minimap.width = value
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.minimap.width
				end,
			},
			height = {
				name = L['Height'],
				order = 4,
				type = 'slider',
				min=10, max = 100, step = 1,
				set = function(info, value)
					E.db.datatexts.minimap.height = value
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.minimap.height
				end,
			},
			BackgroundEnable = {
				name = L['Enable background'],
				order = 4.1,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.minimap.background = not E.db.datatexts.minimap.background
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.minimap.background
				end,
			},
			
			autoWidth = {
				name = L['Distribute module size'],
				order = 4.2,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.minimap.autoWidth = not E.db.datatexts.minimap.autoWidth
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.minimap.autoWidth
				end,
			},
		}	
	},
	['leftSide'] = {
		name = L['Left panel'],
		order = 2,
		embend = true,
		type = "group",
		args = {
			Enable = {
				name = L['Enable'],
				order = 1,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.leftSide.enable = not E.db.datatexts.leftSide.enable
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.leftSide.enable
				end,
			},
			Move = {
				name = L['Unlock'],
				order = 1.1,
				type = 'execute',
				set = function(info, value)
					E:UnlockMover('LeftDataTextPanel')
				end,
				get = function(info)
					return 
				end,
			},
			Amount = {
				name = L['Module amount'],
				order = 2,
				type = 'slider',
				min=1, max = 8, step = 1,
				set = function(info, value)
					E.db.datatexts.leftSide.amount = value
					UpdateDataTexts()
					UpdateAmoutDropDowns('leftSide')
				end,
				get = function(info)
					return E.db.datatexts.leftSide.amount
				end,
			},
			width = {
				name = L['Width'],
				order = 3,
				type = 'slider',
				min=100, max = 1000, step = 1,
				set = function(info, value)
					E.db.datatexts.leftSide.width = value
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.leftSide.width
				end,
			},
			height = {
				name = L['Height'],
				order = 4,
				type = 'slider',
				min=10, max = 100, step = 1,
				set = function(info, value)
					E.db.datatexts.leftSide.height = value
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.leftSide.height
				end,
			},
			BackgroundEnable = {
				name = L['Enable background'],
				order = 4.1,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.leftSide.background = not E.db.datatexts.leftSide.background
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.leftSide.background
				end,
			},
			autoWidth = {
				name = L['Distribute module size'],
				order = 4.2,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.leftSide.autoWidth = not E.db.datatexts.leftSide.autoWidth
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.leftSide.autoWidth
				end,
			},
		},
	},
	['rightSide'] = {
		name = L['Right panel'],
		order = 2,
		embend = true,
		type = "group",
		args = {
			Enable = {
				name = L['Enable'],
				order = 1,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.rightSide.enable = not E.db.datatexts.rightSide.enable
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.rightSide.enable
				end,
			},
			Move = {
				name = L['Unlock'],
				order = 1.1,
				type = 'execute',
				set = function(info, value)
					E:UnlockMover('RightDataTextPanel')
				end,
				get = function(info)
					return 
				end,
			},
			Amount = {
				name = L['Module amount'],
				order = 2,
				type = 'slider',
				min=1, max = 8, step = 1,
				set = function(info, value)
					E.db.datatexts.rightSide.amount = value
					UpdateDataTexts()
					UpdateAmoutDropDowns('rightSide')
				end,
				get = function(info)
					return E.db.datatexts.rightSide.amount
				end,
			},
			width = {
				name = L['Width'],
				order = 3,
				type = 'slider',
				min=100, max = 1000, step = 1,
				set = function(info, value)
					E.db.datatexts.rightSide.width = value
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.rightSide.width
				end,
			},
			height = {
				name = L['Height'],
				order = 4,
				type = 'slider',
				min=10, max = 100, step = 1,
				set = function(info, value)
					E.db.datatexts.rightSide.height = value
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.rightSide.height
				end,
			},
			BackgroundEnable = {
				name = L['Enable background'],
				order = 4.1,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.rightSide.background = not E.db.datatexts.rightSide.background
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.rightSide.background
				end,
			},
			autoWidth = {
				name = L['Distribute module size'],
				order = 4.2,
				type = 'toggle',
				set = function(info, value)
					E.db.datatexts.rightSide.autoWidth = not E.db.datatexts.rightSide.autoWidth
					UpdateDataTexts()
				end,
				get = function(info)
					return E.db.datatexts.rightSide.autoWidth
				end,
			},
		},	
	},
}

local function AddBorderOpts()
	
	if E.GUI.args.datatexts.args.selectedBorderOpts then
		return
	end
	
	local BorderOpts = {
		name = L['Borders'],
		order = 10,
		embend = true,
		type = "group",
		args = {}
	}
	
	BorderOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L['Border texture'],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.datatexts[selectedMenu].border.texture = value;			
			UpdateDataTexts()
		end,
		get = function(info) return E.db.datatexts[selectedMenu].border.texture end,
	}

	BorderOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.datatexts[selectedMenu].border.color={ r, g, b, a}; 
			UpdateDataTexts()
		end,
		get = function(info) 
			return E.db.datatexts[selectedMenu].border.color[1],
					E.db.datatexts[selectedMenu].border.color[2],
					E.db.datatexts[selectedMenu].border.color[3],
					E.db.datatexts[selectedMenu].border.color[4] 
		end,
	}

	BorderOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.datatexts[selectedMenu].border.size = val
			UpdateDataTexts()
		end,
		get =function(info)
			return E.db.datatexts[selectedMenu].border.size
		end,
	}

	BorderOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.datatexts[selectedMenu].border.inset = val
			UpdateDataTexts()
		end,
		get =function(info)
			return E.db.datatexts[selectedMenu].border.inset
		end,
	}


	BorderOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Background texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.datatexts[selectedMenu].border.background_texture = value;
			UpdateDataTexts()
		end,
		get = function(info) return E.db.datatexts[selectedMenu].border.background_texture end,
	}

	BorderOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.datatexts[selectedMenu].border.background_color={ r, g, b, a}
			UpdateDataTexts()
		end,
		get = function(info) 
			return E.db.datatexts[selectedMenu].border.background_color[1],
					E.db.datatexts[selectedMenu].border.background_color[2],
					E.db.datatexts[selectedMenu].border.background_color[3],
					E.db.datatexts[selectedMenu].border.background_color[4] 
		end,
	}


	BorderOpts.args.backgroundInset = {
		name = L['Background inset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.datatexts[selectedMenu].border.background_inset = val
			UpdateDataTexts()
		end,
		get =function(info)
			return E.db.datatexts[selectedMenu].border.background_inset
		end,
	}
	
	E.GUI.args.datatexts.args.selectedBorderOpts = BorderOpts
end

E.GUI.args.datatexts = {		
	name = L['Data texts'],
	order = 3,
	expand = false,
	type = "group",
	args = {
		selectDataText = {
			type = 'dropdown',
			name = L['Select'],
			order = 0.1,
			width = 'full',
			values = {
				['minimap'] = L['Minimap'],
				['leftSide'] = L['Left panel'],
				['rightSide'] = L['Right panel'],
			},
			set = function(info, value)
				selectedMenu = value
				
				E.GUI.args.datatexts.args.selectedDataOpts = availibleMenu[value]
				E.GUI.args.datatexts.args.descText = nil
				AddBorderOpts()
			end,
			get = function(info)
				return selectedMenu
			end
		},
		descText = {
			name = L['Test'],
			type = 'string',
			order = 2,
			width = 'full',
			set = function(info, value)
			
			end,
			get = function(info)
				return ''
			end,
		},		
		selectedDataOpts = nil,
		selectedBorderOpts = nil
	}
}