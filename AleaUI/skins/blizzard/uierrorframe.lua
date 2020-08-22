local addonName, E = ...
local varName = 'uierrorframe'
E.default_settings.skins[varName] = true

local function Skin_ErrorFrame()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	if E.IsLegion then 
		UIErrorsFrame:SetFont(E.media.default_font, 12)
		return 
	end
	--[==[
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");

	local errorsfilter = {
		[ERR_SPELL_COOLDOWN] = false,
		[ERR_ABILITY_COOLDOWN] = false,
		[SPELL_FAILED_TARGETS_DEAD] = false,
		[SPELL_FAILED_SPELL_IN_PROGRESS] = false, --Выполняется другое действие.
		[SPELL_FAILED_INTERRUPTED_COMBAT] = false, --Прервано
		[SPELL_FAILED_CUSTOM_ERROR_132] = false, --У вас нет цели.
		[SPELL_FAILED_UNIT_NOT_INFRONT] = false, --Цель должна быть перед вами.
		[SPELL_FAILED_SPELL_IN_PROGRESS] = false, --Выполняется другое действие
		[ERR_TOO_FAR_TO_INTERACT] = "Слишком далеко", --Чтобы взаимодействовать с выбранной целью, вы должны подойти поближе.
		[ERR_ITEM_COOLDOWN] = false, --Предмет пока недоступен.
		[ERR_OUT_OF_RANGE] = false, --Слишком далеко.
		[SPELL_FAILED_MOVING] = false, --Невозможно делать это на ходу.
		[ERR_ITEM_COOLDOWN] = false, --Предмет пока недоступен.
		[ERR_OUT_OF_BURNING_EMBERS] = false, --Недостаточно раскаленных углей
		[SPELL_FAILED_TARGET_AURASTATE] = false, --Вы пока не можете это сделать.
	}

	UIErrorsFrame:SetFont(E.media.default_font, 12)

	local errorevents = CreateFrame("Frame")
	errorevents:RegisterEvent("UI_ERROR_MESSAGE")
	errorevents:SetScript("OnEvent", function(self, event, id, msg)
		if errorsfilter[msg] == false then return end
		if errorsfilter[msg] then
			UIErrorsFrame:AddMessage(errorsfilter[msg], 1.0, 0.1, 0.1, 1.0)
		else
			UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
		end
	end)
	]==]
end


E:OnInit2(Skin_ErrorFrame)