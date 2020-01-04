local E = AleaUI
if not E.IsClass("SHAMAN") then return end

local CBF = E:Module("ClassBars")


local w, h = 50, 10
local maxw, maxh = 200, 10

local color = { RAID_CLASS_COLORS["SHAMAN"].r, RAID_CLASS_COLORS["SHAMAN"].g, RAID_CLASS_COLORS["SHAMAN"].b, 1 }

local maelStormFrame

local function MaelstromBar()

	if not maelStormFrame then
	
		local f = CreateFrame("Frame", nil, E.UIParent)
		E:Mover(f, "maelstromFrame")
		
		f.orbs = {}
		f.eventlist = {
			["UNIT_POWER_FREQUENT"]		= "player",
			["UNIT_DISPLAYPOWER"]		= "player",
			}
		
		f:SetSize(maxw, 10)
			
		local o = CreateFrame("StatusBar", nil, f)
		o:SetFrameLevel(f:GetFrameLevel()+1)
		o:SetSize(maxw, maxh)
		o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
		o:SetPoint("LEFT", f, "LEFT", 0, 0)
		o:SetStatusBarColor(color[1]*1.3,color[2]*1.3,color[3]*1.3, 1)
		o:SetMinMaxValues(0, 100)
		
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
		
		f.bar = o

		
		function f:UNIT_POWER_FREQUENT(event, unit, powerType)	
			if unit ~= 'player' then return end

			local value = UnitPower('player', E.PowerType.Maelstrom)
			local maxValue = UnitPowerMax("player", E.PowerType.Maelstrom);
			
			f.bar:SetValue(value)
			f.bar:SetMinMaxValues(0, 100)
		end
		
		f.UNIT_DISPLAYPOWER = f.UNIT_POWER_FREQUENT
		f.PLAYER_REGEN_ENABLED = f.PLAYER_REGEN_ENABLED
		
		function f:UpdateStyle()
			local opts = CBF:GetOptions()
			f:SetSize(opts.width, opts.height)
			f.bar:SetSize(opts.width, opts.height)
			f.bar:SetStatusBarTexture(E:GetTexture(opts.texture))
		end
		
		f.Update = function(self)
			self:UNIT_POWER_FREQUENT(_, "player")
			f:UpdateStyle()
		end
		
		f:Update()
		
		E.GUI.args.unitframes.args.classBars.args.unlock = {
			name = E.L['Unlock'],
			order = 2,
			type = "execute",
			set = function(self, value)
				E:UnlockMover("maelstromFrame") 
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
		
		maelStormFrame = f
	end
	
	return maelStormFrame
end

CBF:AddClassBar('SHAMAN', 1, MaelstromBar)
CBF:AddClassBar('SHAMAN', 2, MaelstromBar)