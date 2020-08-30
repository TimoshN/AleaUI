local addOn, E = ...

local versionStr, internalVersion, dateofpatch, uiVersion = GetBuildInfo(); 
internalVersion = tonumber(internalVersion)

local uibuild = tonumber(uiVersion)

if ( uibuild < 90000 ) then return end 

E.UNIT_HEALTH_EVENT = 'UNIT_HEALTH'

function E.GetCurrencyIcon(...)
    local result = C_CurrencyInfo.GetCurrencyInfo(...)
    
    if not result then return end 

    return result.iconFileID
end

function E.GetBackpackCurrencyInfo(...)
	local currencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo(...);
	if currencyInfo then
		return currencyInfo.name,
			   currencyInfo.quantity,
			   currencyInfo.currencyTypesID,
			   currencyInfo.iconFileID
	end
end


function E.UnitInPhase(...)
    return not UnitPhaseReason(...)
end 