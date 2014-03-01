local spawns = {}

local DEFAULT_SKIN = 147

function spawnPointInit()
  spawns = getElementsByType( 'spawnpoint' )
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
  if not spawnID or not spawns[spawnID] then
    spawnID = math.random( 1, #spawns )
  end
  local x, y, z = getElementPosition( spawns[spawnID] )
  spawnPlayer( player, x, y, z, getElementData( spawns[spawnID], 'rotZ' ), getElementData( player, 'skin' ) or DEFAULT_SKIN, 
      getElementData( spawns[spawnID], 'interior' ) )
  setCameraTarget ( player, player )
  fadeCamera( player, true, 3.5 )
end
