util.AddNetworkString("ToggleMessage");

registered_teams = {};

hook.Add("PlayerCanHearPlayersVoice", "CanSameTeamHearEachOther", function(plyOne, plyTwo)
	for k,v in pairs(registered_teams) do
		if (v[plyOne:Team()] && v[plyTwo:Team()] && plyOne:GetNWInt("GroupChatActivated", 0) == 1 && plyTwo:GetNWInt("GroupChatActivated", 0) == 1) then
						print("TALKING");

			return true;
		end
	end
end)

hook.Add("PlayerSay", "ToggleTeamChat", function(ply, text)
	if (text == "!vt" or text == "!voicetogg") then
		if (ply:GetNWInt("GroupChatActivated", 0) == 0) then ply:SetNWInt("GroupChatActivated", 1); 
		else ply:SetNWInt("GroupChatActivated", 0); end
	end
end)

function GAMEMODE:AddTeamVoiceChat(...)
	table.insert(registered_teams, {...});
end