local scoreboard = getResourceFromName( 'scoreboard' )

function initScoreboardColums()
	exports.scoreboard:scoreboardAddColumn( "kd", root, 75, "Kills/Death", 2 )
	exports.scoreboard:scoreboardAddColumn( "ID", root, 35, "ID", 1 )
end
addEventHandler( 'onResourceStart', getResourceRootElement( scoreboard ), initScoreboardColums )
