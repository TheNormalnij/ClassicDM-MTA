
function getPlayerAccountName( player )
	local account = getPlayerAccount( player )
	if not isGuestAccount( account ) then
		return getAccountName( account )
	end
	return false
end
