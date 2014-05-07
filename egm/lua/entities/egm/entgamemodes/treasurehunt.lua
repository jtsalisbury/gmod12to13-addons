--DO NOT EDIT BELOW------------------------------------------
RegisterNewGamemode("Treasure Hunt", "TreasureHunt.lua", "Find the treasure before the other players!", function() TreasureStart() end)
-------------------------------------------------------------
--Admin Vars
TreasureModel = "models/Combine_Helicopter/helicopter_bomb01.mdl" -- what do you want the model of the treasure to be?

--DO NOT EDIT BELOW------------------------------------------

if(SERVER)then

	function TreasureStart()
		
		local SpawnVector = RandomizeXYZ()
		
		Treasure = ents.Create("prop_physics")
		Treasure:SetModel(TreasureModel)
		Treasure:SetPos(SpawnVector)
		Treasure:SetColor(207,152,34,200)
		Treasure:SetUseType(SIMPLE_USE)
		
		Treasure:Spawn()
		
	end
 
	function RandomizeXYZ()
		
		local RandPly = math.random(1, #player.GetAll())
		local Xoffset, Yoffset = 0,0
	

			for k,v in pairs(player.GetAll()) do
				
				Xoffset = Xoffset + v:GetPos().x
				Yoffset = Yoffset + v:GetPos().y
				
				if (k == RandPly) then
				
					ZValue = v:GetPos().z
					
				end
			end
				
				local AverX = (Xoffset/#player.GetAll())
				local AverY = (Yoffset/#player.GetAll())
				
				local RandX = math.Rand(-(AverX),AverX)
				local RandY = math.Rand(-(AverY),AverY)
				
				local OutputVector = Vector(RandX,RandY,ZValue)

		return OutputVector
	end
	
	function TreasureFound(activator, entity)
	if not(ACTIVEGAMEMODE == "Treasure Hunt") then return end
		if ( activator:IsPlayer() and entity == Treasure) then
			for _,v in pairs(player.GetAll()) do
				v:PrintMessage( HUD_PRINTTALK , activator:Nick() .." has found the treasure!")
			end
			Treasure:Remove()
			ACTIVEGAMEMODE = false
		end
	end
	hook.Add( "PlayerUse", "TreasureFound", TreasureFound )
	
	function THAdminEnd(ply,cmd,args)
		if(ply:IsAdmin() or !ply:IsValid())then
			Treasure:Remove()
			ACTIVEGAMEMODE = false
		end
	end
	concommand.Add("EndTH", THAdminEnd)
end