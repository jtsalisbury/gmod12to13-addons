BEACON.Name        = "Revealer (!)"
BEACON.DefaultOff  = true

BEACON.AngleIsEntityYaw        = true
BEACON.AngleIsRadarOrientation = false
BEACON.AngleAdd                = 0

BEACON.angle = nil
BEACON.dist  = nil
BEACON.isup  = nil

BEACON.spriteScale = 1
BEACON.spriteColor = Color(255,255,255)
BEACON.sprite      = dhradar_GetTexture("arrow")
BEACON.spriteAngle = nil
BEACON.spriteColorShadow = Color(0,0,0,128)


function BEACON:FindFunction( entities , myTrashTable )
	for k,ent in pairs(entities) do
		if not (ent:IsWeapon()) and not (ent:GetClass() == "viewmodel") and not (ent:IsPlayer()) then
			table.insert(myTrashTable,ent)
		end
	end
	return myTrashTable
end

function BEACON:DrawFunction( ent )
	self.angle, self.dist, self.isup = dhradar_CalcGetPolar( ent:GetPos() )
	
	if (self.AngleIsEntityYaw) then
		self.spriteAngle  = ent:GetAngles().y - dhradar_Angles().y + 90 + self.AngleAdd
	elseif (self.AngleIsRadarOrientation) then
		self.spriteAngle  = -dhradar_Angles().y + 90 + self.AngleAdd
	else
		self.spriteAngle  = 0 + self.AngleAdd
	end
	
	if self.dist < 1 and (GetConVarNumber("dhradar_ui_showplayernames") > 0) then
		dhradar_DrawText( ent:GetClass(), self.angle, self.dist + 0.10, self.spriteColor, false )
	end
	
	dhradar_DrawPin( self.sprite, self.angle, self.dist, self.spriteColor, 0.95*self.spriteScale, self.spriteAngle, true, 0.5)
	
	return true
end
