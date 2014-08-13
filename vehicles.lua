
local function initTeamVehicles( )
	for _, teamVehicle in ipairs( getElementsByType( 'teamVehicle' ) ) do
		setElementData( teamVehicle, 'fraction', getFractionFromName( getElementData( teamVehicle, 'team' ) ) )
		local x, y, z = getElementPosition( teamVehicle )
		local rX = getElementData( teamVehicle, 'rotX' )
		local rY = getElementData( teamVehicle, 'rotY' )
		local rZ = getElementData( teamVehicle, 'rotZ' )
		local vehicle = createVehicle( getElementData( teamVehicle, 'model' ), x, y, z, rX, rY, rZ )
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
	if vehicleFraction ~= playerFraction or vehicleLevel > playerLevel then
		cancelEvent()
	end
end )
