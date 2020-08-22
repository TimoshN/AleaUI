local E = AleaUI
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "DRUID" and class ~= "ROGUE" then return end

local w, h = 50, 10
local maxw, maxh = 200, 10

local NUM_COMBO = 8

local color = { 
	[1] = { 255/255, 213/255, 0, 1},
	[2] = { 255/255, 213/255, 0, 1},
	[3] = { 255/255, 171/255, 0, 1},
	[4] = { 255/255, 171/255, 0, 1},
	[5] = { 255/255, 107/255, 0, 1},
	[6] = { 255/255, 107/255, 0, 1},
	[7] = { 255/255, 107/255, 0, 1},
	[8] = { 255/255, 107/255, 0, 1},	
 }

 local comboFrame

local function ComboBar()
	
	if not comboFrame then
		
		local f = CreateFrame("Frame", nil, E.UIParent)
		E:Mover(f, "combopointFrame")

		f.eventlist = {
			["UNIT_POWER_FREQUENT"]		= "player",
		--	["UNIT_COMBO_POINTS"]		= "",
			["PLAYER_TARGET_CHANGED"]   = "",

			["PLAYER_ENTERING_WORLD"]	= '',
			["UPDATE_SHAPESHIFT_FORM"]	= '',
			["PLAYER_TALENT_UPDATE"]	= '',
		
		}

		f:Show()
		f:EnableMouse(false)
		
		f:SetSize(maxw, maxh)
		
		local o = CreateFrame("StatusBar", nil, f)
		o:SetParent(f)
		o:SetFrameLevel(f:GetFrameLevel()+1)
		o:SetSize(maxw, maxh)
		o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
		o:SetPoint("LEFT", f, "LEFT", 0, 0)
		o:SetStatusBarColor(unpack(color[1]))
		o:SetMinMaxValues(0,NUM_COMBO)
		o:GetStatusBarTexture():SetDrawLayer('ARTWORK', -2)
		
		o.art = CreateFrame("Frame", nil, o, BackdropTemplateMixin and 'BackdropTemplate')
		o.art:SetFrameLevel(o:GetFrameLevel()-1)
		o.art:SetBackdrop({
		  bgFile = [[Interface\Buttons\WHITE8x8]], 
		  edgeFile = [[Interface\Buttons\WHITE8x8]], 
		  edgeSize = 1, 
		})
		o.art:SetBackdropColor(color[1][1]*0.4,color[1][2]*0.4,color[1][3]*0.4, 1)
		o.art:SetBackdropBorderColor(0,0,0,1)
		o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
		o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)
		
		local overlay = o:CreateTexture()
			overlay:SetDrawLayer('ARTWORK', -1)
			overlay:SetSize(1, maxh)
			overlay:SetColorTexture(1,0.1,0.1,0.3)
			overlay:SetPoint('TOP', o, 'TOP', 0, 0)
			overlay:SetPoint('BOTTOM', o, 'BOTTOM', 0, 0)
			overlay:SetPoint('LEFT', o, 'LEFT', 0, 0)
			overlay:SetPoint('RIGHT', o, 'RIGHT', 0, 0)
			
		f.bar = o
		f.overlay = overlay
		
		f.bar.separators = {}
		
		for i=1, NUM_COMBO-1 do
			local s = f.bar:CreateTexture()
			s:SetDrawLayer('ARTWORK', 1)
			s:SetSize(1, maxh)
			s:SetColorTexture(0,0,0,1)
			s:SetPoint('TOP', f.bar, 'TOP', 0, 0)
			s:SetPoint('BOTTOM', f.bar, 'BOTTOM', 0, 0)
			s:SetPoint('LEFT', f.bar, 'LEFT', maxw/NUM_COMBO*i, 0)
			
			f.bar.separators[i] = s
		end
		
		local lastMaxCombo = -1
		
		function f:UNIT_COMBO_POINTS(event, unit)
			local number = UnitPower("player", E.PowerType.ComboPoints)
			local maxCombo = UnitPowerMax("player", E.PowerType.ComboPoints)
			
			if CBF:GetOptions('visability') == 1 then
				if not f.bar:IsShown() then
					f.bar:Show()
				end
			elseif CBF:GetOptions('visability') then
				if UnitExists('target') then
					if not f.bar:IsShown() then
						f.bar:Show()
					end
				else
					if f.bar:IsShown() then
						f.bar:Hide()
					end
				end
			end
			
			if class == 'DRUID' then
				local form  = GetShapeshiftFormID();
				
				if form == CAT_FORM then
					self:Show()
				else
					self:Hide()
				end
			end
			
			if maxCombo == 0 then return end
			
			if lastMaxCombo ~= maxCombo then
				lastMaxCombo = maxCombo
				
				local width = f.bar:GetWidth()/lastMaxCombo
				
				if lastMaxCombo == 10 then
					f.overlay:Show()
					f.overlay:SetPoint('LEFT', f.bar, 'LEFT', width*5, 0)
					f.bar.art:SetBackdropColor(color[1][1]*0.2,color[1][2]*0.2,color[1][3]*0.2, 1)
				else
					f.overlay:Hide()
				end
				
				for i=1, lastMaxCombo-1 do
				
					if not f.bar.separators[i] then
						local s = f.bar:CreateTexture()
						s:SetDrawLayer('ARTWORK', 1)
						s:SetPoint('TOP', f.bar, 'TOP', 0, 0)
						s:SetPoint('BOTTOM', f.bar, 'BOTTOM', 0, 0)
						s:SetColorTexture(0,0,0,1)
	
						f.bar.separators[i] = s
					end
					
					f.bar.separators[i]:SetPoint('LEFT', f.bar, 'LEFT', width*i, 0)
					f.bar.separators[i]:Show()
				end
				
				for i=lastMaxCombo, #f.bar.separators do
					f.bar.separators[i]:Hide()
				end
				
				f:UpdateStyle()
			end
			
			f.bar:SetMinMaxValues(0, maxCombo)
			f.bar:SetValue(number)
		end

		f.PLAYER_TARGET_CHANGED = f.UNIT_COMBO_POINTS
		f.UNIT_POWER_FREQUENT = f.UNIT_COMBO_POINTS
		
		function f:PLAYER_ENTERING_WORLD()	
			f:UNIT_COMBO_POINTS(event, unit)
		end
		
		f.UPDATE_SHAPESHIFT_FORM = f.PLAYER_ENTERING_WORLD
		f.PLAYER_TALENT_UPDATE = f.PLAYER_ENTERING_WORLD

		function f:UpdateStyle()
			local opts = CBF:GetOptions()
			f:SetSize(opts.width, opts.height)
			
			f.bar:SetSize(opts.width, opts.height)
			f.bar:SetStatusBarTexture(E:GetTexture(opts.texture))
			
			local combos  = UnitPowerMax("player", E.PowerType.ComboPoints)
			if combos == 0 then return end
			
			local width = f.bar:GetWidth()/combos
			
			if combos == 10 then
				f.overlay:Show()
				f.overlay:SetPoint('LEFT', f.bar, 'LEFT', width*5, 0)
				f.bar.art:SetBackdropColor(color[1][1]*0.2,color[1][2]*0.2,color[1][3]*0.2, 1)
			else
				f.overlay:Hide()
			end
				
			for i=1, combos-1 do
				if not f.bar.separators[i] then
					local s = f.bar:CreateTexture()
					s:SetDrawLayer('ARTWORK', 1)
					s:SetPoint('TOP', f.bar, 'TOP', 0, 0)
					s:SetPoint('BOTTOM', f.bar, 'BOTTOM', 0, 0)
					s:SetColorTexture(0,0,0,1)

					f.bar.separators[i] = s
				end
				
				f.bar.separators[i]:SetPoint('LEFT', f.bar, 'LEFT', width*i, 0)
				f.bar.separators[i]:Show()
			end
			
			for i=combos, #f.bar.separators do
				f.bar.separators[i]:Hide()
			end
				
			for i=1, #f.bar.separators do
				f.bar.separators[i]:SetSize(1, opts.height)
			end
		end
		
		
		f.Update = function(self)	
			self:PLAYER_TARGET_CHANGED()	
			self:PLAYER_TALENT_UPDATE()
			f:UpdateStyle()
		end
		
		f:Update()

		E.GUI.args.unitframes.args.classBars.args.ComboBar = {
			name = E.L['Combo points'],
			order = 1,
			type = 'group',
			embend = true,
			args = {},
		}
		
		E.GUI.args.unitframes.args.classBars.args.ComboBar.args.Enable = {
			name = E.L['Enable'],
			order = 1,
			type = "toggle",
			set = function(me, value)
				CBF:SetOptions('enable', not CBF:GetOptions('enable') )				
				CBF.ClassBarUpdate()
			end,
			get = function(me)
				return CBF:GetOptions('enable')
			end
		}
		
		E.GUI.args.unitframes.args.classBars.args.ComboBar.args.unlock = {
			name = E.L['Unlock'],
			order = 2,
			type = "execute",
			set = function(self, value)
				E:UnlockMover("combopointFrame") 
			end,
			get = function(self)end
		}
		
		E.GUI.args.unitframes.args.classBars.args.ComboBar.args.width = {
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
		
		E.GUI.args.unitframes.args.classBars.args.ComboBar.args.height = {
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
		
		E.GUI.args.unitframes.args.classBars.args.ComboBar.args.texture = {
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
		
		E.GUI.args.unitframes.args.classBars.args.ComboBar.args.visability = {
			order = 5,
			type = 'dropdown',
			name = E.L['Visability'],
			values = {
				E.L['Always'],
				E.L['Target exists'],
			},
			set = function(info,value) 
				CBF:SetOptions('visability', value)
				f:UpdateStyle()
			end,
			get = function(info) 
				return CBF:GetOptions('visability')
			end,
		}
		comboFrame = f
		
	end
	
	E.GUI.args.unitframes.args.classBars.args.Enable = nil
	
	return comboFrame
end



CBF:AddClassBar(class, 1, ComboBar)
CBF:AddClassBar(class, 2, ComboBar)
CBF:AddClassBar(class, 3, ComboBar)

if class == "DRUID" then
	CBF:AddClassBar(class, 4, ComboBar)
end