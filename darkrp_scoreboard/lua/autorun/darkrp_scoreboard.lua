if SERVER then 

	AddCSLuaFile( "autorun/darkrp_scoreboard.lua" )
	AddCSLuaFile( "scoreboard/admin_buttons.lua" )
	AddCSLuaFile( "scoreboard/player_frame.lua" )
	AddCSLuaFile( "scoreboard/player_infocard.lua" )
	AddCSLuaFile( "scoreboard/player_row.lua" )
	AddCSLuaFile( "scoreboard/scoreboard.lua" )
	AddCSLuaFile( "scoreboard/vote_button.lua" )

	return
end

include("scoreboard/scoreboard.lua")

local pScoreBoard = nil

/*---------------------------------------------------------
Name: gamemode:CreateScoreboard()
Desc: Creates/Recreates the scoreboard
---------------------------------------------------------*/
local function CreateScoreboard()
	if pScoreBoard then
		pScoreBoard:Remove()
		pScoreBoard = nil
	end

	pScoreBoard = vgui.Create("RPScoreBoard")
end

/*---------------------------------------------------------
Name: gamemode:ScoreboardShow()
Desc: Sets the scoreboard to visible
---------------------------------------------------------*/
local function ScoreboardShow()

	GAMEMODE.ShowScoreboard = true
	gui.EnableScreenClicker(true)

	if not pScoreBoard then
		CreateScoreboard()
	end

	pScoreBoard:SetVisible(true)
	pScoreBoard:UpdateScoreboard(true)

	return true
end

/*---------------------------------------------------------
Name: gamemode:ScoreboardHide()
Desc: Hides the scoreboard
---------------------------------------------------------*/
hook.Add( "ScoreboardHide", "DarkRP_Override_H", function()
	GAMEMODE.ShowScoreboard = false
	gui.EnableScreenClicker(false)
	if pScoreBoard then
		pScoreBoard:SetVisible(false)
	end
end )


hook.Add( "InitPostEntity", "HackyScoreBoardFix", function()

	GAMEMODE.ScoreboardShow = ScoreboardShow

end )