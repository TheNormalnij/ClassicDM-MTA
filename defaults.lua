
local defaultFractions = { 
	Police = { color = { 42, 82, 90 } };
	Yakuza = { color = { 255, 36, 0 } };
}

function createDefaultFraction()
	for fractionName, data in pairs( defaultFractions ) do
		local farction = Fraction:create( fractionName, data.color )
		databaseRegisterFraction( farction )
	end
end
