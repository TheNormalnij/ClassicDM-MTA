
fractions = {}

Fraction = {}
Fraction.__index = Fraction

function Fraction:create( name, vColor )
	if type( name ) == 'string' and #name > 0 and not fractions[name] then
		local newFraction = {}
		setmetatable( newFraction, self )
		newFraction.name = name
		newFraction.team = createTeam( name, vColor and unpack( vColor ) )
		newFraction.leaderLevel = 3
		newFraction.memberList = {}
		newFraction.weaponsByLevel = {}
		fractions[name] = newFraction
		return newFraction
	end
	return false
end

function Fraction:setLeader( player )
	if player and isElement( player ) and getElementType( player ) == 'player' then
		local accountName = getPlayerAccountName( player )
		if accountName then
			self.leader = accountName
			return true
		end
	end
	return false
end

function Fraction:addMember( player, level )
	level = level or 1
	local accountName = getPlayerAccountName( player )
	if not accountName then
		return false
	end
	setPlayerTeam( player, self.team )
	self.memberList[accountName] = { level = level }
	return true
end

function Fraction:removeMember( player )
	local accountName = getPlayerAccountName( player )
	if accountName and self.memberList[accountName] then
		self.memberList[accountName] = nil
		return true
	end
	return false
end

--[[
	table memberData
		memberData.level - int Player level
]]

function Fraction:getMemberData( player )
	local accountName = getPlayerAccountName( player )
	return accountName and self.memberList[accountName] or false
end

function Fraction:setMemberLevel( player, level )
	local memberData = self:getMemberData( player )
	if memberData 
		and type( level ) == 'number'
		and level >= 1 and level <= self.leaderLevel then

		memberData.level = level
		return true
	end
	return false
end

--

function getFractionFromName( name )
	return name and fractions[name] or false
end

function getFractionFromTeam( team )
	if team	and isElement( team ) and getElementType( team ) == 'team' then
		for name, fraction in pairs( fractions ) do
			if fraction.team == team then
				return fraction
			end
		end
	end
	return false
end

function getFractionFromID( id )
	for name, fraction in pairs( fractions ) do
		if fraction.id == id then
			return fraction
		end
	end
end

function getPlayerFraction( player )
	local team = getPlayerTeam( player )
	if team then
		return getFractionFromTeam( team )
	end
end

--

addEventHandler( 'onPlayerLoad', root, function( accountName )
	local fraction = getPlayerFraction( source )
	if fraction then
		fraction.memberList[accountName].player = source
	end
end )

addEventHandler( 'onPlayerQuit', root, function( )
	local fraction = getPlayerFraction( source )
	local accountName = getPlayerAccountName( source )
	if fraction and accountName then
		fraction.memberList[accountName].player = nil
	end
end )

addEventHandler( 'onPlayerSpawn', root, function( x, y, z, rotZ, team )
	local fraction = getFractionFromTeam( team )
	if fraction then
		local level = farction:getMemberData( source ).level
		if fraction.weaponsByLevel[level] then
			for key, weaponsData in pairs( fraction.weaponsByLevel[level] ) do
				giveWepon( source, weaponsData[1], weaponsData[2] )
			end
		end
	end
end )

-- Client-server

addEvent( 'getFractionMemberList', true )

addEventHandler( 'getFractionMemberList', root, function( name )
	if fractions[name] then
		triggerClientEvent( client, 'onGetFractionMemberList', root, fraction[name].memberList )
		return true
	end
	triggerClientEvent( client, 'onGetFractionMemberList', root, 'ERROR:Invalid fraction' )
end )
