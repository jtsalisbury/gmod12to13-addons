BEACON.Name = "Wire Expressions"


BEACON.angle = nil
BEACON.dist  = nil
BEACON.isup  = nil

BEACON.spriteScale = 0.5
BEACON.spriteColor = Color(192,0,0,255)
BEACON.sprite      = nil
BEACON.spriteAngle = nil
BEACON.spriteColorShadow = Color(0,0,0,128)

function BEACON:FindFunction( entities , myTrashTable )
	for k,ent in pairs(entities) do
		if ent:GetClass() == "gmod_wire_expression2" then
			table.insert(myTrashTable,ent)
		end
	end
	return myTrashTable
end

function BEACON:DrawFunction( ent )

	self.angle, self.dist, self.isup = dhradar_CalcGetPolar( ent:GetPos() )
	self.sprite, self.spriteAngle = dhradar_CalcGenericAltitudeSprite(self.isup, dhradar_GetTexture("square"), dhradar_GetTexture("triangle"), 45, 0, 180)
	
	//Shadow
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColorShadow , 1.25*self.spriteScale, self.spriteAngle)
	//Pin
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColor       , 1.00*self.spriteScale, self.spriteAngle)
	
	return true
end
