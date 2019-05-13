local E = AleaUI
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "SHAMAN" then return end


local w, h = 80, 10
local maxw, maxh = 200, 10

local NUM_TOTEMS = MAX_TOTEMS or 4

local color = {
	[1] = { 65/255*1.4, 110/255*1.4, 1, 1 },
	[2] = { 65/255*1.4, 110/255*1.4, 1, 1 },
	[3] = { 65/255*1.4, 110/255*1.4, 1, 1 },
	[4] = { 65/255*1.4, 110/255*1.4, 1, 1 },
}


local function OnUpdateTotems(self)
	for i=1,NUM_TOTEMS do
		local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(i)
		
		if haveTotem then
			self.orbs[i]:SetMinMaxValues(startTime,startTime+duration)
			self.orbs[i]:SetValue(startTime+duration - (GetTime() - startTime))
		else
			self.orbs[i]:SetMinMaxValues(0,1)
			self.orbs[i]:SetValue(0)
		end
	end
end

local function ShamanTotemBar()
	local f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "totembarFrame", maxw, maxh)
	f.orbs = {}
	f.eventlist = { 
		["PLAYER_TOTEM_UPDATE"]		= "",
		}
	f:SetScript("OnUpdate", OnUpdateTotems)
	
	for i=1, NUM_TOTEMS do
		f:SetSize(maxw, maxh)
		
		local o = CreateFrame("StatusBar", nil, f)
		o:SetSize(maxw/NUM_TOTEMS-1, maxh)
		o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
		o:SetPoint("LEFT", f, "LEFT", (maxw/NUM_TOTEMS)*(i-1), 0)
		o:SetStatusBarColor(unpack(color[i]))
		o:SetMinMaxValues(0,1)
		
		o.art = CreateFrame("Frame", nil, o)
		o.art:SetFrameLevel(o:GetFrameLevel()-1)
		o.art:SetBackdrop({
		  bgFile = [[Interface\Buttons\WHITE8x8]], 
		  edgeFile = [[Interface\Buttons\WHITE8x8]], 
		  edgeSize = 1, 
		})
		o.art:SetBackdropColor(color[i][1]*0.4,color[i][2]*0.4,color[i][3]*0.4, 1)
		o.art:SetBackdropBorderColor(0,0,0,1)
		o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
		o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)

		f.orbs[i] = o
	end

	function f:PLAYER_TOTEM_UPDATE(event, totem)
	--	local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totem)
		
		--print(event, totem, haveTotem, totemName, startTime, duration, icon)
	end
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = E.L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("totembarFrame") 
		end,
		get = function(self)end
	}
	
	return f
end

CBF:AddClassBar(class, 1, ShamanTotemBar)
CBF:AddClassBar(class, 2, ShamanTotemBar)
CBF:AddClassBar(class, 3, ShamanTotemBar)