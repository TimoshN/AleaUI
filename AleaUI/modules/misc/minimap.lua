local addonName, E = ...
local L = E.L
local raidBuffSide = 'LEFT'

local defaults = {
	enable_raidbuffs = true,
	minimap_size = 138,
	raidBuffpanel_size = 138,
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
			0,  
		},
		["texture"] = E.media.default_bar_texture_name3,
	},
}

E.default_settings.minimap = defaults


------------------
--  END CONFIG  --
------------------
Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
if ( Minimap.SetQuestBlobRingAlpha ) then 
	Minimap:SetQuestBlobRingAlpha(0)
end
if (Minimap.SetArchBlobRingAlpha) then 
	Minimap:SetArchBlobRingAlpha(0)
end
Minimap:SetScale(1)
Minimap:SetFrameLevel(3)
Minimap:SetFrameStrata('LOW')
Minimap:Raise() 
GetMinimapShape = function() return 'SQUARE' end

MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint('TOPRIGHT', UIParent, -20, -20)
MinimapCluster:EnableMouse(false)

local artBorder = CreateFrame("Frame", nil, Minimap, BackdropTemplateMixin and 'BackdropTemplate')
artBorder:SetFrameLevel(Minimap:GetFrameLevel())
artBorder:SetBackdrop({
  edgeFile = [[Interface\Buttons\WHITE8x8]],
  edgeSize = 1, 
})
artBorder:SetBackdropBorderColor(0,0,0,1)
artBorder:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, -0)
artBorder:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -0, 0)

artBorder.back = Minimap:CreateTexture()
artBorder.back:SetDrawLayer('BACKGROUND', -2)
artBorder.back:SetColorTexture(0, 0, 0, 0)
artBorder.back:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
artBorder.back:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0, 0)
		
function E:UpdateMinimapArtBorder()

	local opts = E.db.minimap
		
	artBorder:SetBackdrop({
	  edgeFile = E:GetBorder(opts.border.texture),
	  edgeSize = opts.border.size, 
	})
	artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
	artBorder:SetPoint("TOPLEFT", Minimap, "TOPLEFT", opts.border.inset, -opts.border.inset)
	artBorder:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

	artBorder.back:SetTexture(E:GetTexture(opts.border.background_texture))
	artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
	artBorder.back:SetPoint("TOPLEFT", Minimap, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
	artBorder.back:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)

end

local clockFrame = CreateFrame('Frame', nil, UIParent)
clockFrame:SetScript('OnEvent', function(self, event, name)
    if name == 'Blizzard_TimeManager' then
        TimeManagerClockButton:Hide()
        TimeManagerClockButton:SetScript('OnShow', function(self)
           TimeManagerClockButton:Hide()
        end)
    end
end)
clockFrame:RegisterEvent('ADDON_LOADED')

local hideThis = {
	'MinimapBorder',
	'MinimapBorderTop',
	'MinimapNorthTag',
	'MiniMapWorldMapButton',
	'MinimapZoneTextButton',
	'MinimapZoomIn',
	'MinimapZoomOut',
	--'WatchFrame',
	'GameTimeFrame',
	'MiniMapTracking',
--	'ZoneTextFrame',
--	'SubZoneTextFrame',
}

for i, v in pairs(hideThis) do
	if ( _G[v] ) then 
		hooksecurefunc(_G[v],"Show", _G[v].Hide)	
		_G[v]:Hide()
	end 
end

if ( QueueStatusMinimapButton ) then 
	QueueStatusMinimapButton:SetScale(.9)
	QueueStatusMinimapButton:SetFrameStrata("MEDIUM")
	QueueStatusMinimapButton:SetFrameLevel(10)
	QueueStatusMinimapButtonBorder:Hide()
end 

MiniMapMailFrame:SetFrameStrata("HIGH")

local minimapFlags = {
	"MiniMapInstanceDifficulty",
	"GuildInstanceDifficulty",
	"MiniMapChallengeMode",
}

local minimapFlagPoint1, minimapFlagPoint2, minimapFlagXoffset, minimapFlagYoffset
local function HookFlagRepoint(self, point1, anchor, point2, x, y)
	if point1 ~= minimapFlagPoint1 or
	   point2 ~= minimapFlagPoint2 or
	   x ~= minimapFlagXoffset or
	   y ~= minimapFlagYoffset then
		self:ClearAllPoints()
		self:SetPoint(minimapFlagPoint1, Minimap, minimapFlagPoint2,minimapFlagXoffset,minimapFlagYoffset)
	end
end

local function SelectMinimapButtonPoint()
	if ( QueueStatusMinimapButton ) then 
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusFrame:ClearAllPoints()
	end 

	MiniMapMailFrame:ClearAllPoints()

	if raidBuffSide == 'LEFT' then
		if ( QueueStatusMinimapButton ) then 
			QueueStatusMinimapButton:SetPoint('BOTTOMRIGHT', Minimap, 3, 1)
			QueueStatusFrame:SetPoint('TOPLEFT', QueueStatusMinimapButton, "TOPRIGHT", 3, 1)
		end 

		MiniMapMailFrame:SetPoint('TOPRIGHT', Minimap, 2, 3)
		
		minimapFlagPoint1, minimapFlagPoint2, minimapFlagXoffset, minimapFlagYoffset = 'TOPLEFT', "TOPLEFT", 2, 3
			
		for i=1, #minimapFlags do
			if ( _G[minimapFlags[i]] ) then
				_G[minimapFlags[i]]:SetFrameStrata("MEDIUM")
				_G[minimapFlags[i]]:ClearAllPoints()
				_G[minimapFlags[i]]:SetPoint(minimapFlagPoint1, Minimap, minimapFlagPoint2,minimapFlagXoffset,minimapFlagYoffset)
				_G[minimapFlags[i]]:SetScale(0.9)
				if not _G[minimapFlags[i]].hooked then
					_G[minimapFlags[i]].hooked = true
					hooksecurefunc(_G[minimapFlags[i]], 'SetPoint', HookFlagRepoint)
				end
			end
		end
	
	else
		if ( QueueStatusMinimapButton ) then 
			QueueStatusMinimapButton:SetPoint('BOTTOMLEFT', Minimap, -3, 1)
			QueueStatusFrame:SetPoint('TOPRIGHT', QueueStatusMinimapButton, "TOPLEFT", -3, 1)
		end 

		MiniMapMailFrame:SetPoint('TOPLEFT', Minimap, -2, 3)
		
		minimapFlagPoint1, minimapFlagPoint2, minimapFlagXoffset, minimapFlagYoffset = 'TOPRIGHT', "TOPRIGHT", -2, 3
		
		for i=1, #minimapFlags do
			_G[minimapFlags[i]]:SetFrameStrata("MEDIUM")
			_G[minimapFlags[i]]:ClearAllPoints()
			_G[minimapFlags[i]]:SetPoint(minimapFlagPoint1, Minimap, minimapFlagPoint2,minimapFlagXoffset,minimapFlagYoffset)
			_G[minimapFlags[i]]:SetScale(0.9)
			
			if not _G[minimapFlags[i]].hooked then
				_G[minimapFlags[i]].hooked = true
				hooksecurefunc(_G[minimapFlags[i]], 'SetPoint', HookFlagRepoint)
			end
		end
		
	end
end

do
	if ( VehicleSeatIndicator ) then 
		local VehicleSeatMover = CreateFrame("Frame", nil, E.UIParent)
			VehicleSeatMover:SetSize(100,100)
			VehicleSeatMover:SetPoint("CENTER", E.UIParent, "CENTER", 0, 0)
			VehicleSeatMover:EnableMouse(false)		

		hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
			if (parent ~=  VehicleSeatMover ) then
				VehicleSeatIndicator:ClearAllPoints()
				VehicleSeatIndicator:SetPoint("CENTER", VehicleSeatMover, "CENTER", 0, 0)
				VehicleSeatIndicator:SetScale(0.8)		
			end
		end)
		VehicleSeatIndicator:SetPoint('TOPLEFT', MinimapCluster, 'TOPLEFT', 2, 2) -- initialize mover

		function E:UpdateVehicleSeatMover()			
			E:Mover(VehicleSeatMover, "vehicleSeatMover")
		end
		
		E:OnInit(E.UpdateVehicleSeatMover)
	end
end

do
	DurabilityFrame:SetFrameStrata("HIGH")
	hooksecurefunc(DurabilityFrame,"SetPoint",function(self,_,parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			DurabilityFrame:ClearAllPoints()
			DurabilityFrame:SetPoint("RIGHT", Minimap, "RIGHT")
			DurabilityFrame:SetScale(0.6)
		end
	end)	
end

--[[
MiniMapMailBorder:SetTexture('Interface\Minimap\MiniMap-TrackingBorder')
MiniMapMailIcon:SetTexture('Interface\Icons\INV_Letter_15')
]]

Minimap:SetScript('OnMouseUp', function(self, button)
    if (button == 'RightButton') then
        ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * .7), -3)
    elseif (button == 'MiddleButton') then
        ToggleCalendar()
	else
        Minimap_OnClick(self)
    end
end)

Minimap:EnableMouseWheel()
Minimap:SetScript('OnMouseWheel', function(self, direction)
	if(direction > 0) then
		MinimapZoomIn:Click()
	else
		MinimapZoomOut:Click()
	end
end)


local fadingButtons = {}

local minimapFader = CreateFrame("Frame")
minimapFader.elapsed = 0
minimapFader:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	
	if self.elapsed < 2 and (MouseIsOver(_G["Minimap"]) or not minimapFader.ReadyForFrame() ) then 
		self.elapsed = 0
		for frame in pairs(fadingButtons) do
			frame:SetAlpha(1)
		end		
		return 
	end
	
	if self.elapsed <= 2.5 then
		for frame in pairs(fadingButtons) do
			frame:SetAlpha(2.5-self.elapsed)
		end
	else
		self:Hide()
		self.elapsed = 0		
		for frame in pairs(fadingButtons) do
			frame:SetAlpha(0)
		end
	end
end)

function minimapFader.mimimapFaderFunc()
	minimapFader.InterateChildrend(Minimap:GetChildren())
	minimapFader.elapsed = 0
	minimapFader:Show()
end

function minimapFader.InterateChildrend(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local name = frame:GetName()
		
		if frame.ignoreFading ~= true and not fadingButtons[frame] and ( frame.minimapButtonFadeOut or ( name and string.find(name, "LibDBIcon10") ))  then	
			minimapFader.AddToFading(frame)
		end
	end	
end

function minimapFader.ReadyForFrame()
	
	for frame in pairs(fadingButtons) do	
		if MouseIsOver(frame) then		
			return false
		end
	end
	
	return true
end

function minimapFader.AddToFading(frame)
	if not fadingButtons[frame] then	
		fadingButtons[frame] = true
		
		if frame:HasScript("OnEnter") then
			frame:HookScript("OnEnter", minimapFader.mimimapFaderFunc)	
		else
			frame:SetScript("OnEnter", minimapFader.mimimapFaderFunc)	
		end
		
		if frame:HasScript("OnLeave") then
			frame:HookScript("OnLeave", minimapFader.mimimapFaderFunc)	
		else
			frame:SetScript("OnLeave", minimapFader.mimimapFaderFunc)	
		end
		
	end
end

local ChooseRaidBuffFramePoint

local MinimapPostitonHandler = function(event, point, anchor, secondaryPoint, x, y)
	local cur		
	if ( point == 'TOPLEFT' and secondaryPoint == 'TOPLEFT' ) or ( point == 'BOTTOMLEFT' and secondaryPoint == 'BOTTOMLEFT' ) then
		cur = 'LEFT'
	elseif ( point == 'TOP' and secondaryPoint == 'TOP' ) or ( point == 'CENTER' and secondaryPoint == 'CENTER' ) or ( point == 'BOTTOM' and secondaryPoint == 'BOTTOM' ) then
		if  tonumber(x) >= 0 then cur = 'RIGHT'
		else cur = 'LEFT' end
	elseif ( point == 'TOPRIGHT' and secondaryPoint == 'TOPRIGHT' ) or ( point == 'BOTTOMRIGHT' and secondaryPoint == 'BOTTOMRIGHT' ) then
		cur = 'RIGHT'
	end
	
	if raidBuffSide ~= cur then
		raidBuffSide = cur
		SelectMinimapButtonPoint()
	end
end
	
local function MoveWatchFrame()
	
	if ( Minimap.SetQuestBlobRingAlpha ) then 
		Minimap:SetQuestBlobRingAlpha(0)
	end 

	if ( Minimap.SetArchBlobRingAlpha ) then 
		Minimap:SetArchBlobRingAlpha(0)
	end 

	minimapFader.InterateChildrend(_G["Minimap"]:GetChildren())
	
	_G["Minimap"]:HookScript("OnEnter", minimapFader.mimimapFaderFunc)	
	_G["Minimap"]:HookScript("OnLeave", minimapFader.mimimapFaderFunc)

	E:Mover(_G["Minimap"], "minimapFrames", nil, nil, nil, MinimapPostitonHandler)
	
	SelectMinimapButtonPoint()

	if ( _G["GarrisonLandingPageMinimapButton"] ) then
		_G["GarrisonLandingPageMinimapButton"]:SetScale(0.7)
		_G["GarrisonLandingPageMinimapButton"]:EnableMinimapMoving("garrisonMinimapButton")	
		minimapFader.AddToFading(_G["GarrisonLandingPageMinimapButton"])
	end

	C_Timer.After(0.1, function() 
		minimapFader.InterateChildrend(_G["Minimap"]:GetChildren())
	end)
	
	E:UpdateMinimapArtBorder()
	E:UpdateMiniMapSize()
end

E:OnInit(MoveWatchFrame)

function E:UpdateMiniMapSize()
	Minimap:SetSize(E.db.minimap.minimap_size, E.db.minimap.minimap_size)
end

E.GUI.args.Minimap = {
	name = L['Minimap'],
	type = "group",
	order = 5,
	args = {},
}

E.GUI.args.Minimap.args.Size = {
	name = L['Minimap size'],
	order = 1,
	type = 'slider',
	min= 40, max = 400, step = 1,
	set = function(info, value)
		E.db.minimap.minimap_size = value
		E:UpdateMiniMapSize()
	end,
	get = function(info)
		return E.db.minimap.minimap_size
	end,
}

E.GUI.args.Minimap.args.unlock = {
	name = L['Unlock'],
	order = 2,
	type = "execute",
	set = function(self, value)
		E:UnlockMover('minimapFrames') 
	end,
	get = function(self)
	end,
}

E.GUI.args.Minimap.args.BorderOpts = {
	name = L['Borders'],
	order = 10,
	embend = true,
	type = "group",
	args = {}
}

E.GUI.args.Minimap.args.BorderOpts.args.BorderTexture = {
	order = 1,
	type = 'border',
	name = L['Border texture'],
	values = E:GetBorderList(),
	set = function(info,value) 
		E.db.minimap.border.texture = value;
		E:UpdateMinimapArtBorder()
	end,
	get = function(info) return E.db.minimap.border.texture end,
}

E.GUI.args.Minimap.args.BorderOpts.args.BorderColor = {
	order = 2,
	name = L['Border color'],
	type = "color", 
	hasAlpha = true,
	set = function(info,r,g,b,a) 
		E.db.minimap.border.color={ r, g, b, a}; 
		E:UpdateMinimapArtBorder()
	end,
	get = function(info) 
		return E.db.minimap.border.color[1],
				E.db.minimap.border.color[2],
				E.db.minimap.border.color[3],
				E.db.minimap.border.color[4] 
	end,
}

E.GUI.args.Minimap.args.BorderOpts.args.BorderSize = {
	name = L['Border size'],
	type = "slider",
	order	= 3,
	min		= 1,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		E.db.minimap.border.size = val
		E:UpdateMinimapArtBorder()
	end,
	get =function(info)
		return E.db.minimap.border.size
	end,
}

E.GUI.args.Minimap.args.BorderOpts.args.BorderInset = {
	name = L['Border inset'],
	type = "slider",
	order	= 4,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		E.db.minimap.border.inset = val
		E:UpdateMinimapArtBorder()
	end,
	get =function(info)
		return E.db.minimap.border.inset
	end,
}


E.GUI.args.Minimap.args.BorderOpts.args.BackgroundTexture = {
	order = 5,
	type = 'statusbar',
	name = L['Background texture'],
	values = E.GetTextureList,
	set = function(info,value) 
		E.db.minimap.border.background_texture = value;
		E:UpdateMinimapArtBorder()
	end,
	get = function(info) return E.db.minimap.border.background_texture end,
}

E.GUI.args.Minimap.args.BorderOpts.args.BackgroundColor = {
	order = 6,
	name = L['Background color'],
	type = "color", 
	hasAlpha = true,
	set = function(info,r,g,b,a) 
		E.db.minimap.border.background_color={ r, g, b, a}
		E:UpdateMinimapArtBorder()
	end,
	get = function(info) 
		return E.db.minimap.border.background_color[1],
				E.db.minimap.border.background_color[2],
				E.db.minimap.border.background_color[3],
				E.db.minimap.border.background_color[4] 
	end,
}


E.GUI.args.Minimap.args.BorderOpts.args.backgroundInset = {
	name = L['Background  inset'],
	type = "slider",
	order	= 7,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		E.db.minimap.border.background_inset = val
		E:UpdateMinimapArtBorder()
	end,
	get =function(info)
		return E.db.minimap.border.background_inset
	end,
}