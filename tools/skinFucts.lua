--
--The MIT License (MIT)
--Copyright (c) 2014 CoolDark
--
--See LICENSE file
--

function getSkinNameFromId( id )
	if id then
		return skins[id] or false
	end
end

function getSkinIdFromName( name )
	if name then
		for k,v in pairs(skins) do
			if(v == name) then return k end
		end
	end
end