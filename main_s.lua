g_Players = {}

local function initPlayer( player )
	player = player or source
	local nextID = #g_Players + 1
	g_Players[nextID] = source
	setElementData( source, "ID", nextID )
end
addEventHandler("onPlayerJoin", root, initPlayer )

addEventHandler ( "onResourceStart", resourceRoot, function()
	initScoreboardColums()
  for key, player in pairs( getElementsByType( "player" ) ) do
  	initPlayer( player )
  end
end )

addEventHandler ( "onPlayerQuit", root, function()
  g_Players[ getElementData( source, "ID" ) ] = nil
end )

addEventHandler ( "onPlayerWasted", root, function ( ammo, killer, killerWeap )
	local deathCount = ( getElementData( source, 'DM-Death' ) or 0 ) + 1
	setElementData( source, 'DM-Death', deathCount, false )
	setElementData ( source, "kd", ( getElementData( source, 'DM-Kills' ) or 0 ) .."/".. deathCount )
	takePlayerMoney ( source, 50 )
	fadeCamera( source, false, 8 )
	setTimer( spawn, 4000, 1, source )
	
	if killer and getElementType(killer) == "player" then
		local killsCount = ( getElementData( source, 'DM-Kills' ) or 0  ) + 1
		setElementData( killer, 'DM-Kills', killsCount, false )
		setElementData( killer, "kd", killsCount .."/".. ( getElementData( killer, 'DM-Death' ) or 0 ) )
		givePlayerMoney ( killer, 75 )
	end
end )

