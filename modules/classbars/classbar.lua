local E = AleaUI
local CBF = E:Module("ClassBars")

local class1, class2
local currentSpec

local config = {
	['PRIEST'] = {
		[1] = { enable = false, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[2] = { enable = false, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[3] = { enable = true,  texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
	},
	['DRUID'] = {
		[1] = { 
			enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10, visability = 1, 
			enableLunar = true, textureLunar = E.media.default_bar_texture_name3, widthLunar = 200, heightLunar = 10,
		},
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10, visability = 1 },
		[3] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10, visability = 1 },
		[4] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10, visability = 1 },
	},
	['ROGUE'] = {
		[1] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10, visability = 1 },
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10, visability = 1 },
		[3] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10, visability = 1 },
	},
	['PALADIN'] = {
		[1] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10},
		[3] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
	},
	['WARLOCK'] = {
		[1] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[3] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },	
	},
	['MONK'] = {
		[1] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[3] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },	
	},
	['SHAMAN'] = {
		[1] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[3] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },	
	},
	['DEATHKNIGHT'] = {
		[1] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[3] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
	},
	['MAGE'] = {
		[1] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[3] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
	},
	['DEMONHUNTER'] = {
		[1] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
		[2] = { enable = true, texture = E.media.default_bar_texture_name3, width = 200, height = 10 },
	}
}

E.default_settings.classBars = config

local function ClassBarUpdate(f, unit)
	class1, class2 = UnitClass("player")
	currentSpec = GetSpecialization()
	
	if currentSpec and currentSpec > 0 then
	--	print(currentSpec)
		CBF:Activate(class2, currentSpec)
	end
end

CBF.ClassBarUpdate = ClassBarUpdate

function CBF:GetCurrentSpec()
	return currentSpec
end

function CBF:AddClassBar(class, spec, func)
	if not self.Exists then self.Exists = {} end
	if not self.Exists[class] then self.Exists[class] = {} end
	if not self.Exists[class][spec] then self.Exists[class][spec] = {} end
	
	self.Exists[class][spec][#self.Exists[class][spec]+1] = func
end

local function OnEvent(self, event, ...)
	self[event](self, event, ...)
end

function CBF:Activate(class, spec)
	spec = spec or "any"
	if not self.Exists then self.Exists = {} end
	if not self.Exists[class] then self.Exists[class] = {} end
	if not self.Done then self.Done = {} end	
	if not self.Done[class] then self.Done[class] = {} end	
	if not self.Done[class][spec] then
		self.Done[class][spec] = {}
		
		if self.Exists[class][spec] then
			for i=1, #self.Exists[class][spec] do
				local bar = self.Exists[class][spec][i] and self.Exists[class][spec][i]() or nil
				
				if bar then
					bar.Register = bar.Register or function(self)
						for k, v in pairs(self.eventlist) do
							if v ~= "" then
								self:RegisterUnitEvent(k, v, '')
							else
								self:RegisterEvent(k)
							end
						end
						
						if self.Update then
							self:Update()
						end
						
						self:SetScript("OnEvent", OnEvent)
							
						self:Show()
					end
					
					bar.Enable = bar.Enable or function(self)
						self:Register()
					end
					
					bar.Disable = bar.Disable or function(self)
						self:UnregisterAllEvents()
						self:Hide()
					end
					
					self.Done[class][spec][#self.Done[class][spec]+1] = bar
				end
			end
		end
	end
	
	if self.CurrentAcive ~= spec then
		if self.CurrentAcive then		
			for i=1, #self.Done[class][self.CurrentAcive] do
				self.Done[class][self.CurrentAcive][i]:Disable()
			end
		end
		
		if self.Done[class][spec] then
			self.CurrentAcive = spec	
	
			for i=1, #self.Done[class][spec] do
				if self.Done[class][spec][i] then
					self.Done[class][spec][i]:Enable()
				end
			end
		else
			self.CurrentAcive = nil
		end
	end
	
	if self.Done[class] and self.Done[class][spec] then
		for i=1, #self.Done[class][spec] do
			if self.Done[class][spec][i].EnableState then
				if self.Done[class][spec][i]:EnableState() then
					self.Done[class][spec][i]:Enable()
				else
					self.Done[class][spec][i]:Disable()
				end
			elseif E.db.classBars[class][spec].enable then
				self.Done[class][spec][i]:Enable()
			else
				self.Done[class][spec][i]:Disable()
			end
		end
	end
end

function CBF:GetOptions(value)
	local spec = GetSpecialization()
	local _, class = UnitClass("player")
	
	if value then
		return E.db.classBars[class][spec][value]
	end
	
	return E.db.classBars[class][spec]
end

function CBF:SetOptions(value, arg)
	local spec = GetSpecialization()
	local _, class = UnitClass("player")
	
	E.db.classBars[class][spec][value] = arg
end

local function InitClassBars()
	local classBarUpdate = CreateFrame("Frame")
	classBarUpdate:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player",'')
	classBarUpdate:RegisterEvent("PLAYER_TALENT_UPDATE")
	classBarUpdate:RegisterEvent("PLAYER_LEVEL_UP")
	classBarUpdate:SetScript("OnEvent", ClassBarUpdate)
	
	E.GUI.args.unitframes.args.classBars = {
		name = E.L['Class bar'],
		order = 20,
		expand = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.unitframes.args.classBars.args.Enable = {
		name = E.L['Enable'],
		order = 1,
		type = "toggle",
		set = function(me, value)
			
			E.db.classBars[class2][currentSpec].enable = not E.db.classBars[class2][currentSpec].enable
			
			ClassBarUpdate()
		end,
		get = function(me)
			return E.db.classBars[class2][currentSpec].enable
		end
	}
	
	ClassBarUpdate()
end

E:OnInit2(InitClassBars)