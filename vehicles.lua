
local function initTeamVehicles( )
	for _, teamVehicle in ipairs( getElementsByType( 'teamVehicle' ) ) do
		setElementData( teamVehicle, 'fraction', getFractionFromName( getElementData( teamVehicle, 'team' ) ) )
		local x, y, z = getElementPosition( teamVehicle )
		local rX, rY, rZ = getElementRotation( teamVehicle )
		local vehicle = createVehicle( getElementData( teamVehicle, 'model' ), x, y, z + 1, rX, rY, rZ )
		setElementParent( vehicle, teamVehicle )
		setVehicleRespawnPosition( vehicle, x, y, z, rX, rY, rZ )
	end
end
addEventHandler( 'onResourceStart', resourceRoot, initTeamVehicles )
addEventHandler( 'onGamemodeMapStart', root, initTeamVehicles )

addEventHandler( 'onVehicleStartEnter', root, function( player )
	local vehicleFraction = getElementData( source, 'fraction' )
	if not vehicleFraction then return end
	local vehicleLevel = getElementData( source, 'level' )
	local playerFraction = getPlayerFraction( player )
	local playerLevel = playerFraction and playerFraction:getMemberData( player ).level
	if vehicleLevel > playerLevel or vehicleFraction ~= playerFraction then
		cancelEvent()
	end
end )
