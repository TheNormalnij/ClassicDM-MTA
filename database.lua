
local sqlLink = dbConnect ( "sqlite", "database.db" )

addEvent( 'onPlayerLoad' )
addEvent( 'onFractionLoad' )

function databaseRegisterFraction( fraction )
	dbExec( sqlLink,
		[[INSERT INTO fractions ( name, owner ) VALUES ( ?, ? );]],
		fraction.name, fraction.owner or ''
	)
end

local function loadFractionMemberList( fraction )
	dbQuery( function( queryHandle )
		local resultTable, num, err = dbPoll( queryHandle, 0 )
		if resultTable then
			local memberList = {}
			fraction.memberList = memberList
			for i = 1, #resultTable do
				local data = resultTable[i]
				memberList[ data.account ] = { level = data.level }
			end
			triggerEvent( 'onFractionLoad', root, fraction )
		elseif resultTable == nil then
			dbFree(queryHandle)
		elseif resultTable == false then
			outputDebugString('Ошибка в запросе, код '..num..': '..err)
		end
	end, sqlLink, "SELECT account, level FROM players WHERE fractionID = ?;", fraction.id )
end

local function loadFractions( )
	-- fraction load
	dbQuery( function( queryHandle )
		local resultTable, num, err = dbPoll( queryHandle, 0 )
		if resultTable then
			local fractionCount = #resultTable
			if fractionCount == 0 then
				createDefaultFraction()
			end
			for i = 1, fractionCount do
				local fractionData = resultTable[i]
				local fraction = Fraction:create( fractionData.name )
				fraction.id = fractionData.id
				fraction.leader = fractionData.owner
				loadFractionMemberList( fraction )
			end
		elseif resultTable == nil then
			dbFree(queryHandle)
			createDefaultFraction()
		elseif resultTable == false then
			outputDebugString('Ошибка в запросе, код '..num..': '..err)
		end
	end, sqlLink, "SELECT * FROM fractions;" )
end

function loadPlayer( player )
	local accountName = getPlayerAccountName( player )
	if not accountName then return end
	dbQuery( function( queryHandle )
		local resultTable, num, err = dbPoll( queryHandle, 0 )
		if resultTable then
			local playerData = resultTable[1]
			setElementData( player, 'DM-Kills', playerData.kills, false )
			setElementData( player, 'DM-Death', playerData.death, false )
			setElementData( player, "kd", playerData.kills .."/".. playerData.death )
			local fraction = getFractionFromName( playerData.fractionID )
			spawnPlayer( player, playerData.x, playerData.y, playerData.z, 0,
				playerData.skin, playerData.interior, 0, fraction and fraction.team
				or getTeamFromName( 'Default' ) or nil )
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
	end, sqlLink, "SELECT * FROM players WHERE account = ? ;", accountName )
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
	loadFractions()
end )

local function saveFractions( )
	for name, fraction in pairs( fractions ) do
		dbExec( sqlLink,
			[[UPDATE fractions SET owner = ? WHERE id=?]],
			fraction.leader, fraction.id
		)
	end
end 

function savePlayer( player )
	local accountName = getPlayerAccountName( player )
	if not accountName then return end
	local fraction = getPlayerFraction( player )
	local x, y, z = getElementPosition( player )
	dbExec( sqlLink,
		[[INSERT OR REPLACE INTO players( id, account, fractionID, level,
			kills, death, money, health, armor, weapons, skin, lastJoin,
			posX, posY, posZ, interior) VALUES(
			(SELECT id FROM players WHERE account = ? ),
			?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)]],
		accountName, accountName,
		fraction and fraction.id or '',
		fraction and fraction:getMemberData( player ).level or 0,
		getElementData( player, 'DM-Kills' ) or 0,
		getElementData( player, 'DM-Death' ) or 0,
		getPlayerMoney ( player ),
		getElementHealth ( player ),
		getPedArmor ( player ),
		'',
		getPedSkin( player ),
		getRealTime( ).timestamp,
		x, y, z, getElementInterior( player )
	)
end

function saveAllPlayers( )
	for key, player in pairs( getElementsByType( 'player' ) ) do
		savePlayer( player )
	end
end

addEventHandler( 'onResourceStop', resourceRoot, function( )
	saveFractions()
end )
