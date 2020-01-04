local addonName, E = ...
local L = E.L

if ( E.isClassic ) then  
	return
end 

local holder = CreateFrame('Frame', 'AleaUIAltPowerBarHolder', E.UIParent)
holder:SetSize(128, 50)
holder:Show()

local function ReparentAltPowerBar()

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint('CENTER', holder, 'CENTER', 0, 0)
--	PlayerPowerBarAlt:SetParent(holder)
--	PlayerPowerBarAlt:SetIgnoreFramePositionManager(true)
end


local function PositionAltPowerBar()
	ReparentAltPowerBar()
	
	E:Mover(holder, "powerbarFrame")
	PlayerPowerBarAlt.ignoreFramePositionManager = true
	PlayerPowerBarAlt:SetScale(E.db.Frames["powerbarFrame"].scale or 1)
	
	hooksecurefunc(PlayerPowerBarAlt, 'SetPoint', function(self, a1, a2, a3, a4, a5)	
		if a1 ~= 'CENTER' or a2 ~= holder or a3 ~= 'CENTER' or a4 ~= 0 or a5 ~= 0 then
			ReparentAltPowerBar()
		end
	end)
	
	E.numActonBars = ( E.numActonBars or 0 ) + 1
	
	E.GUI.args.actionbars.args.powerbarFrame = {
		name = L["PowerbarFrame"],
		order = E.numActonBars,
		expand = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.actionbars.args.powerbarFrame.args.unlock = {
		name = L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("powerbarFrame") 
		end,
		get = function(self)end
	}
	
	E.GUI.args.actionbars.args.powerbarFrame.args.scale = {
		name = L["Scale"],
		order = 4,
		type = "slider",
		min = 0.5, max = 3, step = 0.1,
		set = function(self, value)
			E.db.Frames["powerbarFrame"].scale = value
			PlayerPowerBarAlt:SetScale(E.db.Frames["powerbarFrame"].scale)
		end,
		get = function(self) 
			return E.db.Frames["powerbarFrame"].scale or 1
		end
	}
end


E:OnInit2(PositionAltPowerBar)
E:OnInit(ReparentAltPowerBar)