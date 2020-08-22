local addonName, E = ...

if not E.IsClass("WARLOCK") then return end

local CBF = E:Module("ClassBars")
local class = "WARLOCK"

local w, h = 50, 10
local maxw, maxh = 200, 10

local NUM_SOUL_SHARDS = E.IsLegion and 5 or 4
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local GetSpecialization = GetSpecialization
local UnitPower = UnitPower
local UnitPowerDisplayMod = UnitPowerDisplayMod
local math_floor = math.floor

local color = { RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, 1 }

local soulShardFrame

local function SouldShards()
	if not soulShardFrame then
	
		local f = CreateFrame("Frame", nil, E.UIParent)
		E:Mover(f, "soulshardFrame")
		
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
		o:SetStatusBarColor(unpack(color))
		o:SetMinMaxValues(0, NUM_SOUL_SHARDS*( E.IsLegion and 1 or 100 ) )
		
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
		
		f.bar.separators = {}
		
		for i=1, NUM_SOUL_SHARDS-1 do
			local s = f.bar:CreateTexture()
			s:SetDrawLayer('ARTWORK', 1)
			s:SetSize(1, maxh)
			s:SetColorTexture(0,0,0,1)
			s:SetPoint('LEFT', f.bar, 'LEFT', maxw/NUM_SOUL_SHARDS*i, 0)
			
			f.bar.separators[i] = s
		end
		
		function f:UNIT_POWER_FREQUENT(event, unit, powerType)	
		
			if("player" ~= unit or (powerType and powerType ~= E.PowerTypeString.SoulShards)) then return end
			
			local numShards = 0
			
			if GetSpecialization() == SPEC_WARLOCK_DESTRUCTION then
				local shardPower = UnitPower("player", E.PowerType.SoulShards, true);
				local shardModifier = UnitPowerDisplayMod(E.PowerType.SoulShards);
				
				numShards = (shardModifier ~= 0) and (shardPower / shardModifier) or 0;
			else
			
				numShards = UnitPower("player", E.PowerType.SoulShards)
			end
	
			f.bar:SetValue(numShards)
		end
		
		f.UNIT_DISPLAYPOWER = f.UNIT_POWER_FREQUENT
		f.PLAYER_REGEN_ENABLED = f.PLAYER_REGEN_ENABLED
		
		function f:UpdateStyle()
			local opts = CBF:GetOptions()
			
			f:SetSize(opts.width, opts.height)
			
			f.bar:SetSize(opts.width, opts.height)
			f.bar:SetStatusBarTexture(E:GetTexture(opts.texture))
			
			for i=1, #f.bar.separators do
				f.bar.separators[i]:SetPoint('LEFT', f.bar, 'LEFT', opts.width/NUM_SOUL_SHARDS*i, 0)
				f.bar.separators[i]:SetSize(1, opts.height)
			end
			
			E:Mover(f, "soulshardFrame")
		end
		
		f.Update = function(self)
			self:UNIT_POWER_FREQUENT(_, "player", E.PowerTypeString.SoulShards)
			f:UpdateStyle()
		end
		
		f:Update()
		
		E.GUI.args.unitframes.args.classBars.args.unlock = {
			name = E.L['Unlock'],
			order = 2,
			type = "execute",
			set = function(self, value)
				E:UnlockMover("soulshardFrame") 
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
		
		soulShardFrame = f
	end
	
	return soulShardFrame
end

CBF:AddClassBar(class, 1, SouldShards)
CBF:AddClassBar(class, 2, SouldShards)
CBF:AddClassBar(class, 3, SouldShards)