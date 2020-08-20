local E = AleaUI
local Skins = E:Module("Skins")
local AB = E:Module('ActionBars')
local BF = E:Module('ButtonForge')
local L = E.L

local _G = _G
local type, error, tostring, tonumber, assert, select = type, error, tostring, tonumber, assert, select
local setmetatable, wipe, unpack, pairs, next = setmetatable, wipe, unpack, pairs, next
local str_match, format, tinsert, tremove = string.match, format, tinsert, tremove
local gsub = string.gsub
local split = string.split
local ceil = math.ceil;
local ceil = math.ceil;
local lower = string.lower;

local CooldownFrame_SetTimer = CooldownFrame_Set or CooldownFrame_SetTimer

local DD_points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
}

local options = {
	['font'] = E.media.default_font_name,
	['fontSize'] = 10,
	['fontOutline'] = 'OUTLINE',

	["macrotext"] = true,
	["hotkeytext"] = true,
	['showGrid'] = true,

	['noRangeColor'] = { r = 0.8, g = 0.1, b = 0.1 },
	['noPowerColor'] = { r = 0.5, g = 0.5, b = 1 },

	['keyDown'] = false,
	['movementModifier'] = 'SHIFT',
	['swipeTexture'] = 1,	
	['microbar'] = {
		['enabled'] = false,
		['mouseover'] = false,
		['buttonsPerRow'] = 12,
		['alpha'] = 1,
	},
	['bar1'] = {
		['enabled'] = true,
		['buttons'] = 12,
		['mouseover'] = false,
		['buttonsPerRow'] = 12,
		['point'] = 'BOTTOMLEFT',
		['backdrop'] = false,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 28,
		["buttonspacing"] = 2,
		['alpha'] = 1,
		['paging'] = {
			["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 7; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
			["PRIEST"] = "[bonusbar:1] 7;",
			["ROGUE"] = "[stance:1] 7;  [stance:2] 7; [stance:3] 7;", -- set to "[stance:1] 7; [stance:3] 10;" if you want a shadow dance bar
			["MONK"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
			["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8;"
		},
		['visibility'] = "[petbattle] hide; show",
		["border"] = {
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
		["artwork"] = {
			['enable'] = false,
			['width'] = 1,
			['height'] = 1,
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
	},
	['bar2'] = {
		['enabled'] = true,
		['mouseover'] = false,
		['buttons'] = 12,
		['buttonsPerRow'] = 12,
		['point'] = 'BOTTOMLEFT',
		['backdrop'] = false,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 28,
		["buttonspacing"] = 2,
		['alpha'] = 1,
		['paging'] = {},
		['visibility'] = "[vehicleui] hide; [overridebar] hide; [petbattle] hide; show",
		["border"] = {
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
		["artwork"] = {
			['enable'] = false,
			['width'] = 1,
			['height'] = 1,
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
	},
	['bar3'] = {
		['enabled'] = true,
		['mouseover'] = false,
		['buttons'] = 12,
		['buttonsPerRow'] = 12,
		['point'] = 'BOTTOMLEFT',
		['backdrop'] = false,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 28,
		["buttonspacing"] = 2,
		['alpha'] = 1,
		['paging'] = {},
		['visibility'] = "[vehicleui] hide; [overridebar] hide; [petbattle] hide; show",
		["border"] = {
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
		["artwork"] = {
			['enable'] = false,
			['width'] = 1,
			['height'] = 1,
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
	},
	['bar4'] = {
		['enabled'] = false,
		['mouseover'] = false,
		['buttons'] = 12,
		['buttonsPerRow'] = 1,
		['point'] = 'TOPRIGHT',
		['backdrop'] = true,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 28,
		["buttonspacing"] = 2,
		['alpha'] = 1,
		['paging'] = {},
		['visibility'] = "[vehicleui] hide; [overridebar] hide; [petbattle] hide; show",
		["border"] = {
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
		["artwork"] = {
			['enable'] = false,
			['width'] = 1,
			['height'] = 1,
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
	},
	['bar5'] = {
		['enabled'] = false,
		['mouseover'] = false,
		['buttons'] = 6,
		['buttonsPerRow'] = 6,
		['point'] = 'BOTTOMLEFT',
		['backdrop'] = false,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 28,
		["buttonspacing"] = 2,
		['alpha'] = 1,
		['paging'] = {},
		['visibility'] = "[vehicleui] hide; [overridebar] hide; [petbattle] hide; show",
		["border"] = {
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
		["artwork"] = {
			['enable'] = false,
			['width'] = 1,
			['height'] = 1,
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
	},
	['bar6'] = {
		['enabled'] = false,
		['mouseover'] = false,
		['buttons'] = 12,
		['buttonsPerRow'] = 12,
		['point'] = 'BOTTOMLEFT',
		['backdrop'] = false,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 28,
		["buttonspacing"] = 2,
		['alpha'] = 1,
		['paging'] = {},
		['visibility'] = "[vehicleui] hide; [overridebar] hide; [petbattle] hide; show",
		["border"] = {
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
		["artwork"] = {
			['enable'] = false,
			['width'] = 1,
			['height'] = 1,
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
	},
	['barPet'] = {
		['enabled'] = true,
		['mouseover'] = false,
		['buttons'] = NUM_PET_ACTION_SLOTS,
		['buttonsPerRow'] = 1,
		['point'] = 'TOPRIGHT',
		['backdrop'] = true,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 28,
		["buttonspacing"] = 2,
		['alpha'] = 1,
		['visibility'] = "[petbattle] hide;[pet,novehicleui,nooverridebar,nopossessbar] show;hide",
		["border"] = {
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
		["artwork"] = {
			['enable'] = false,
			['width'] = 1,
			['height'] = 1,
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
	},
	['stanceBar'] = {
		['enabled'] = true,
		['style'] = 'darkenInactive',
		['mouseover'] = false,
		['buttonsPerRow'] = NUM_STANCE_SLOTS,
		['buttons'] = NUM_STANCE_SLOTS,
		['point'] = 'TOPLEFT',
		['backdrop'] = false,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 28,
		["buttonspacing"] = 2,
		['alpha'] = 1,
		["border"] = {
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
		["artwork"] = {
			['enable'] = false,
			['width'] = 1,
			['height'] = 1,
			["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
				0.6,  
			},
			["texture"] = AleaUI.media.default_bar_texture_name3,
		},
	},
	['extraActionButton'] = {
		['alpha'] = 1,
	},
};

E.default_settings.actionbars = options

local GetVehicleBarIndex = GetVehicleBarIndex
local GetOverrideBarIndex = GetOverrideBarIndex

if (E.isClassic) then 
	GetVehicleBarIndex = function() return 1 end 
	GetOverrideBarIndex = function() return 1 end
end 

AB["handledBars"] = {} --List of all bars
AB["handledbuttons"] = {} --List of all buttons that have been modified.
AB["barDefaults"] = {
	["bar1"] = {
		['page'] = 1,
		['bindButtons'] = "ACTIONBUTTON",
		['conditions'] = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex()),
		['position'] = "BOTTOM,AleaUIParent,BOTTOM,327,5",
	},
	["bar2"] = {
		['page'] = 5,
		['bindButtons'] = "MULTIACTIONBAR2BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,AleaUIParent,BOTTOM,0,32",
	},
	["bar3"] = {
		['page'] = 6,
		['bindButtons'] = "MULTIACTIONBAR1BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,AleaUIParent,BOTTOM,0,59",
	},
	["bar4"] = {
		['page'] = 4,
		['bindButtons'] = "MULTIACTIONBAR4BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,AleaUIParent,BOTTOM,406,234",
	},
	["bar5"] = {
		['page'] = 3,
		['bindButtons'] = "MULTIACTIONBAR3BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,AleaUIParent,BOTTOM,0,85",
	},
	["bar6"] = {
		['page'] = 2,
		['bindButtons'] = "ALEAUIBAR6BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,AleaUI_Bar2,TOP,0,2",
	},
}

AB.customExitButton = {
	func = function(button)
		if UnitExists('vehicle') then
			VehicleExit()
		else
			PetDismiss()
		end
	end,
	texture = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	tooltip = LEAVE_VEHICLE,
}



function AB:PositionAndSizeBar(barName)
	local spacing = E.db.actionbars[barName].buttonspacing --E:Scale();
	local buttonsPerRow = E.db.actionbars[barName].buttonsPerRow;
	local numButtons = E.db.actionbars[barName].buttons;
	local size = E.db.actionbars[barName].buttonsize--  E:Scale();
	local point = E.db.actionbars[barName].point;
	local numColumns = ceil(numButtons / buttonsPerRow);
	local widthMult = E.db.actionbars[barName].widthMult;
	local heightMult = E.db.actionbars[barName].heightMult;
	local bar = self["handledBars"][barName]

	bar.db = E.db.actionbars[barName]
	bar.db.position = nil; --Depreciated

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end

	if numColumns < 1 then
		numColumns = 1;
	end

	bar:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	
	if not bar.artWork then
		bar.artWork = CreateFrame("Frame", nil, bar, BackdropTemplateMixin and 'BackdropTemplate')
		bar.artWork:SetFrameLevel(bar:GetFrameLevel())
		bar.artWork:SetBackdrop({
		  edgeFile = [[Interface\Buttons\WHITE8x8]],
		  edgeSize = 1, 
		})
		bar.artWork:SetBackdropBorderColor(0,0,0,1)
		bar.artWork:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, -0)
		bar.artWork:SetSize(100,100)

		bar.artWork.back = bar:CreateTexture()
		bar.artWork.back:SetDrawLayer('BACKGROUND', -2)
		bar.artWork.back:SetColorTexture(0, 0, 0, 0)
		bar.artWork.back:SetPoint("BOTTOMLEFT", bar.artWork, "BOTTOMLEFT", 0, -0)

		bar.artWork:SetScript('OnEvent', AB.VehicleBarArtWorkVisability)
	end
	
	local opts = E.db.actionbars[barName]
	
	if opts.artwork.enable then
		bar.artWork:SetBackdrop({
		  edgeFile = E:GetBorder(opts.artwork.texture),
		  edgeSize = opts.artwork.size, 
		})
		bar.artWork:SetBackdropBorderColor(opts.artwork.color[1],opts.artwork.color[2],opts.artwork.color[3],opts.artwork.color[4])
		bar.artWork:SetSize(opts.artwork.width, opts.artwork.height)
		bar.artWork:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", opts.artwork.inset, opts.artwork.inset)
		
		bar.artWork.back:SetTexture(E:GetTexture(opts.artwork.background_texture))
		bar.artWork.back:SetVertexColor(opts.artwork.background_color[1],opts.artwork.background_color[2],opts.artwork.background_color[3],opts.artwork.background_color[4])
	--	bar.artWork.back:SetPoint("TOPLEFT", bar.artWork, "TOPLEFT", -opts.artwork.background_inset, opts.artwork.background_inset)
	--	bar.artWork.back:SetPoint("BOTTOMRIGHT", bar.artWork, "BOTTOMRIGHT", opts.artwork.background_inset, -opts.artwork.background_inset)
		bar.artWork.back:SetSize(opts.artwork.width+opts.artwork.background_inset+opts.artwork.background_inset, opts.artwork.height+opts.artwork.background_inset+opts.artwork.background_inset)
		bar.artWork.back:SetPoint("BOTTOMLEFT", bar.artWork, "BOTTOMLEFT", -opts.artwork.background_inset, -opts.artwork.background_inset)
		
		if ( not E.isClassic) then 
		bar.artWork:RegisterEvent('VEHICLE_UPDATE')
		bar.artWork:RegisterEvent('UNIT_ENTERED_VEHICLE')
		bar.artWork:RegisterEvent('UNIT_ENTERING_VEHICLE')
		bar.artWork:RegisterEvent('UNIT_EXITED_VEHICLE')
		bar.artWork:RegisterEvent('UNIT_EXITING_VEHICLE')
		end

		bar.artWork:Show()
		bar.artWork.back:Show()
		
		AB.VehicleBarArtWorkVisability(bar.artWork)
	else
		if ( not E.isClassic) then 
			bar.artWork:UnregisterEvent('VEHICLE_UPDATE')
			bar.artWork:UnregisterEvent('UNIT_ENTERED_VEHICLE')
			bar.artWork:UnregisterEvent('UNIT_ENTERING_VEHICLE')
			bar.artWork:UnregisterEvent('UNIT_EXITED_VEHICLE')
			bar.artWork:UnregisterEvent('UNIT_EXITING_VEHICLE')
		end

		bar.artWork:Hide()
		bar.artWork.back:Hide()
	end
	
	bar.mouseover = E.db.actionbars[barName].mouseover

	if E.db.actionbars[barName].backdrop == true then
	--	bar.backdrop:Show();
	else
	--	bar.backdrop:Hide();
	end

	local horizontalGrowth, verticalGrowth;
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end

	local button, lastButton, lastColumnButton ;
	for i=1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i];
		lastButton = bar.buttons[i-1];
		lastColumnButton = bar.buttons[i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:SetSize(size, size)
		button:SetAttribute("showgrid", 1)
		
		--[[
		if E.db.actionbars[barName].mouseover == true then
			bar:SetAlpha(0);
			if not self.hooks[bar] then
				self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
				self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');
			end

			if not self.hooks[button] then
				self:HookScript(button, 'OnEnter', 'Button_OnEnter');
				self:HookScript(button, 'OnLeave', 'Button_OnLeave');
			end
		else
			bar:SetAlpha(E.db.actionbars[barName].alpha);
			if self.hooks[bar] then
				self:Unhook(bar, 'OnEnter');
				self:Unhook(bar, 'OnLeave');
			end

			if self.hooks[button] then
				self:Unhook(button, 'OnEnter');
				self:Unhook(button, 'OnLeave');
			end
		end
		]]
		if i == 1 then
			local x, y;
			if point == "BOTTOMLEFT" then
				x, y = spacing, spacing;
			elseif point == "TOPRIGHT" then
				x, y = -spacing, -spacing;
			elseif point == "TOPLEFT" then
				x, y = spacing, -spacing;
			else
				x, y = -spacing, spacing;
			end

			button:SetPoint(point, bar, point, x, y);
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0;
			local y = -spacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if verticalGrowth == 'UP' then
				y = spacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:SetPoint(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = spacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if horizontalGrowth == 'LEFT' then
				x = -spacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end

			button:SetPoint(buttonPoint, lastButton, anchorPoint, x, y);
		end
		
		local minVihicleExit = 7
		
		for i=7, 11 do
			bar.buttons[i]:SetState(12, "empty")
		end
			
		if numButtons < 12 then
			
			local exitButton = max(numButtons, minVihicleExit)
			
			bar.buttons[exitButton]:SetState(12, "custom", AB.customExitButton)	
		end
		
		if i > numButtons then
			button:Hide()
		else
			button:Show()
		end

		
		self:StyleButton(button, nil, nil, true);
		button:SetCheckedTexture("")
		
	--	local opts = E.db.actionbars[barName]
		
		button.artBorder.r = opts.border.color[1]
		button.artBorder.g = opts.border.color[2]
		button.artBorder.b = opts.border.color[3]
		button.artBorder.a = opts.border.color[4]
		
		button.artBorder:SetBackdrop({
		  edgeFile = E:GetBorder(opts.border.texture),
		  edgeSize = opts.border.size, 
		})
		button.artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
		button.artBorder:SetPoint("TOPLEFT", button._point, "TOPLEFT", opts.border.inset, -opts.border.inset)
		button.artBorder:SetPoint("BOTTOMRIGHT", button._point, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

		button.artBorder.back:SetTexture(E:GetTexture(opts.border.background_texture))
		button.artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
		button.artBorder.back:SetPoint("TOPLEFT", button._point, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
		button.artBorder.back:SetPoint("BOTTOMRIGHT", button._point, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
		
		
	--	print('Update Bar', barName, opts, E:GetBorder(opts.border.texture))
	end

	if E.db.actionbars[barName].enabled or not bar.initialized then
		if not E.db.actionbars[barName].mouseover then
			bar:SetAlpha(E.db.actionbars[barName].alpha);
		end

		local page = self:GetPage(barName, self['barDefaults'][barName].page, self['barDefaults'][barName].conditions)
		if AB['barDefaults']['bar'..bar.id].conditions:find("[form,noform]") then
			bar:SetAttribute("hasTempBar", true)

			local newCondition = page
			newCondition = gsub(AB['barDefaults']['bar'..bar.id].conditions, " %[form,noform%] 0; ", "")
			bar:SetAttribute("newCondition", newCondition)
		else
			bar:SetAttribute("hasTempBar", false)
		end

		bar:Show()
		RegisterStateDriver(bar, "visibility", E.db.actionbars[barName].visibility); -- this is ghetto
		RegisterStateDriver(bar, "page", page);
		bar:SetFrameRef("MainMenuBarArtFrame", MainMenuBarArtFrame)

		if barName == 'bar1' then
			RegisterStateDriver(bar, "overridebarFix", "[overridebar] true;false")
			bar:SetAttribute("_onstate-overridebarFix", [[
				--print('overridebarFix', newstate, HasOverrideActionBar(), GetOverrideBarIndex())

				if ( HasOverrideActionBar() ) then 
					local index = GetOverrideBarIndex()
					self:SetAttribute("state", index)
					self:ChildUpdate("state", index)
					self:GetFrameRef("MainMenuBarArtFrame"):SetAttribute("actionpage", index)
				end
			]])	
		end 

		if not bar.initialized then
			bar.initialized = true;
			AB:PositionAndSizeBar(barName)
			return
		end
	else
		bar:Hide()
		UnregisterStateDriver(bar, "visibility");
	end


--	E:SetMoverSnapOffset('AleaAB_'..bar.id, bar.db.buttonspacing / 2)

end

function AB:CreateBar(id)
	local bar = CreateFrame('Frame', 'AleaUI_Bar'..id, E.UIParent, 'SecureHandlerStateTemplate');
	local point, anchor, attachTo, x, y = split(',', self['barDefaults']['bar'..id].position)
	bar:SetPoint(point, anchor, attachTo, x, y)
	bar.id = id
--	bar:CreateBackdrop('Default');
	bar:SetFrameStrata("LOW")
--	bar.backdrop:SetAllPoints();
	bar.buttons = {}
	bar.bindButtons = self['barDefaults']['bar'..id].bindButtons

	for i=1, 12 do
		bar.buttons[i] = BF:CreateButton(i, format(bar:GetName().."Button%d", i), bar, nil)
		E:RegisterCooldown(bar.buttons[i].cooldown)
		
		bar.buttons[i]:SetState(0, "action", i)
		for k = 1, 14 do
			bar.buttons[i]:SetState(k, "action", (k - 1) * 12 + i)
		end

		if i == 12 then
			bar.buttons[i]:SetState(12, "custom", AB.customExitButton)
		end
	end
	self:UpdateButtonConfig(bar, bar.bindButtons)

	if AB['barDefaults']['bar'..id].conditions:find("[form]") then
		bar:SetAttribute("hasTempBar", true)
	else
		bar:SetAttribute("hasTempBar", false)
	end

	bar:SetAttribute("_onstate-page", [[
		if HasTempShapeshiftActionBar() and self:GetAttribute("hasTempBar") then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end

		if newstate ~= 0 then
			self:SetAttribute("state", newstate)
			control:ChildUpdate("state", newstate)
		else
			local newCondition = self:GetAttribute("newCondition")
			if newCondition then
				newstate = SecureCmdOptionParse(newCondition)
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			end
		end
	]]);


	self["handledBars"]['bar'..id] = bar;
	self:PositionAndSizeBar('bar'..id);
--	E:CreateMover(bar, 'ElvAB_'..id, "Bar "..id, nil, nil, nil,'ALL,ACTIONBARS')

	
	E:Mover(bar, 'AleaAB_'..bar.id)
	
	E.numActonBars = ( E.numActonBars or 0 ) + 1
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id] = {
		name = L['ActionBar']..bar.id,
		order = E.numActonBars,
		expand = true,
		type = "group",
		args = {}
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.unlock = {
		name = L["Unlock"],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover('AleaAB_'..bar.id) 
		end,
		get = function(self)end
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.enabled = {
		name = L["Enable"],
		order = 1.1,
		type = "toggle",
		set = function(self, value)
			E.db.actionbars['bar'..id].enabled = not E.db.actionbars['bar'..id].enabled
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(self)
			return E.db.actionbars['bar'..id].enabled
		end
	}
	
	--[[
	
		['enabled'] = true,
		['buttons'] = 12,
		['mouseover'] = false,
		['buttonsPerRow'] = 12,
		['point'] = 'BOTTOMLEFT',
		['backdrop'] = false,
		['heightMult'] = 1,
		['widthMult'] = 1,
		["buttonsize"] = 32,
		["buttonspacing"] = 2,
		['alpha'] = 1,
	]]
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.buttons = {
		name = L["Buttons"],
		order = 3,
		type = "slider",
		min = 1, max = 12, step = 1,
		set = function(self, value)
			E.db.actionbars['bar'..id].buttons = value
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(self) 
			return E.db.actionbars['bar'..id].buttons
		end
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.perrow = {
		name = L["Per row"],
		order = 3.1,
		type = "slider",
		min = 1, max = 12, step = 1,
		set = function(self, value)
			E.db.actionbars['bar'..id].buttonsPerRow = value
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(self) 
			return E.db.actionbars['bar'..id].buttonsPerRow
		end
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.size = {
		name = L["Size"],
		order = 4,
		type = "slider",
		min = 1, max = 60, step = 1,
		set = function(self, value)
			E.db.actionbars['bar'..id].buttonsize = value
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(self) 
			return E.db.actionbars['bar'..id].buttonsize
		end
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.spacing = {
		name = L["Spacing"],
		order = 6,
		type = "slider",
		min = 0, max = 60, step = 1,
		set = function(self, value)
			E.db.actionbars['bar'..id].buttonspacing = value
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(self) 
			return E.db.actionbars['bar'..id].buttonspacing
		end
	}
	
		
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.point = {
		name = L["Point"],
		type = "dropdown",
		order = 7,
		values = DD_points,
		set = function(self, value)
			E.db.actionbars['bar'..id].point = value
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(self)
			return E.db.actionbars['bar'..id].point
		end,	
	}
	
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.BorderOpts = {
		name = L["Borders"],
		order = 10,
		embend = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.BorderOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L["Border texture"],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.actionbars['bar'..id].border.texture = value;
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info) return E.db.actionbars['bar'..id].border.texture end,
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.BorderOpts.args.BorderColor = {
		order = 2,
		name = L["Border color"],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.actionbars['bar'..id].border.color={ r, g, b, a}; 
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info) 
			return E.db.actionbars['bar'..id].border.color[1],
					E.db.actionbars['bar'..id].border.color[2],
					E.db.actionbars['bar'..id].border.color[3],
					E.db.actionbars['bar'..id].border.color[4] 
		end,
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.BorderOpts.args.BorderSize = {
		name = L['Border width'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['bar'..id].border.size = val
			AB:PositionAndSizeBar('bar'..id);
		end,
		get =function(info)
			return E.db.actionbars['bar'..id].border.size
		end,
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.BorderOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['bar'..id].border.inset = val
			AB:PositionAndSizeBar('bar'..id);
		end,
		get =function(info)
			return E.db.actionbars['bar'..id].border.inset
		end,
	}


	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.BorderOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L["Background texture"],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.actionbars['bar'..id].border.background_texture = value;
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info) return E.db.actionbars['bar'..id].border.background_texture end,
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.BorderOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.actionbars['bar'..id].border.background_color={ r, g, b, a}
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info) 
			return E.db.actionbars['bar'..id].border.background_color[1],
					E.db.actionbars['bar'..id].border.background_color[2],
					E.db.actionbars['bar'..id].border.background_color[3],
					E.db.actionbars['bar'..id].border.background_color[4] 
		end,
	}


	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.BorderOpts.args.backgroundInset = {
		name = L['Background offset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['bar'..id].border.background_inset = val
			AB:PositionAndSizeBar('bar'..id);
		end,
		get =function(info)
			return E.db.actionbars['bar'..id].border.background_inset
		end,
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts = {
		name = L['Artwork'],
		order = 11,
		embend = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.Enable = {
		name = L['Enable'],
		type = 'toggle',
		order = 0.1,
		width = 'full',
		set = function(info)
			E.db.actionbars['bar'..id].artwork.enable = not E.db.actionbars['bar'..id].artwork.enable
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info)
			return E.db.actionbars['bar'..id].artwork.enable
		end,	
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.Width = {
		name = L['Width'],
		type = "slider",
		order	= 0.2,
		min		= 1,
		max		= 500,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['bar'..id].artwork.width = val
			AB:PositionAndSizeBar('bar'..id);
		end,
		get =function(info)
			return E.db.actionbars['bar'..id].artwork.width
		end,
	}
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.Height = {
		name = L['Height'],
		type = "slider",
		order	= 0.3,
		min		= 1,
		max		= 500,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['bar'..id].artwork.height = val
			AB:PositionAndSizeBar('bar'..id);
		end,
		get =function(info)
			return E.db.actionbars['bar'..id].artwork.height
		end,
	}
	
	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L["Border texture"],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.actionbars['bar'..id].artwork.texture = value;
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info) return E.db.actionbars['bar'..id].artwork.texture end,
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.actionbars['bar'..id].artwork.color={ r, g, b, a}; 
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info) 
			return E.db.actionbars['bar'..id].artwork.color[1],
					E.db.actionbars['bar'..id].artwork.color[2],
					E.db.actionbars['bar'..id].artwork.color[3],
					E.db.actionbars['bar'..id].artwork.color[4] 
		end,
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['bar'..id].artwork.size = val
			AB:PositionAndSizeBar('bar'..id);
		end,
		get =function(info)
			return E.db.actionbars['bar'..id].artwork.size
		end,
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['bar'..id].artwork.inset = val
			AB:PositionAndSizeBar('bar'..id);
		end,
		get =function(info)
			return E.db.actionbars['bar'..id].artwork.inset
		end,
	}


	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Background texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.actionbars['bar'..id].artwork.background_texture = value;
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info) return E.db.actionbars['bar'..id].artwork.background_texture end,
	}

	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.actionbars['bar'..id].artwork.background_color={ r, g, b, a}
			AB:PositionAndSizeBar('bar'..id);
		end,
		get = function(info) 
			return E.db.actionbars['bar'..id].artwork.background_color[1],
					E.db.actionbars['bar'..id].artwork.background_color[2],
					E.db.actionbars['bar'..id].artwork.background_color[3],
					E.db.actionbars['bar'..id].artwork.background_color[4] 
		end,
	}


	E.GUI.args.actionbars.args['ActionBar'..bar.id].args.ArtWorkOpts.args.backgroundInset = {
		name = L['Background offset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['bar'..id].artwork.background_inset = val
			AB:PositionAndSizeBar('bar'..id);
		end,
		get =function(info)
			return E.db.actionbars['bar'..id].artwork.background_inset
		end,
	}
	
	return bar
end

function AB:PLAYER_REGEN_ENABLED()
	self:UpdateButtonSettings()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

local function Vehicle_OnEvent(self, event)
	if ( CanExitVehicle() and ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN ) then
		self:Show()
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		self:EnableMouse(true)
	else
		self:Hide()
	end
end

local function Vehicle_OnClick(self)
	if ( UnitOnTaxi("player") ) then
		TaxiRequestEarlyLanding();
		self:GetNormalTexture():SetVertexColor(1, 0, 0)
		self:EnableMouse(false)
	else
		VehicleExit();
	end
end

function AB:UpdateVehicleLeave()
	local button = LeaveVehicleButton
	if not button then return; end
	
	local pos = "BOTTOMLEFT" --E.db.general.minimap.icons.vehicleLeave.position or
	local size = 26 --E.db.general.minimap.icons.vehicleLeave.size or 
	button:ClearAllPoints()
	button:SetPoint(pos, Minimap, pos, 2, 2)
	--E.db.general.minimap.icons.vehicleLeave.xOffset or 
	--E.db.general.minimap.icons.vehicleLeave.yOffset or 
	button:SetSize(size, size)
end

function AB:CreateVehicleLeave()
	local vehicle = CreateFrame("Button", 'LeaveVehicleButton', Minimap, BackdropTemplateMixin and 'BackdropTemplate')
	vehicle:SetSize(26,26)
	vehicle:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2)
	vehicle:SetNormalTexture("Interface\\AddOns\\AleaUI\\media\\vehicleexit")
	vehicle:SetPushedTexture("Interface\\AddOns\\AleaUI\\media\\vehicleexit")
	vehicle:SetHighlightTexture("Interface\\AddOns\\AleaUI\\media\\vehicleexit")
---	vehicle:SetTemplate("Default")

	Skins.SetTemplate(vehicle, 'DARK')
	vehicle:RegisterForClicks("AnyUp")
	vehicle:SetFrameLevel(Minimap:GetFrameLevel()+1)
	vehicle:SetScript("OnClick", Vehicle_OnClick)
	vehicle:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	vehicle:SetScript("OnLeave", GameTooltip_Hide)
	vehicle:RegisterEvent("PLAYER_ENTERING_WORLD");
	vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	if ( not E.isClassic ) then
	vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");
	vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE");
	vehicle:RegisterEvent("UNIT_EXITED_VEHICLE");
	vehicle:RegisterEvent("VEHICLE_UPDATE");
	vehicle:SetScript("OnEvent", Vehicle_OnEvent)
	end
	
	self:UpdateVehicleLeave()

	vehicle:Hide()
end

function AB:ReassignBindings(event)
	if event == "UPDATE_BINDINGS" then
		self:UpdatePetBindings();
		self:UpdateStanceBindings();
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")

	if InCombatLockdown() then return end
	for _, bar in pairs(self["handledBars"]) do
		if not bar then return end

		ClearOverrideBindings(bar)
		for i = 1, #bar.buttons do
			local button = (bar.bindButtons.."%d"):format(i)
			local real_button = (bar:GetName().."Button%d"):format(i)
			for k=1, select('#', GetBindingKey(button)) do
				local key = select(k, GetBindingKey(button))
				if key and key ~= "" then
					SetOverrideBindingClick(bar, false, key, real_button)
				end
			end
		end
	end
end

AB.UPDATE_BINDINGS = AB.ReassignBindings
AB.PLAYER_REGEN_DISABLED = AB.ReassignBindings
AB.PET_BATTLE_CLOSE = AB.ReassignBindings

function AB:RemoveBindings()
	if InCombatLockdown() then return end
	for _, bar in pairs(self["handledBars"]) do
		if not bar then return end

		ClearOverrideBindings(bar)
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
end

AB.PET_BATTLE_OPENING_DONE = AB.RemoveBindings

function AB:UpdateBar1Paging()
	if E.db.actionbars.bar6.enabled then
		AB.barDefaults.bar1.conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex())
	else
		AB.barDefaults.bar1.conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex())
	end

	if (false or InCombatLockdown()) or not self.isInitialized then return; end
	local bar2Option = InterfaceOptionsActionBarsPanelBottomRight
	local bar3Option = InterfaceOptionsActionBarsPanelBottomLeft
	local bar4Option = InterfaceOptionsActionBarsPanelRightTwo
	local bar5Option = InterfaceOptionsActionBarsPanelRight

	if (E.db.actionbars.bar2.enabled and not bar2Option:GetChecked()) or (not E.db.actionbars.bar2.enabled and bar2Option:GetChecked())  then
		bar2Option:Click()
	end

	if (E.db.actionbars.bar3.enabled and not bar3Option:GetChecked()) or (not E.db.actionbars.bar3.enabled and bar3Option:GetChecked())  then
		bar3Option:Click()
	end

	if not E.db.actionbars.bar5.enabled and not E.db.actionbars.bar4.enabled then
		if bar4Option:GetChecked() then
			bar4Option:Click()
		end

		if bar5Option:GetChecked() then
			bar5Option:Click()
		end
	elseif not E.db.actionbars.bar5.enabled then
		if not bar5Option:GetChecked() then
			bar5Option:Click()
		end

		if not bar4Option:GetChecked() then
			bar4Option:Click()
		end
	elseif (E.db.actionbars.bar4.enabled and not bar4Option:GetChecked()) or (not E.db.actionbars.bar4.enabled and bar4Option:GetChecked()) then
		bar4Option:Click()
	elseif (E.db.actionbars.bar5.enabled and not bar5Option:GetChecked()) or (not E.db.actionbars.bar5.enabled and bar5Option:GetChecked()) then
		bar5Option:Click()
	end
end

function AB:UpdateButtonSettings()
	if false then return end
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return; end
	for button, _ in pairs(self["handledbuttons"]) do
		if button then
			self:StyleButton(button, button.noBackdrop)
			self:StyleFlyout(button)
		else
			self["handledbuttons"][button] = nil
		end
	end

	for i=1, 6 do
		self:PositionAndSizeBar('bar'..i)
	end
	self:PositionAndSizeBarPet()
	self:PositionAndSizeBarShapeShift()
	self:UpdatePetBindings()
	self:UpdateStanceBindings()
	for barName, bar in pairs(self["handledBars"]) do
		self:UpdateButtonConfig(bar, bar.bindButtons)
	end
end

E.OnLSMUpdateRegister(function()
	AB:UpdateButtonSettings()
end)	

function AB:GetPage(bar, defaultPage, condition)
	local page = E.db.actionbars[bar]['paging'][E.myclass]
	if not condition then condition = '' end
	if not page then page = '' end
	if page then
		condition = condition.." "..page
	end
	condition = condition.." "..defaultPage

	return condition
end

function AB:VehicleBarArtWorkVisability()
	
	if UnitHasVehicleUI and UnitHasVehicleUI('player')  then
		self:Hide()
		self.back:Hide()
	else
		self:Show()
		self.back:Show()
	end
--	print(self, self.back, event, unit, UnitHasVehicleUI('player'),  UnitHasVehiclePlayerFrameUI('player'))
end

function AB:StyleButton(button, noBackdrop, adjustChecked)
	local name = button:GetName();
	local icon = _G[name.."Icon"];
	local count = _G[name.."Count"];
	local flash	 = _G[name.."Flash"];
	local hotkey = _G[name.."HotKey"];
	local border  = _G[name.."Border"];
	local macroName = _G[name.."Name"];
	local normal  = _G[name.."NormalTexture"];
	local normal2 = button:GetNormalTexture()
	local shine = _G[name.."Shine"];
	local combat = InCombatLockdown()

	if flash then flash:SetTexture(nil); end
	if normal then normal:SetTexture(nil); normal:Hide(); normal:SetAlpha(0); end
	if normal2 then normal2:SetTexture(nil); normal2:Hide(); normal2:SetAlpha(0); end
	if border then border:Kill(); end

	if not button.noBackdrop then
		button.noBackdrop = noBackdrop;
	end

	if count then
		count:ClearAllPoints();
		count:SetPoint("BOTTOMRIGHT", 0, 2);
		count:SetFont(E:GetFont(E.db.actionbars.font), E.db.actionbars.fontSize, E.db.actionbars.fontOutline)
		count:SetShadowColor(0,0,0,1)
		count:SetShadowOffset(1, -1)
	end
	
	button._point = button
	
	if not button.noBackdrop and not button.artBorder then
		button.artBorder = CreateFrame("Frame", nil, button, BackdropTemplateMixin and 'BackdropTemplate')
		button.artBorder:SetFrameLevel(button:GetFrameLevel()+1)
		button.artBorder:SetBackdrop({
		  edgeFile = [[Interface\Buttons\WHITE8x8]],
		  edgeSize = 1, 
		})
		button.artBorder:SetBackdropBorderColor(0,0,0,1)
		button.artBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, -0)
		button.artBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -0, 0)
	
		button.artBorder.back = button:CreateTexture()
		button.artBorder.back:SetDrawLayer('BACKGROUND', -2)
		button.artBorder.back:SetColorTexture(0, 0, 0, 0)
		button.artBorder.back:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
		button.artBorder.back:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
	end
	
	if icon then
		icon:SetTexCoord(unpack(E.media.texCoord));
		icon:SetInside()
	end

	if shine then
		shine:SetInside(nil, 3, 3)
	end
	
	if E.db.actionbars.macrotext then
		macroName:SetParent(button.artBorder)
		macroName:SetFont(E:GetFont(E.db.actionbars.font), E.db.actionbars.fontSize, E.db.actionbars.fontOutline)
	end
	
	if E.db.actionbars.hotkeytext then
		hotkey:SetParent(button.artBorder)
		hotkey:SetFont(E:GetFont(E.db.actionbars.font), E.db.actionbars.fontSize, E.db.actionbars.fontOutline)
	end

	--Extra Action Button
	if button.style then
		--button.style:SetParent(button.backdrop)
		button.style:SetDrawLayer('BACKGROUND', -7)
	end

	button.FlyoutUpdateFunc = AB.StyleFlyout
	self:FixKeybindText(button);
	button:StyleButton();

	if(not self.handledbuttons[button]) then
		self.handledbuttons[button] = true;
	end
end

function AB:Bar_OnEnter(bar)
--	E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
end

function AB:Bar_OnLeave(bar)
--	E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
--	E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
--	E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
end

function AB:BlizzardOptionsPanel_OnEvent()
	InterfaceOptionsActionBarsPanelBottomRight.Text:SetText(format("Remove Bar %d Action Page", 2))
	InterfaceOptionsActionBarsPanelBottomLeft.Text:SetText(format("Remove Bar %d Action Page", 3))
	InterfaceOptionsActionBarsPanelRightTwo.Text:SetText(format("Remove Bar %d Action Page", 4))
	InterfaceOptionsActionBarsPanelRight.Text:SetText(format("Remove Bar %d Action Page", 5))

	InterfaceOptionsActionBarsPanelBottomRight:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelRightTwo:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelRight:SetScript('OnEnter', nil)
end

function AB:DisableBlizzard()
	-- Hidden parent frame
	local UIHider = CreateFrame("Frame")
	UIHider:Hide()
	
	if ArtifactWatchBar then
		ArtifactWatchBar:SetParent(UIHider)
		ArtifactWatchBar:UnregisterAllEvents()
	end
	
	if HonorWatchBar then
		HonorWatchBar:SetParent(UIHider)
		HonorWatchBar:UnregisterAllEvents()
	end
	
	MultiBarBottomLeft:SetParent(UIHider)
	MultiBarBottomRight:SetParent(UIHider)
	MultiBarLeft:SetParent(UIHider)
	MultiBarRight:SetParent(UIHider)
	
	-- Hide MultiBar Buttons, but keep the bars alive
	for i=1,12 do
		_G["ActionButton" .. i]:Hide()
		_G["ActionButton" .. i]:UnregisterAllEvents()
		_G["ActionButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomLeftButton" .. i]:Hide()
		_G["MultiBarBottomLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton" .. i]:Hide()
		_G["MultiBarBottomRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarRightButton" .. i]:Hide()
		_G["MultiBarRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarLeftButton" .. i]:Hide()
		_G["MultiBarLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarLeftButton" .. i]:SetAttribute("statehidden", true)

		if _G["VehicleMenuBarActionButton" .. i] then
			_G["VehicleMenuBarActionButton" .. i]:Hide()
			_G["VehicleMenuBarActionButton" .. i]:UnregisterAllEvents()
			_G["VehicleMenuBarActionButton" .. i]:SetAttribute("statehidden", true)
		end

		if _G['OverrideActionBarButton'..i] then
			_G['OverrideActionBarButton'..i]:Hide()
			_G['OverrideActionBarButton'..i]:UnregisterAllEvents()
			_G['OverrideActionBarButton'..i]:SetAttribute("statehidden", true)
		end

		if ( _G['MultiCastActionButton'..i] ) then 
		_G['MultiCastActionButton'..i]:Hide()
		_G['MultiCastActionButton'..i]:UnregisterAllEvents()
		_G['MultiCastActionButton'..i]:SetAttribute("statehidden", true)
		end
	end

	ActionBarController:UnregisterAllEvents()
	if (not E.isClassic) then 
	ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	end

	MainMenuBar:SetMovable(true)
	MainMenuBar:SetUserPlaced(true)
	MainMenuBar:SetIgnoreFramePositionManager(true)
	
	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	--[==[
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(UIHider)
	]==]
	
	for i=1, MainMenuBar:GetNumChildren() do
		local child = select(i, MainMenuBar:GetChildren())
		if child then
			child:UnregisterAllEvents()
			child:Hide()
			child:SetParent(UIHider)
		end
	end
	--[==[
	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(UIHider)
	]==]
	
	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)

	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(UIHider)

	if ( OverrideActionBar ) then
	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(UIHider)
	end

	if ( PossessBarFrame ) then 
	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)
	end

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)

	if ( MultiCastActionBarFrame ) then 
	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(UIHider)
	end

	--This frame puts spells on the damn actionbar, fucking obliterate that shit
	if ( IconIntroTracker ) then 
	IconIntroTracker:UnregisterAllEvents()
	IconIntroTracker:Hide()
	IconIntroTracker:SetParent(UIHider)
	end

	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
	InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.00001)

	hooksecurefunc('BlizzardOptionsPanel_OnEvent', AB.BlizzardOptionsPanel_OnEvent)
--	InterfaceOptionsFrameCategoriesButton6:SetScale(0.00001)
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function AB:UpdateButtonConfig(bar, buttonName)
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return; end
	if not bar.buttonConfig then bar.buttonConfig = { hideElements = {}, colors = {} } end
	bar.buttonConfig.hideElements.macro = not E.db.actionbars.macrotext
	bar.buttonConfig.hideElements.hotkey = not E.db.actionbars.hotkeytext
	bar.buttonConfig.showGrid = E.db.actionbars.showGrid
	bar.buttonConfig.clickOnDown = E.db.actionbars.keyDown
	SetModifiedClick("PICKUPACTION", E.db.actionbars.movementModifier)
	bar.buttonConfig.colors.range = { E.db.actionbars.noRangeColor.r, E.db.actionbars.noRangeColor.g, E.db.actionbars.noRangeColor.b }
	bar.buttonConfig.colors.mana = { E.db.actionbars.noPowerColor.r, E.db.actionbars.noPowerColor.g, E.db.actionbars.noPowerColor.b }
	bar.buttonConfig.colors.hp = { E.db.actionbars.noPowerColor.r, E.db.actionbars.noPowerColor.g, E.db.actionbars.noPowerColor.b }

	for i, button in pairs(bar.buttons) do
		bar.buttonConfig.keyBoundTarget = format(buttonName.."%d", i)
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget
		button.postKeybind = AB.FixKeybindText
		button:SetAttribute("buttonlock", true)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)

		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName()..'HotKey'];
	local text = hotkey:GetText();

	if text then
		text = gsub(text, 'SHIFT%-',"S");
		text = gsub(text, 'ALT%-', "A");
		text = gsub(text, 'CTRL%-', "C");
		text = gsub(text, 'BUTTON', "MB");
		text = gsub(text, 'MOUSEWHEELUP', "MWU");
		text = gsub(text, 'MOUSEWHEELDOWN', "MWD");
		text = gsub(text, 'NUMPAD', "NP");
		text = gsub(text, 'PAGEUP', "PU");
		text = gsub(text, 'PAGEDOWN', "PD");
		text = gsub(text, 'SPACE', "SP");
		text = gsub(text, 'INSERT', "INS");
		text = gsub(text, 'HOME', "HME");
		text = gsub(text, 'DELETE', "DLT");
		text = gsub(text, 'NMULTIPLY', "*");
		text = gsub(text, 'NMINUS', "N-");
		text = gsub(text, 'NPLUS', "N+");

		hotkey:SetText(text);
	end

	hotkey:ClearAllPoints()
	hotkey:SetPoint("TOPRIGHT", 0, -3);
end

local buttons = 0
local function SetupFlyoutButton()
	for i=1, buttons do
		--prevent error if you don't have max amount of buttons
		if _G["SpellFlyoutButton"..i] then
			AB:StyleButton(_G["SpellFlyoutButton"..i])
			_G["SpellFlyoutButton"..i]:StyleButton()
			_G["SpellFlyoutButton"..i]:HookScript('OnEnter', function(self)
				local parent = self:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if not AB["handledbuttons"][parentAnchorButton] then return end

				local parentAnchorBar = parentAnchorButton:GetParent()
				if parentAnchorBar.mouseover then
					AB:Bar_OnEnter(parentAnchorBar)
				end
			end)
			_G["SpellFlyoutButton"..i]:HookScript('OnLeave', function(self)
				local parent = self:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if not AB["handledbuttons"][parentAnchorButton] then return end

				local parentAnchorBar = parentAnchorButton:GetParent()

				if parentAnchorBar.mouseover then
					AB:Bar_OnLeave(parentAnchorBar)
				end
			end)
		end
	end

	SpellFlyout:HookScript('OnEnter', function(self)
		local anchorButton = select(2, self:GetPoint())
		if not AB["handledbuttons"][anchorButton] then return end

		local parentAnchorBar = anchorButton:GetParent()
		if parentAnchorBar.mouseover then
			AB:Bar_OnEnter(parentAnchorBar)
		end
	end)

	SpellFlyout:HookScript('OnLeave', function(self)
		local anchorButton = select(2, self:GetPoint())
		if not AB["handledbuttons"][anchorButton] then return end

		local parentAnchorBar = anchorButton:GetParent()
		if parentAnchorBar.mouseover then
			AB:Bar_OnLeave(parentAnchorBar)
		end
	end)
end

function AB:StyleFlyout(button)
	if(not button.FlyoutArrow or not button.FlyoutArrow:IsShown()) then return end

	if not BF.buttonRegistry[button] then return end
	if not button.FlyoutBorder then return end
	local combat = InCombatLockdown()

	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)

	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)

	for i=1, GetNumFlyouts() do
		local x = GetFlyoutID(i)
		local _, _, numSlots, isKnown = GetFlyoutInfo(x)
		if isKnown then
			buttons = numSlots
			break
		end
	end

	--Change arrow direction depending on what bar the button is on
	local arrowDistance
	if ((SpellFlyout:IsShown() and SpellFlyout:GetParent() == button) or GetMouseFocus() == button) then
		arrowDistance = 5
	else
		arrowDistance = 2
	end

	if button:GetParent() and button:GetParent():GetParent() and button:GetParent():GetParent():GetName() and button:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame" then
		return
	end

	if button:GetParent() then
		local point = 'BOTTOM' --E:GetScreenQuadrant(button:GetParent())
		if point == "UNKNOWN" then return end
		
		button.FlyoutArrow:SetParent(button.artBorder)
		
		if strfind(point, "TOP") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("BOTTOM", button, "BOTTOM", 0, -arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if not combat then button:SetAttribute("flyoutDirection", "DOWN") end
		elseif point == "RIGHT" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("LEFT", button, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if not combat then button:SetAttribute("flyoutDirection", "LEFT") end
		elseif point == "LEFT" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("RIGHT", button, "RIGHT", arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if not combat then button:SetAttribute("flyoutDirection", "RIGHT") end
		elseif point == "CENTER" or strfind(point, "BOTTOM") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("TOP", button, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if not combat then button:SetAttribute("flyoutDirection", "UP") end
		end
	end
end

function AB:VehicleFix()
	local barName = 'bar1'
	local bar = self["handledBars"][barName]
	local spacing = E.db.actionbars[barName].buttonspacing;
	local numButtons = E.db.actionbars[barName].buttons;
	local buttonsPerRow = E.db.actionbars[barName].buttonsPerRow;
	local size = E.db.actionbars[barName].buttonsize;
	local point = E.db.actionbars[barName].point;
	local numColumns = ceil(numButtons / buttonsPerRow);

	if (HasOverrideActionBar() or HasVehicleActionBar()) and numButtons == 12 then
		local widthMult = 1;
		local heightMult = 1;

	--	bar.backdrop:ClearAllPoints()
	--	bar.backdrop:SetPoint(E.db.actionbars[barName].point, bar, E.db.actionbars[barName].point)
	--	bar.backdrop:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	--	bar.backdrop:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	else
	--	bar.backdrop:SetAllPoints()
	end
end

AB.UPDATE_VEHICLE_ACTIONBAR = AB.VehicleFix
AB.UPDATE_OVERRIDE_ACTIONBAR = AB.VehicleFix
	
function AB:ActionButton_ShowOverlayGlow(frame)
	if not frame.overlay then return; end
	local size =  frame:GetWidth() / 3
	frame.overlay:SetOutside(frame, size, size)
end

function AB:Initialize()

	AB:DisableBlizzard()

--	AB:SetupExtraButton()
--	AB:SetupMicroBar()
	AB:UpdateBar1Paging()

	for i=1, 6 do
		AB:CreateBar(i)
	end
	AB:CreateBarPet()
	AB:CreateBarShapeShift()
	AB:CreateVehicleLeave()

	AB:UpdateButtonSettings()

	AB:LoadKeyBinder()
	AB:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")

	if ( not E.isClassic ) then 
	AB:RegisterEvent("PET_BATTLE_CLOSE", "ReassignBindings")
	AB:RegisterEvent('PET_BATTLE_OPENING_DONE', 'RemoveBindings')
	AB:RegisterEvent('UPDATE_VEHICLE_ACTIONBAR', 'VehicleFix')
	AB:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR', 'VehicleFix')
	end 

	if C_PetBattles and C_PetBattles.IsInBattle() then
		AB:RemoveBindings()
	else
		AB:ReassignBindings()
	end

	if not GetCVarBool('lockActionBars') then
		SetCVar('lockActionBars', 1)
	end

	if ( SpellFlyout ) then 
	SpellFlyout:HookScript("OnShow", SetupFlyoutButton)
	end

	E.GUI.args.actionbars.args.FontGroup = {
		name = L["Fonts"],
		type = "group",
		order = 5,
		embend = true,
		args = {},	
	}
	
	E.GUI.args.actionbars.args.FontGroup.args.Font = {	
		name = L["Font"],
		order = 1,
		type = "font",
		values = E.GetFontList,
		set = function(self, value)
			E.db.actionbars.font = value
			AB:UpdateButtonSettings()
		end,
		get = function(self)
			return E.db.actionbars.font
		end,
	}
	
	E.GUI.args.actionbars.args.FontGroup.args.Size = {
		name = L["Size"],
		order = 2,
		type = "slider",
		min = 1, max = 32, step = 1,
		set = function(self, value)
			E.db.actionbars.fontSize = value
			AB:UpdateButtonSettings()
		end,
		get = function(self) 
			return E.db.actionbars.fontSize
		end
	}
	
	E.GUI.args.actionbars.args.FontGroup.args.Flags = {
		name = L["Outline"],
		type = "dropdown",
		order = 3,
		values = {
			['NONE'] = NO,
			['OUTLINE'] = L["Outline"],
		},
		set = function(self, value)			
			E.db.actionbars.fontOutline = value
			AB:UpdateButtonSettings()
		end,
		get = function(self)
			return E.db.actionbars.fontOutline
		end,	
	}
	
	E.GUI.args.actionbars.args.MacroText = {
		name = L["Macro name"],
		type = "toggle",
		order = 1,
		set = function(self, value)
			E.db.actionbars.macrotext = not E.db.actionbars.macrotext
			AB:UpdateButtonSettings()
		end,
		get = function(self)
			return E.db.actionbars.macrotext
		end,	
	}
	
	E.GUI.args.actionbars.args.HotKeyText = {
		name = L["Key name"],
		type = "toggle",
		order = 2,
		set = function(self, value)
			E.db.actionbars.hotkeytext = not E.db.actionbars.hotkeytext
			AB:UpdateButtonSettings()
		end,
		get = function(self)
			return E.db.actionbars.hotkeytext
		end,	
	}
	
	E.GUI.args.actionbars.args.keyDown = {
		name = L["Trigger on key down"],
		type = "toggle",
		order = 3,
		set = function(self, value)
			E.db.actionbars.keyDown = not E.db.actionbars.keyDown
			AB:UpdateButtonSettings()
		end,
		get = function(self)
			return E.db.actionbars.keyDown
		end,	
	}
	
	E.GUI.args.actionbars.args.noRangeColor = {
		name = L['"No range" color'],
		order = 3.6,
		type = "color",
		hasAlpha = false,		
		set = function(self, r,g,b,a)
			E.db.actionbars.noRangeColor = { r=r, g=g, b=b, 1 }
			AB:UpdateButtonSettings()
		end,
		get = function(self)
			return E.db.actionbars.noRangeColor.r, 
			E.db.actionbars.noRangeColor.g, 
			E.db.actionbars.noRangeColor.b,
			E.db.actionbars.noRangeColor.a or 1
		end,
	}
	
	E.GUI.args.actionbars.args.noPowerColor = {
		name = L['"No power" color'],
		order = 3.7,
		type = "color",
		hasAlpha = false,		
		set = function(self, r,g,b,a)
			E.db.actionbars.noPowerColor = { r=r, g=g, b=b, 1 }
			AB:UpdateButtonSettings()
		end,
		get = function(self)
			return E.db.actionbars.noPowerColor.r, 
			E.db.actionbars.noPowerColor.g, 
			E.db.actionbars.noPowerColor.b,
			E.db.actionbars.noPowerColor.a or 1
		end,
	}
	
	E.GUI.args.actionbars.args.swipeTexture = {
		name = L['Edge texture'],
		order = 3.8,
		type = 'dropdown',
		values = {
			'Default',
			'White',
			'Test1',
			'Test2',
		},
		set = function(info, value)
			E.db.actionbars.swipeTexture = value
			
			for i=1, #BF.TotalChargeCooldowns do
				BF.TotalChargeCooldowns[i]:SetEdgeTexture(E:GetEdgeTexture())
			end
		end,
		get = function(info)
			return E.db.actionbars.swipeTexture
		end,
	}

	for i=1, #BF.TotalChargeCooldowns do
		BF.TotalChargeCooldowns[i]:SetEdgeTexture(E:GetEdgeTexture())
	end

end

local edgeTextures = {
	"Interface\\Cooldown\\edge",
	[[Interface\AddOns\AleaUI\media\edgeBlackAndWhite.blp]],
	[[Interface\AddOns\AleaUI\media\edgeBlackAndWhite2.blp]],
	[[Interface\AddOns\AleaUI\media\edgeWhite3.blp]],
}
function E:GetEdgeTexture()
	return edgeTextures[E.db.actionbars.swipeTexture or 1] or "Interface\\Cooldown\\edge"
end

E:OnInit2(AB.Initialize)

local bar = CreateFrame('Frame', 'AleaUI_BarPet', E.UIParent, 'SecureHandlerStateTemplate');

function AB:UpdatePet(event, unit)
	if(event == "UNIT_AURA" and unit ~= "pet") then return end

	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton"..i;
		local button = _G[buttonName];
		local icon = _G[buttonName.."Icon"];
		local autoCast = _G[buttonName.."AutoCastable"];
		local shine = _G[buttonName.."Shine"];
		local checked = button:GetCheckedTexture();
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i);
		
		if not isToken then
			--icon:SetTexture(texture);
			button.ICON:SetTexture(texture);
			button.tooltipName = name;
		else
			--icon:SetTexture(_G[texture]);
			button.ICON:SetTexture(_G[texture]);
			button.tooltipName = _G[name];
		end
		
		button.icon:Hide();
		button.isToken = isToken;
		button.tooltipSubtext = subtext;

		if isActive and name ~= "PET_ACTION_FOLLOW" then
			--button:GetCheckedTexture():SetColorTexture(1, 1, 1)
			button:SetChecked(true);

			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(button);
			end
		else
			--button:SetCheckedTexture("")
			button:SetChecked(false);
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(button);
			end
		end

		if autoCastAllowed then
			autoCast:Show();
		else
			autoCast:Hide();
		end

		if autoCastEnabled then
			AutoCastShine_AutoCastStart(shine);
		else
			AutoCastShine_AutoCastStop(shine);
		end

		button:SetAlpha(1);

		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(button.ICON, nil);
			else
				SetDesaturation(button.ICON, 1);
			end
			button.ICON:Show();
		else
			button.ICON:Hide();
		end

		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(button);
			SetDesaturation(button.ICON, 1);
			button:SetChecked(false);
		end

		checked:SetAlpha(0.3)
	end
end


AB.SPELLS_CHANGED = AB.UpdatePet
AB.PLAYER_CONTROL_GAINED = AB.UpdatePet
AB.PLAYER_ENTERING_WORLD = AB.UpdatePet
AB.PLAYER_CONTROL_LOST = AB.UpdatePet
AB.PET_BAR_UPDATE = AB.UpdatePet
AB.UNIT_PET = AB.UpdatePet
AB.UNIT_FLAGS = AB.UpdatePet
AB.UNIT_AURA = AB.UpdatePet
AB.UNIT_COMBAT = AB.UpdatePet
AB.PLAYER_FARSIGHT_FOCUS_CHANGED = AB.UpdatePet
AB.PET_BAR_UPDATE_COOLDOWN = PetActionBar_UpdateCooldowns

function AB:PositionAndSizeBarPet()
	local spacing = E.db.actionbars['barPet'].buttonspacing;
	local buttonsPerRow = E.db.actionbars['barPet'].buttonsPerRow;
	local numButtons = E.db.actionbars['barPet'].buttons;
	local size = E.db.actionbars['barPet'].buttonsize;
	local autoCastSize = (size / 2) - (size / 7.5) + 1
	local point = E.db.actionbars['barPet'].point;
	local numColumns = ceil(numButtons / buttonsPerRow);
	local widthMult = E.db.actionbars['barPet'].widthMult;
	local heightMult = E.db.actionbars['barPet'].heightMult;
	bar.db = E.db.actionbars['barPet']
	bar.db.position = nil; --Depreciated
	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end

	if numColumns < 1 then
		numColumns = 1;
	end

	bar:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	bar.mouseover = E.db.actionbars['barPet'].mouseover
	if E.db.actionbars['barPet'].enabled then
		bar:SetScale(1);
		bar:SetAlpha(bar.db.alpha);
	else
		bar:SetScale(0.000001);
		bar:SetAlpha(0);
	end
	--[[
	if E.db.actionbars['barPet'].backdrop == true then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();
	end
	]]
	local horizontalGrowth, verticalGrowth;
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end

	local button, lastButton, lastColumnButton, autoCast;
	for i=1, NUM_PET_ACTION_SLOTS do
		button = _G["PetActionButton"..i];

		lastButton = _G["PetActionButton"..i-1];
		autoCast = _G["PetActionButton"..i..'AutoCastable'];
		lastColumnButton = _G["PetActionButton"..i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:SetSize(size, size);
		
		if not button.ICON then
			button.ICON = button:CreateTexture("PetActionButton"..i..'ICON')
			button.ICON:SetTexCoord(unpack(E.media.texCoord))
			button.ICON:SetSnapToPixelGrid(false)
			button.ICON:SetTexelSnappingBias(0)
			button.ICON:SetInside()

			if button.pushed then
				button.pushed:SetDrawLayer('ARTWORK', 1)
			end
		end
		
		autoCast:SetOutside(button, autoCastSize, autoCastSize)

		button:SetAttribute("showgrid", 1);
		
		E:RegisterCooldown(button.cooldown)
	--[[
		if E.db.actionbars['barPet'].mouseover == true then
			bar:SetAlpha(0);
			if not self.hooks[bar] then
				self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
				self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');
			end

			if not self.hooks[button] then
				self:HookScript(button, 'OnEnter', 'Button_OnEnter');
				self:HookScript(button, 'OnLeave', 'Button_OnLeave');
			end
		else
			bar:SetAlpha(bar.db.alpha);
			if self.hooks[bar] then
				self:Unhook(bar, 'OnEnter');
				self:Unhook(bar, 'OnLeave');
			end

			if self.hooks[button] then
				self:Unhook(button, 'OnEnter');
				self:Unhook(button, 'OnLeave');
			end
		end
	]]
		if i == 1 then
			local x, y;
			if point == "BOTTOMLEFT" then
				x, y = spacing, spacing;
			elseif point == "TOPRIGHT" then
				x, y = -spacing, -spacing;
			elseif point == "TOPLEFT" then
				x, y = spacing, -spacing;
			else
				x, y = -spacing, spacing;
			end

			button:SetPoint(point, bar, point, x, y);
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0;
			local y = -spacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if verticalGrowth == 'UP' then
				y = spacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:SetPoint(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = spacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if horizontalGrowth == 'LEFT' then
				x = -spacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end

			button:SetPoint(buttonPoint, lastButton, anchorPoint, x, y);
		end

		if i > numButtons then
			button:SetScale(0.000001);
			button:SetAlpha(0);
		else
			button:SetScale(1);
			button:SetAlpha(bar.db.alpha);
		end

		self:StyleButton(button);
		
		local opts = E.db.actionbars['barPet']
		
		button.artBorder.r = opts.border.color[1]
		button.artBorder.g = opts.border.color[2]
		button.artBorder.b = opts.border.color[3]
		button.artBorder.a = opts.border.color[4]
		
		button.artBorder:SetBackdrop({
		  edgeFile = E:GetBorder(opts.border.texture),
		  edgeSize = opts.border.size, 
		})
		button.artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
		button.artBorder:SetPoint("TOPLEFT", button._point, "TOPLEFT", opts.border.inset, -opts.border.inset)
		button.artBorder:SetPoint("BOTTOMRIGHT", button._point, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

		button.artBorder.back:SetTexture(E:GetTexture(opts.border.background_texture))
		button.artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
		button.artBorder.back:SetPoint("TOPLEFT", button._point, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
		button.artBorder.back:SetPoint("BOTTOMRIGHT", button._point, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
		
		--wtf lol
		if not button.CheckFixed then
			hooksecurefunc(button:GetCheckedTexture(), 'SetAlpha', function(self, value)
				if value == 1 then
					self:SetAlpha(0.3)
				end
			end)
			button.CheckFixed = true;
		end
	end

	RegisterStateDriver(bar, "show", E.db.actionbars['barPet'].visibility);
end

function AB:UpdatePetBindings()
	for i=1, NUM_PET_ACTION_SLOTS do
		if E.db.actionbars.hotkeytext then
			local key = GetBindingKey("BONUSACTIONBUTTON"..i)
			_G["PetActionButton"..i.."HotKey"]:Show()
			_G["PetActionButton"..i.."HotKey"]:SetText(key)
			self:FixKeybindText(_G["PetActionButton"..i])
		else
			_G["PetActionButton"..i.."HotKey"]:Hide()
		end
	end
end

function AB:CreateBarPet()
--	bar:CreateBackdrop('Default');
--	bar.backdrop:SetAllPoints();
	if E.db.actionbars['bar4'].enabled then
		bar:SetPoint('RIGHT', AleaUI_Bar4, 'LEFT', -4, 0);
	else
		bar:SetPoint('RIGHT', E.UIParent, 'RIGHT', -4, 0);
	end

	bar:SetAttribute("_onstate-show", [[
		if newstate == "hide" then
			self:Hide();
		else
			self:Show();
		end
	]]);

	PetActionBarFrame.showgrid = 1;
	PetActionBar_ShowGrid();

	self:RegisterEvent('SPELLS_CHANGED')
	self:RegisterEvent('PLAYER_CONTROL_GAINED');
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
	self:RegisterEvent('PLAYER_CONTROL_LOST');
	self:RegisterEvent('PET_BAR_UPDATE');
	self:RegisterUnitEvent("UNIT_COMBAT", "pet", "player");
	self:RegisterUnitEvent("UNIT_AURA", "pet", "player");
	self:RegisterEvent('PLAYER_FARSIGHT_FOCUS_CHANGED');
	self:RegisterEvent('PET_BAR_UPDATE_COOLDOWN');	
	self:RegisterUnitEvent("UNIT_PET", "player", '');

	E:Mover(bar, 'PetAB');
	self:PositionAndSizeBarPet();
	self:UpdatePetBindings()
	
	E.numActonBars = ( E.numActonBars or 0 ) + 1
	
	E.GUI.args.actionbars.args['PetActionBar'] = {
		name = L['PetActionBar'],
		order = E.numActonBars,
		expand = true,
		type = "group",
		args = {}
	}

	E.GUI.args.actionbars.args['PetActionBar'].args.unlock = {
		name = L["Unlock"],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover('PetAB') 
		end,
		get = function(self)end
	}
	
	E.GUI.args.actionbars.args['PetActionBar'].args.enabled = {
		name = L['Enable'],
		order = 1.1,
		type = "toggle",
		set = function(self, value)
			E.db.actionbars['barPet'].enabled = not E.db.actionbars['barPet'].enabled
			AB:PositionAndSizeBarPet();
		end,
		get = function(self)
			return E.db.actionbars['barPet'].enabled
		end
	}

	E.GUI.args.actionbars.args['PetActionBar'].args.perrow = {
		name = L["Per row"],
		order = 3.1,
		type = "slider",
		min = 1, max = 10, step = 1,
		set = function(self, value)
			E.db.actionbars['barPet'].buttonsPerRow = value
			AB:PositionAndSizeBarPet();
		end,
		get = function(self) 
			return E.db.actionbars['barPet'].buttonsPerRow
		end
	}
	
	E.GUI.args.actionbars.args['PetActionBar'].args.buttons = {
		name = L["Buttons"],
		order = 3,
		type = "slider",
		min = 1, max = 10, step = 1,
		set = function(self, value)
			E.db.actionbars['barPet'].buttons = value
			AB:PositionAndSizeBarPet();
		end,
		get = function(self) 
			return E.db.actionbars['barPet'].buttons
		end
	}
	
	E.GUI.args.actionbars.args['PetActionBar'].args.perrow = {
		name = L["Per row"],
		order = 3.1,
		type = "slider",
		min = 1, max = 10, step = 1,
		set = function(self, value)
			E.db.actionbars['barPet'].buttonsPerRow = value
			AB:PositionAndSizeBarPet();
		end,
		get = function(self) 
			return E.db.actionbars['barPet'].buttonsPerRow
		end
	}
	
	E.GUI.args.actionbars.args['PetActionBar'].args.size = {
		name = L["Size"],
		order = 4,
		type = "slider",
		min = 1, max = 60, step = 1,
		set = function(self, value)
			E.db.actionbars['barPet'].buttonsize = value
			AB:PositionAndSizeBarPet();
		end,
		get = function(self) 
			return E.db.actionbars['barPet'].buttonsize
		end
	}
	
	E.GUI.args.actionbars.args['PetActionBar'].args.spacing = {
		name = L["Spacing"],
		order = 6,
		type = "slider",
		min = 0, max = 60, step = 1,
		set = function(self, value)
			E.db.actionbars['barPet'].buttonspacing = value
			AB:PositionAndSizeBarPet();
		end,
		get = function(self) 
			return E.db.actionbars['barPet'].buttonspacing
		end
	}
	
	E.GUI.args.actionbars.args['PetActionBar'].args.point = {
		name = L["Point"],
		type = "dropdown",
		order = 7,
		values = DD_points,
		set = function(self, value)
			E.db.actionbars['barPet'].point = value
			AB:PositionAndSizeBarPet();
		end,
		get = function(self)
			return E.db.actionbars['barPet'].point
		end,	
	}
	
	E.GUI.args.actionbars.args['PetActionBar'].args.BorderOpts = {
		name = L["Borders"],
		order = 10,
		embend = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.actionbars.args['PetActionBar'].args.BorderOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L['Border texture'],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.actionbars['barPet'].border.texture = value;
			AB:PositionAndSizeBarPet();
		end,
		get = function(info) return E.db.actionbars['barPet'].border.texture end,
	}

	E.GUI.args.actionbars.args['PetActionBar'].args.BorderOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.actionbars['barPet'].border.color={ r, g, b, a}; 
			AB:PositionAndSizeBarPet();
		end,
		get = function(info) 
			return E.db.actionbars['barPet'].border.color[1],
					E.db.actionbars['barPet'].border.color[2],
					E.db.actionbars['barPet'].border.color[3],
					E.db.actionbars['barPet'].border.color[4] 
		end,
	}

	E.GUI.args.actionbars.args['PetActionBar'].args.BorderOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['barPet'].border.size = val
			AB:PositionAndSizeBarPet();
		end,
		get =function(info)
			return E.db.actionbars['barPet'].border.size
		end,
	}

	E.GUI.args.actionbars.args['PetActionBar'].args.BorderOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['barPet'].border.inset = val
			AB:PositionAndSizeBarPet();
		end,
		get =function(info)
			return E.db.actionbars['barPet'].border.inset
		end,
	}


	E.GUI.args.actionbars.args['PetActionBar'].args.BorderOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Background texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.actionbars['barPet'].border.background_texture = value;
			AB:PositionAndSizeBarPet();
		end,
		get = function(info) return E.db.actionbars['barPet'].border.background_texture end,
	}

	E.GUI.args.actionbars.args['PetActionBar'].args.BorderOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.actionbars['barPet'].border.background_color={ r, g, b, a}
			AB:PositionAndSizeBarPet();
		end,
		get = function(info) 
			return E.db.actionbars['barPet'].border.background_color[1],
					E.db.actionbars['barPet'].border.background_color[2],
					E.db.actionbars['barPet'].border.background_color[3],
					E.db.actionbars['barPet'].border.background_color[4] 
		end,
	}


	E.GUI.args.actionbars.args['PetActionBar'].args.BorderOpts.args.backgroundInset = {
		name = L['Background offset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['barPet'].border.background_inset = val
			AB:PositionAndSizeBarPet();
		end,
		get =function(info)
			return E.db.actionbars['barPet'].border.background_inset
		end,
	}
end


local bar = CreateFrame('Frame', 'AleaUI_StanceBar', E.UIParent, 'SecureHandlerStateTemplate');

function AB:UPDATE_SHAPESHIFT_COOLDOWN()
	local numForms = GetNumShapeshiftForms();
	local start, duration, enable, cooldown
	for i = 1, NUM_STANCE_SLOTS do
		if i <= numForms then
			cooldown = _G["AleaUI_StanceBarButton"..i.."Cooldown"];
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
			cooldown:SetDrawBling(cooldown:GetEffectiveAlpha() > 0.5) --Cooldown Bling Fix
		end
	end

	self:StyleShapeShift("UPDATE_SHAPESHIFT_COOLDOWN")
end

function AB:StyleShapeShift(event)
	local numForms = GetNumShapeshiftForms();
	local texture, name, isActive, isCastable, _;
	local buttonName, button, icon, cooldown;
	local stance = GetShapeshiftForm();

	for i = 1, NUM_STANCE_SLOTS do
		buttonName = "AleaUI_StanceBarButton"..i;
		button = _G[buttonName];
		icon = _G[buttonName.."Icon"];
		cooldown = _G[buttonName.."Cooldown"];
		
		if not button.ICON then
			button.ICON = button:CreateTexture("PetActionButton"..i..'ICON')
			button.ICON:SetTexCoord(unpack(E.media.texCoord))
			button.ICON:SetSnapToPixelGrid(false)
			button.ICON:SetTexelSnappingBias(0)
			button.ICON:SetInside()

			if button.pushed then
				button.pushed:SetDrawLayer('ARTWORK', 1)
			end
		end
		
		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);

			if not texture then
				texture = "Interface\\Icons\\Spell_Nature_WispSplode"
			end

			if (type(texture) == "string" and (lower(texture) == "interface\\icons\\spell_nature_wispsplode" or lower(texture) == "interface\\icons\\ability_rogue_envelopingshadows")) and E.db.actionbars.stanceBar.style == 'darkenInactive' then
				_, _, texture = GetSpellInfo(name)
			end

			button.ICON:SetTexture(texture);

			if texture then
				cooldown:SetAlpha(1);
			else
				cooldown:SetAlpha(0);
			end

			if isActive then
				StanceBarFrame.lastSelected = button:GetID();
				if numForms == 1 then
					button.__checked:SetColorTexture(1, 1, 1, 0.5)
					button:SetChecked(true);
				else
					button.__checked:SetColorTexture(1, 1, 1, 0.5)
					button:SetChecked(E.db.actionbars.stanceBar.style ~= 'darkenInactive');
				end
			else
				if numForms == 1 or stance == 0 then
					button:SetChecked(false);
				else
					button:SetChecked(E.db.actionbars.stanceBar.style == 'darkenInactive');
					button.__checked:SetAlpha(1)
					if E.db.actionbars.stanceBar.style == 'darkenInactive' then
						button.__checked:SetColorTexture(0, 0, 0, 0.5)
					else
						button.__checked:SetColorTexture(1, 1, 1, 0.5)
					end
				end
			end

			if isCastable then
				button.ICON:SetVertexColor(1.0, 1.0, 1.0);
			else
				button.ICON:SetVertexColor(0.4, 0.4, 0.4);
			end
		end
	end
end

function AB:PositionAndSizeBarShapeShift()
	local spacing = E.db.actionbars['stanceBar'].buttonspacing
	local buttonsPerRow = E.db.actionbars['stanceBar'].buttonsPerRow;
	local numButtons = E.db.actionbars['stanceBar'].buttons;
	local size = E.db.actionbars['stanceBar'].buttonsize
	local point = E.db.actionbars['stanceBar'].point;
	local widthMult = E.db.actionbars['stanceBar'].widthMult;
	local heightMult = E.db.actionbars['stanceBar'].heightMult;

	bar.db = E.db.actionbars['stanceBar']
	bar.db.position = nil; --Depreciated
	if bar.LastButton and numButtons > bar.LastButton then
		numButtons = bar.LastButton;
	end

	if bar.LastButton and buttonsPerRow > bar.LastButton then
		buttonsPerRow = bar.LastButton;
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end

	local numColumns = ceil(numButtons / buttonsPerRow);
	if numColumns < 1 then
		numColumns = 1;
	end

	bar:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	bar.mouseover = E.db.actionbars['stanceBar'].mouseover
	if E.db.actionbars['stanceBar'].enabled then
		bar:SetScale(1);
		bar:SetAlpha(bar.db.alpha);
	else
		bar:SetScale(0.000001);
		bar:SetAlpha(0);
	end
	--[[
	if E.db.actionbars['stanceBar'].backdrop == true then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();
	end
	]]
	local horizontalGrowth, verticalGrowth;
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end

	local button, lastButton, lastColumnButton;
	for i=1, NUM_STANCE_SLOTS do
		button = _G["AleaUI_StanceBarButton"..i];
		lastButton = _G["AleaUI_StanceBarButton"..i-1];
		lastColumnButton = _G["AleaUI_StanceBarButton"..i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:SetSize(size,size);
		
		E:RegisterCooldown(button.cooldown)
		
		--[[
		if E.db.actionbars['stanceBar'].mouseover == true then
			bar:SetAlpha(0);
			if not self.hooks[bar] then
				self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
				self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');
			end

			if not self.hooks[button] then
				self:HookScript(button, 'OnEnter', 'Button_OnEnter');
				self:HookScript(button, 'OnLeave', 'Button_OnLeave');
			end
		else
			bar:SetAlpha(bar.db.alpha);
			if self.hooks[bar] then
				self:Unhook(bar, 'OnEnter');
				self:Unhook(bar, 'OnLeave');
			end

			if self.hooks[button] then
				self:Unhook(button, 'OnEnter');
				self:Unhook(button, 'OnLeave');
			end
		end
		]]
		if i == 1 then
			local x, y;
			if point == "BOTTOMLEFT" then
				x, y = spacing, spacing;
			elseif point == "TOPRIGHT" then
				x, y = -spacing, -spacing;
			elseif point == "TOPLEFT" then
				x, y = spacing, -spacing;
			else
				x, y = -spacing, spacing;
			end

			button:SetPoint(point, bar, point, x, y);
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0;
			local y = -spacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if verticalGrowth == 'UP' then
				y = spacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:SetPoint(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = spacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if horizontalGrowth == 'LEFT' then
				x = -spacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end

			button:SetPoint(buttonPoint, lastButton, anchorPoint, x, y);
		end

		if i > numButtons then
			button:SetScale(0.000001);
			button:SetAlpha(0);
		else
			button:SetScale(1);
			button:SetAlpha(bar.db.alpha);
		end

		if(not button.FlyoutUpdateFunc) then
			self:StyleButton(button, nil, true);
			local opts = E.db.actionbars['stanceBar']
			
			button.artBorder.r = opts.border.color[1]
			button.artBorder.g = opts.border.color[2]
			button.artBorder.b = opts.border.color[3]
			button.artBorder.a = opts.border.color[4]
		
			button.artBorder:SetBackdrop({
			  edgeFile = E:GetBorder(opts.border.texture),
			  edgeSize = opts.border.size, 
			})
			button.artBorder:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
			button.artBorder:SetPoint("TOPLEFT", button._point, "TOPLEFT", opts.border.inset, -opts.border.inset)
			button.artBorder:SetPoint("BOTTOMRIGHT", button._point, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

			button.artBorder.back:SetTexture(E:GetTexture(opts.border.background_texture))
			button.artBorder.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
			button.artBorder.back:SetPoint("TOPLEFT", button._point, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
			button.artBorder.back:SetPoint("BOTTOMRIGHT", button._point, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
		
		end
	end
end

function AB:AdjustMaxStanceButtons(event)
	if InCombatLockdown() then return; end

	for i=1, #bar.buttons do
		bar.buttons[i]:Hide()
	end
	local initialCreate = false;
	local numButtons = GetNumShapeshiftForms()
	for i = 1, NUM_STANCE_SLOTS do
		if not bar.buttons[i] then
			bar.buttons[i] = CreateFrame("CheckButton", format(bar:GetName().."Button%d", i), bar, "StanceButtonTemplate")
			bar.buttons[i]:SetID(i)
			initialCreate = true;
		end

		if ( i <= numButtons ) then
			bar.buttons[i]:Show();
			bar.LastButton = i;
		else
			bar.buttons[i]:Hide();
		end
	end

	self:PositionAndSizeBarShapeShift();

	if event == 'UPDATE_SHAPESHIFT_FORMS' then
		self:StyleShapeShift()
	end

	if C_PetBattles and not C_PetBattles.IsInBattle() or initialCreate then
		if numButtons == 0 then
			UnregisterStateDriver(bar, "show");
			bar:Hide()
		else
			bar:Show()
			RegisterStateDriver(bar, "show", '[petbattle] hide;show');
		end
	end
end

function AB:UpdateStanceBindings()
	for i = 1, NUM_STANCE_SLOTS do
		if E.db.actionbars.hotkeytext then
			_G["AleaUI_StanceBarButton"..i.."HotKey"]:Show()
			_G["AleaUI_StanceBarButton"..i.."HotKey"]:SetText(GetBindingKey("CLICK AleaUI_StanceBarButton"..i..":LeftButton"))
			self:FixKeybindText(_G["AleaUI_StanceBarButton"..i])
		else
			_G["AleaUI_StanceBarButton"..i.."HotKey"]:Hide()
		end
	end
end

AB.UPDATE_SHAPESHIFT_FORMS = AB.AdjustMaxStanceButtons
AB.UPDATE_SHAPESHIFT_USABLE = AB.StyleShapeShift
AB.UPDATE_SHAPESHIFT_FORM = AB.StyleShapeShift
AB.ACTIONBAR_PAGE_CHANGED = AB.StyleShapeShift

function AB:CreateBarShapeShift()
--	bar:CreateBackdrop('Default');
--	bar.backdrop:SetAllPoints();
	bar:SetPoint('TOPLEFT', E.UIParent, 'TOPLEFT', 4, -4);
	bar.buttons = {};
	bar:SetAttribute("_onstate-show", [[
		if newstate == "hide" then
			self:Hide();
		else
			self:Show();
		end
	]]);
	
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORMS');
	self:RegisterEvent('UPDATE_SHAPESHIFT_COOLDOWN');
	self:RegisterEvent('UPDATE_SHAPESHIFT_USABLE');
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORM');
	self:RegisterEvent('ACTIONBAR_PAGE_CHANGED');

	E:Mover(bar, 'ShiftActionBar');
	
	self:AdjustMaxStanceButtons();
	self:PositionAndSizeBarShapeShift();
	self:StyleShapeShift();
	self:UpdateStanceBindings()
	
	E.numActonBars = ( E.numActonBars or 0 ) + 1
	
	E.GUI.args.actionbars.args['ShiftActionBar'] = {
		name = L['ShiftActionBar'],
		order = E.numActonBars,
		expand = true,
		type = "group",
		args = {}
	}

	E.GUI.args.actionbars.args['ShiftActionBar'].args.unlock = {
		name = L["Unlock"],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover('ShiftActionBar') 
		end,
		get = function(self)end
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.enabled = {
		name =L['Enable'],
		order = 1.1,
		type = "toggle",
		set = function(self, value)
			E.db.actionbars['stanceBar'].enabled = not E.db.actionbars['stanceBar'].enabled
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(self)
			return E.db.actionbars['stanceBar'].enabled
		end
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.DarkenInactive = {
		name = L["DarkenInactive"],
		order = 1.2,
		type = "toggle",
		set = function(self, value)	
			if E.db.actionbars['stanceBar'].style == 'darkenInactive' then
				E.db.actionbars['stanceBar'].style = 'reverted'
			else
				E.db.actionbars['stanceBar'].style = 'darkenInactive'
			end
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(self)
			return E.db.actionbars['stanceBar'].style == 'darkenInactive' and true or false
		end
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.perrow = {
		name = L["Per row"],
		order = 3.1,
		type = "slider",
		min = 1, max = 10, step = 1,
		set = function(self, value)
			E.db.actionbars['stanceBar'].buttonsPerRow = value
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(self) 
			return E.db.actionbars['stanceBar'].buttonsPerRow
		end
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.buttons = {
		name = L["Buttons"],
		order = 3,
		type = "slider",
		min = 1, max = 10, step = 1,
		set = function(self, value)
			E.db.actionbars['stanceBar'].buttons = value
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(self) 
			return E.db.actionbars['stanceBar'].buttons
		end
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.perrow = {
		name = L["Per row"],
		order = 3.1,
		type = "slider",
		min = 1, max = 10, step = 1,
		set = function(self, value)
			E.db.actionbars['stanceBar'].buttonsPerRow = value
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(self) 
			return E.db.actionbars['stanceBar'].buttonsPerRow
		end
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.size = {
		name = L["Size"],
		order = 4,
		type = "slider",
		min = 1, max = 60, step = 1,
		set = function(self, value)
			E.db.actionbars['stanceBar'].buttonsize = value
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(self) 
			return E.db.actionbars['stanceBar'].buttonsize
		end
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.spacing = {
		name = L["Spacing"],
		order = 6,
		type = "slider",
		min = 0, max = 60, step = 1,
		set = function(self, value)
			E.db.actionbars['stanceBar'].buttonspacing = value
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(self) 
			return E.db.actionbars['stanceBar'].buttonspacing
		end
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.point = {
		name = L["Point"],
		type = "dropdown",
		order = 7,
		values = DD_points,
		set = function(self, value)
			E.db.actionbars['stanceBar'].point = value
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(self)
			return E.db.actionbars['stanceBar'].point
		end,	
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.BorderOpts = {
		name = L['Borders'],
		order = 10,
		embend = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.actionbars.args['ShiftActionBar'].args.BorderOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L['Border texture'],
		values = E:GetBorderList(),
		set = function(info,value) 
			E.db.actionbars['stanceBar'].border.texture = value;
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(info) return E.db.actionbars['stanceBar'].border.texture end,
	}

	E.GUI.args.actionbars.args['ShiftActionBar'].args.BorderOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.actionbars['stanceBar'].border.color={ r, g, b, a}; 
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(info) 
			return E.db.actionbars['stanceBar'].border.color[1],
					E.db.actionbars['stanceBar'].border.color[2],
					E.db.actionbars['stanceBar'].border.color[3],
					E.db.actionbars['stanceBar'].border.color[4] 
		end,
	}

	E.GUI.args.actionbars.args['ShiftActionBar'].args.BorderOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['stanceBar'].border.size = val
			AB:PositionAndSizeBarShapeShift();
		end,
		get =function(info)
			return E.db.actionbars['stanceBar'].border.size
		end,
	}

	E.GUI.args.actionbars.args['ShiftActionBar'].args.BorderOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['stanceBar'].border.inset = val
			AB:PositionAndSizeBarShapeShift();
		end,
		get =function(info)
			return E.db.actionbars['stanceBar'].border.inset
		end,
	}


	E.GUI.args.actionbars.args['ShiftActionBar'].args.BorderOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Background texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			E.db.actionbars['stanceBar'].border.background_texture = value;
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(info) return E.db.actionbars['stanceBar'].border.background_texture end,
	}

	E.GUI.args.actionbars.args['ShiftActionBar'].args.BorderOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color", 
		hasAlpha = true,
		set = function(info,r,g,b,a) 
			E.db.actionbars['stanceBar'].border.background_color={ r, g, b, a}
			AB:PositionAndSizeBarShapeShift();
		end,
		get = function(info) 
			return E.db.actionbars['stanceBar'].border.background_color[1],
					E.db.actionbars['stanceBar'].border.background_color[2],
					E.db.actionbars['stanceBar'].border.background_color[3],
					E.db.actionbars['stanceBar'].border.background_color[4] 
		end,
	}


	E.GUI.args.actionbars.args['ShiftActionBar'].args.BorderOpts.args.backgroundInset = {
		name = L['Background offset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val) 
			E.db.actionbars['stanceBar'].border.background_inset = val
			AB:PositionAndSizeBarShapeShift();
		end,
		get =function(info)
			return E.db.actionbars['stanceBar'].border.background_inset
		end,
	}
end


do
	local scantip = CreateFrame("GameTooltip", "AleaUIActionScanLinkTooltip", nil, "GameTooltipTemplate")
		scantip:SetOwner(UIParent, "ANCHOR_NONE")
		scantip:SetScript('OnTooltipAddMoney', function()end)
		scantip:SetScript('OnTooltipCleared', function()end)
		scantip:SetScript('OnHide', function()end)
		scantip:SetScript('OnTooltipSetDefaultAnchor',function()end)
	
	local function UpdateItemButtonColor(button)
		if not button.itemcolor then
			local f = CreateFrame("Frame", nil, button, BackdropTemplateMixin and 'BackdropTemplate')
			f:SetInside()
			f:SetFrameLevel(button:GetFrameLevel()+1)
			Skins.SetTemplate(f, 'BORDERED')
			f:SetBackdropBorderColor(0,0,0,0)
			button.itemcolor = f
		end	
		
	--	print('T',	button._state_type, button._state_action)
	
		if button.artBorder then
			button.artBorder:SetBackdropBorderColor(button.artBorder.r or 0,button.artBorder.g or 0,button.artBorder.b or 0, button.artBorder.a or 1)
		end
		
		button.itemcolor:SetBackdropBorderColor(0,0,0,0)

		if button._state_type == 'action' then
			local type, id, subType, spellID = GetActionInfo(button._state_action)	
			if type == 'item' then
			
				if button._itemID ~= id then
					button._itemID = id
					
					scantip:SetAction(button._state_action)
					local name, link = scantip:GetItem()
					
					button._itemLink = link
				end
				
				local _, _, quality = GetItemInfo(button._itemLink or id)		
				if quality and quality > 1 then				
					local r, g, b, hex = GetItemQualityColor(quality);		
					
					if button.artBorder then
						button.artBorder:SetBackdropBorderColor(r*1.2, g*1.2, b*1.2, button.artBorder.a or 1)
					else
						button.itemcolor:SetBackdropBorderColor(r,g,b,1)
					end
				end
			end
		end
	end

	local addon1 = CreateFrame("Frame")
	addon1:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	addon1:RegisterEvent("PLAYER_LOGIN")
	addon1:RegisterEvent("SPELLS_CHANGED")
	if (not E.isClassic) then 
	addon1:RegisterEvent("PLAYER_TALENT_UPDATE")
	addon1:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	addon1:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	end
	addon1:SetScript("OnEvent", function(self, event, buttonID)
		self:Show()
	end)
	addon1:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = (self.elapsed or 0 ) + elapsed
		if self.elapsed < 0.05 then return end
		self.elapsed = 0
		
		for button in pairs(AB.handledbuttons or {}) do
			UpdateItemButtonColor(button)		
		end
		self:Hide()
	end)
	E:OnInit2(function()
		addon1:Show()
	end)
end