--
--The MIT License (MIT)
--Copyright (c) 2014 TheNormalnij, CoolDark
--
--See LICENSE file
--

addEvent( 'onPlayerRegister' )

local PREFFIX = 'LOTRS-DM.'

addEventHandler ( "onPlayerQuit", root, function()
	local acc = getPlayerAccount( source )
	if not acc or isGuestAccount( acc ) then
		return
	end
	
	local guns = { }
	local ammo = { }
	for slot = 0, 12 do
		guns[slot + 1] = getPedWeapon ( source, slot )
		ammo[slot + 1] = getPedTotalAmmo ( source, slot )
	end
	setAccountData ( acc, PREFFIX .. "Weapons", toJSON( guns ) )
	setAccountData ( acc, PREFFIX .. "Ammo", toJSON( ammo ) )
	setAccountData ( acc, PREFFIX .. "playerHealth", getElementHealth ( source ) )
	setAccountData ( acc, PREFFIX .. "Money", getPlayerMoney ( source ) )
	setAccountData ( acc, PREFFIX .. "Kills", getElementData( source, 'DM-Kills' ) or 0 )
	setAccountData ( acc, PREFFIX .. "Death", getElementData( source, 'DM-Death' ) or 0 )
end )

addEventHandler( 'onPlayerRegister', root, function( acc )
	givePlayerMoney ( source, 1000 )
end )

addEventHandler ( "onPlayerLogin", root, function( _, acc )
	local kills = getAccountData( acc, PREFFIX .. "Kills" ) or 0
	local death = getAccountData( acc, PREFFIX .. "Death" ) or 0
	setElementData( source, 'DM-Kills' kills, false )
	setElementData( source, 'DM-Death' death, false )
	setElementData( source, "kd", kills .."/".. death )
	
	givePlayerMoney ( source, getAccountData ( acc, PREFFIX .. "Money" ) )
	setElementHealth ( source, getAccountData ( acc, PREFFIX .. "playerHealth" ) )
	
	local weapons = fromJSON( getAccountData ( acc, PREFFIX .. "Weapons" ) or '[ ]' )
	local ammo = fromJSON( getAccountData ( acc, PREFFIX .. "Ammo" ) or '[ ]' )
	
	for _, weaponID in pairs( weapons ) do
		giveWeapon ( source, weaponID ) -- tonumber???
	end	
	for slot, ammoCount in pairs( ammo ) do
		setWeaponAmmo( source, weapons[slot], ammoCount )
	end
end )

addEventHandler( 'onPlayerLogout', root, cancelEvent )

