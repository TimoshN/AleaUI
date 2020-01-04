local E = AleaUI
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "DEATHKNIGHT" then return end

local w, h = 50, 10
local maxw, maxh = 200, 10

local NUM_RUNES = 6

local color_def = { 
	[1] = { 181/255, 0, 0, 1},
	[2] = { 81/255, 179/255, 72/255, 1 },
	[3] = { 0, 181/255, 181/255, 1},
	[4] = { 184/255, 104/255, 209/255, 1 },
 }

local runesRegen = function(self, elapsed)
	for i=1, 6 do
		local start, duration, runeReady = GetRuneCooldown(i);

		if ( start ) then 
			local color = CBF:GetOptions('color') or color_def[4]
			
			self.bars[i]:SetMinMaxValues(start, start+duration)
			self.bars[i]:SetValue(GetTime())
			
			local alpha = 1
			
			if not runeReady then --or ( GetTime() < start+duration ) then
				alpha = 0.5
			end
			
			self.bars[i]:SetStatusBarColor(color[1]*alpha, color[2]*alpha, color[3]*alpha, color[4] or 1)
		else 
			print('EROR IN START TIME', start, duration, runeReady)
		end
	end
end

local runeFrame

local function DK_Runes()

	if not runeFrame then
	
		local f = CreateFrame("Frame", nil, E.UIParent)
		E:Mover(f, "runesFrame")
		f.bars = {}
		f.eventlist = {
		--	["RUNE_POWER_UPDATE"]		= "",
		--	["RUNE_TYPE_UPDATE"]		= "",
			}

		f:SetScript("OnUpdate", runesRegen)
		
		f:SetSize(maxw, 10)
		
		for i=1, NUM_RUNES do

			local o = CreateFrame("StatusBar", nil, f)
			o:SetFrameLevel(f:GetFrameLevel()+1)
			o:SetSize(maxw/NUM_RUNES-1, 10)
			o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
			if i == 1 then
				o:SetPoint("LEFT", f, "LEFT", 0, 0)
			else
				o:SetPoint("LEFT", f.bars[i-1], "RIGHT", 1, 0)
			end
			o:SetStatusBarColor(1,1,1,0.5)
			o:SetMinMaxValues(0,1)
			
			o.art = CreateFrame("Frame", nil, o)
			o.art:SetFrameLevel(o:GetFrameLevel()-1)
			o.art:SetBackdrop({
			  bgFile = [[Interface\Buttons\WHITE8x8]], 
			  edgeFile = [[Interface\Buttons\WHITE8x8]], 
			  edgeSize = 1, 
			})
			o.art:SetBackdropColor(1*0.2,1*0.2,1*0.2, 1)
			o.art:SetBackdropBorderColor(0,0,0,1)
			o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
			o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)

			f.bars[i] = o
		end
		
		function f:RUNE_POWER_UPDATE(runeIndex, isEnergize)
		end

		--f.RUNE_TYPE_UPDATE = f.RUNE_POWER_UPDATE
			
		function f:UpdateStyle()
			local opts = CBF:GetOptions()
			f:SetSize(opts.width, opts.height)

			for i=1, 6 do
				f.bars[i]:SetSize(opts.width/NUM_RUNES-1, opts.height)
				f.bars[i]:SetStatusBarTexture(E:GetTexture(opts.texture))
			end
		end
		
		f.Update = function(self)
			f:UpdateStyle()
		end
		
		f:Update()
		
		E.GUI.args.unitframes.args.classBars.args.unlock = {
			name = E.L['Unlock'],
			order = 2,
			type = "execute",
			set = function(self, value)
				E:UnlockMover("runesFrame") 
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
		
		E.GUI.args.unitframes.args.classBars.args.color = {
			name = E.L['Color'],
			order = 6,
			type = "color",
			set = function(self, r,g,b,a)
				local color = { r, g, b, a }		
				CBF:SetOptions('color', color)
				f:UpdateStyle()
			end,
			get = function(self)
				local color = CBF:GetOptions('color') or color_def[4]
				return color[1], color[2], color[3], color[4]
			end
		}
		
		runeFrame = f
	end
	
	return runeFrame
end



CBF:AddClassBar(class, 1, DK_Runes)
CBF:AddClassBar(class, 2, DK_Runes)
CBF:AddClassBar(class, 3, DK_Runes)