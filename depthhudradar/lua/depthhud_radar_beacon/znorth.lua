BEACON.Name = "North Sign"

function BEACON:FindFunction( entities , myTrashTable )
	myTrashTable = { LocalPlayer() }
	return myTrashTable
end

function BEACON:DrawFunction( ent )
	local spriteAngle = - dhradar_Angles().y + 90

	dhradar_DrawPin(dhradar_GetTexture("circle")     , -90, 0.97, dhradar_GetStyleData("color_ring")     , 1.9, spriteAngle)
	dhradar_DrawPin(dhradar_GetTexture("circle")     , -90, 0.97, Color(0,0,0,255) , 1.5, spriteAngle)
	dhradar_DrawText("N", -90, 0.97, Color(255,255,255,255))
	
	return true
end
