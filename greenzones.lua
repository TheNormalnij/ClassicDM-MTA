
local function blockPlayerDamage( attacker )
	if attacker and attacker ~= source then
		cancelEvent()
	end
end

local function onInGreenZone( element )
	if getElemenType( element ) == 'player' then
		addEventHandler( 'onPlayerDamage', element, blockPlayerDamage )
		toggleControl ( element, "fire", false )
		toggleControl ( element, "vehicle_fire", false )
		toggleControl ( element, "vehicle_secondary_fire", false )
	end
end

local function onOutGreenZone( element )
	if getElemenType( element ) == 'player' then
		removeEventHandler( 'onPlayerDamage', element, blockPlayerDamage )
		toggleControl ( element, "fire", true )
		toggleControl ( element, "vehicle_fire", true )
		toggleControl ( element, "vehicle_secondary_fire", true )
	end
end

addEventHandler( 'onGamemodeMapStart', root, function( )
	for key, greenZone in pairs( getElementsByType( 'greenzone' ) ) do
		local x, y, z = getElementPosition( greenZone )
		local sW = getElementData( greenZone, 'width' )
		local sD = getElementData( greenZone, 'depth' )
		local sH = getElementData( greenZone, 'height' )
		local col = createColCuboid( x, y, z, sW, sD, sH )
		setElementParent( col, greenZone )
		addEventHandler( 'onColShapeHit', col, onInGreenZone )
		addEventHandler( 'onColShapeLeave', col, onOutGreenZone )
	end
end )
