local spawnsByTeam = {}

local DEFAULT_SKIN = 147

function spawnPointInit()
	local spawns = getElementsByType( 'spawnpoint' )
	local teamsByName = {}
	for key, team in pairs( getElementsByType( 'team' ) ) do
		spawnsByTeam[team] = {}
		teamsByName[ getTeamName( team ) ] = team
		outputDebugString( getTeamName( team ) )
	end
	for i = 1, #spawns do
		local spawnpoint = spawns[i]
		local spawnpointTeam = getElementData( spawnpoint, 'team' )
		table.insert( spawnsByTeam[ teamsByName[spawnpointTeam] ], spawnpoint )
	end

	local mustRegister = get( 'onlyRegisterPlayer' )
	for _, player in pairs( getElementsByType( 'player' ) ) do
		if not ( mustRegister and isGuestAccount( getPlayerAccount( player ) ) ) then
			spawn( player )
		end
	end
end
addEventHandler( 'onGamemodeMapStart', root, spawnPointInit )

function spawn( player, spawnID )
	if not player or getElementType( player ) ~= 'player' then return false; end
	local team = getPlayerTeam( player )
	if not team then
		outputDebugString( 'Not team', 2 )
		return false
	end
	if not spawnID or not spawnsByTeam[team][spawnID] then
		spawnID = math.random( 1, #spawnsByTeam[team] )
	end
	local x, y, z = getElementPosition( spawnsByTeam[team][spawnID] )
	spawnPlayer( player, x, y, z, getElementData( spawnsByTeam[team][spawnID], 'rotZ' ), getElementData( player, 'skin' ) or DEFAULT_SKIN, 
			getElementData( spawnsByTeam[team][spawnID], 'interior' ), 0, team )
	setCameraTarget ( player, player )
	fadeCamera( player, true, 3.5 )
end
