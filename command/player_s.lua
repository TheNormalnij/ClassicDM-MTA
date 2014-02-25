--
--The MIT License (MIT)
--Copyright (c) 2014 CoolDark
--
--See LICENSE file
--

addCommandHandler ( "pm", function ( source, cmd, id, ... )
	id = tonumber( id )
	if not ( id or ... ) then
		outputChatBox( "#F20010[Syntax]: /" .. cmd .. " id text", source, 255, 255, 255, true )
		return
	end
	local targetPlayer = g_Players[id]
	if targetPlayer == source then
		outputChatBox( "#F20010You can not write yourself", source, 255, 255, 255, true  )
		return
	end
	local text = table.concat ( { ... }, " " )
	if targetPlayer then
		outputChatBox ( "#F2F200Message to #08F200".. getPlayerName ( targetPlayer ) .." #F2F200: " .. text, source, 255, 255, 255, true )
		outputChatBox ( "#F2F200Message from #08F200".. getPlayerName ( source ) .." #F2F200: " .. text, targetPlayer, 255, 255, 255, true )
	else
		outputChatBox( "#F20010Player not found", source, 255, 255, 255, true  )
	end
end )

addCommandHandler ( "pay",
	function ( player, cmd, id, amount )
		if tonumber ( amount ) then
			if (tonumber ( amount ) > 0 and getPlayerMoney( player ) >= tonumber( amount ) ) then
				if player ~=  g_Players[tonumber (id)] then
					if g_Players[tonumber ( id )] ~= nil then
						takePlayerMoney ( player, amount )
						outputChatBox ( "#F2F200You paid #08F200".. getPlayerName (g_Players[tonumber (id)]) .." #F2F200: " .. amount .. "$", player, 255, 255, 255, true )
						givePlayerMoney ( g_Players[tonumber (id)], amount )
						outputChatBox ( "#F2F200You got money from #08F200".. getPlayerName ( player ) .." #F2F200: " .. amount .. "$", g_Players[tonumber (id)], 255, 255, 255, true )
					else
						outputChatBox ( "#F20010[Syntax]: /pay id amount", player, 255, 255, 255, true )
					end
				else
					outputChatBox ( "#F20010You can not pay yourself", player, 255, 255, 255, true  )
				end
			else
				outputChatBox ( "#F20010You do not have enough money", player, 255, 255, 255, true  )
			end
		else
			outputChatBox ( "#F20010[Syntax]: /pay id amount", player, 255, 255, 255, true )
		end
	end
)
