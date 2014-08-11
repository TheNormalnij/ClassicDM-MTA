local spawnsByTeam = {}

local DEFAULT_SKIN = 147

function spawnPointInit()
  local spawns = getElementsByType( 'spawnpoint' )
  local teamsByName = {}
  for i, team in pairs( getElementsByType( 'team' ) ) do
    teamsByName[ getTeamName( team ) ] = team
  end
  for i = 1, #spawns do
    spawnsByTeam[ teamsByName[ getElementData( spawns[i], 'Team' ) ] ]
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
  local team = getTeamFromName( getElementData( player, 'Team' ) )
  if not spawnID or not spawnsByTeam[team][spawnID] then
    spawnID = math.random( 1, #spawnsByTeam[team] )
  end
  local x, y, z = getElementPosition( spawns[spawnID] )
  spawnPlayer( player, x, y, z, getElementData( spawnsByTeam[team[spawnID], 'rotZ' ), getElementData( player, 'skin' ) or DEFAULT_SKIN, 
      getElementData( spawnsByTeam[team][spawnID], 'interior' ), 0, team )
  setCameraTarget ( player, player )
  fadeCamera( player, true, 3.5 )
end
