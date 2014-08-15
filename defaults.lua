
local defaultFractions = { 
	Police = {
		color = { 42, 82, 90 };
		weaponsByLevel = {
			[1] = {
				{ 3,  1   };
				{ 22, 68  };
			};
			[2] = {
				{ 3,  1   };
				{ 22, 102 };
				{ 29, 180 };
			};
			[3] = {
				{ 3,  1   };
				{ 22, 119 };
				{ 31, 250 };
			};
		};
	};
	Yakuza = {
		color = { 255, 36, 0 };
			weaponsByLevel = {
			[1] = {
				{ 8,  1   };
				{ 22, 68  };
			};
			[2] = {
				{ 8,  1   };
				{ 22, 102 };
				{ 29, 180 };
			};
			[3] = {
				{ 8,  1   };
				{ 22, 119 };
				{ 30, 250 };
			};
		};
	};
}

function createDefaultFraction()
	for fractionName, data in pairs( defaultFractions ) do
		local farction = Fraction:create( fractionName, data.color )
		databaseRegisterFraction( farction )
	end
end

addEventHandler( 'onFractionLoad', root, function( fraction )
	farction.weaponsByLevel = defaultFractions[ farction.name ].weaponsByLevel
end )