
local sqlLink = dbConnect ( "sqlite", "database.db" )

addEvent( 'onPlayerLoad' )
addEvent( 'onFractionLoad' )

local function loadFractionMemberList( fraction )
	dbQuery( function( queryHandle,
		local resultTable, num, err = dbPoll( queryHandle, 0 )
		if resultTable then
			local memberList = {}
			fraction.memberList = memberList
			for i = 1, #resultTable do
				local data = resultTable[i]
				memberList[ data.account ] = { level = data.level }
			end
			triggerEvent( 'onFractionLoad' )
		elseif resultTable == nil then
			dbFree(queryHandle)
		elseif resultTable == false then
			outputDebugString('Ошибка в запросе, код '..num..': '..err)
		end
	end, sqlLink, "SELECT account, level FROM players WHERE fractionID = ?;", fraction.id )
end

local function loadFractions( )
	-- fraction load
	dbQuery( function( queryHandle,
		local resultTable, num, err = dbPoll( queryHandle, 0 )
		if resultTable then
			for i = 1, #resultTable do
				local fractionData = resultTable[i]
				local fraction = Fraction( fractionData.name )
				fraction.id = fractionData.id
				fraction.leader = fractionData.owner
				loadFractionMemberList( fraction )
			end
		elseif resultTable == nil then
			dbFree(queryHandle)
		elseif resultTable == false then
			outputDebugString('Ошибка в запросе, код '..num..': '..err)
		end
	end, sqlLink, "SELECT * FROM fractions;" )
end

local function loadPlayer( player )
	local accountName = getPlayerAccountName( player )
	if not accountName then return end
	dbQuery( function( queryHandle,
		local resultTable, num, err = dbPoll( queryHandle, 0 )
		if resultTable then
			local playerData = resultTable[1]
			setElementData( player, 'DM-Kills', playerData.kills, false )
			setElementData( player, 'DM-Death', playerData.death, false )
			setElementData( player, "kd", playerData.kills .."/".. playerData.death )
			local fraction = getFractionFromName( playerData.fractionID )
			spawnPlayer( player, playerData.x, playerData.y, playerData.z, 0,
				playerData.skin, playerData.interior, 0, fraction and fraction.team or nil )
			setCameraTarget ( player, player )
			fadeCamera( player, true, 3.5 )
			givePlayerMoney ( player, playerData.money )
			setElementHealth ( player, playerData.health )
			setElementArmor ( player, playerData.armor )
			triggerEvent( 'onPlayerLoad', player, accountName )
		elseif resultTable == nil then
			dbFree(queryHandle)
		elseif resultTable == false then
			outputDebugString('Ошибка в запросе, код '..num..': '..err)
		end
	end, sqlLink, "SELECT * FROM fractions WHERE account = ? ;", accountName )
end

addEventHandler( 'onResourceStart', resourceRoot, function( )
	dbExec( sqlLink, -- AUTOINCREMENT
		[[CREATE TABLE IF NOT EXISTS players (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		account TEXT,
		fractionID INTEGER,
		level INTEGER,
		kills INTEGER,
		death INTEGER,
		money INTEGER,
		health INTEGER,
		armor INTEGER,
		weapons TEXT,
		skin INTEGER,
		lastJoin INTEGER,
		posX REAL,
		posY REAL,
		posZ REAL,
		interior INTEGER
		);]] -- datetime(...)
	)
	dbExec( sqlLink, -- AUTOINCREMENT
		[[CREATE TABLE IF NOT EXISTS fractions (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT,
		owner TEXT );]]
	)

end )

local function saveFractions( )
	for name, fraction in pairs( fractions ) do
		dbExec( sqlLink,
			[[UPDATE fractions SET owner = ? WHERE id=?]],
			fraction.leader, fraction.id
		)
	end
end 

local function savePlayer( player )
	local accountName = getPlayerAccountName( player )
	if not accountName then return end
	local fraction = getPlayerFraction( player )
	local x, y, z = getElementPosition( player )
	dbExec( sqlLink,
		[[UPDATE players SET 
		fractionID = ?,
		level = ?,
		kills = ?,
		death = ?,
		money = ?,
		health = ?,
		armor = ?,
		weapons = ?,
		skin = ?,
		lastJoin = ?,
		posX = ?,
		posY = ?,
		posZ = ?,
		interior = ?
		WHERE account = ? ]],
		fraction and fraction.id or '',
		fraction and fraction:getMemberData( player ).level or 0,
		getElementData( player, 'DM-Kills' ) or 0,
		getElementData( player, 'DM-Death' ) or 0,
		getPlayerMoney ( player ),
		getElementHealth ( player ),
		getElementArmor ( player ),
		'',
		getPedSkin( player )
		getRealTime( ).timestamp,
		x, y, z, getElementInterior( player ),
		accountName
	)
end

addEventHandler( 'onResourceStop', resourceRoot, function( )
	saveFractions()

	for key, player in pairs( getElementsByType( 'player' ) ) do
		savePlayer( player )
	end
end )

addEventHandler( 'onPlayerRegister', root, function( account )
	dbExec( sqlLink,
		[[INSERT INTO players ( account ) VALUES ( ? );]],
		getAccountName( account )
	)
end )
