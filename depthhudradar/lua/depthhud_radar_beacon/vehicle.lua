BEACON.Name = "Vehicles"

BEACON.angle = nil
BEACON.dist  = nil
BEACON.isup  = nil

BEACON.spriteScale = 2.5
BEACON.spriteColor = nil
BEACON.spriteColorEmpty = Color(128,240,128,255)

BEACON.sprite      = dhradar_GetTexture("arrow")
BEACON.spriteAngle = nil
BEACON.spriteColorBorder = Color(0,0,0,128)

BEACON.theoScale = nil

function BEACON:FindFunction( entities , myTrashTable )
	for k,ent in pairs(entities) do
		if string.find(ent:GetClass(),"vehicle") then
			table.insert(myTrashTable,ent)
		end
	end
	return myTrashTable
end

function BEACON:DrawFunction( ent )
	self.angle, self.dist, self.isup = dhradar_CalcGetPolar( ent:GetPos() )
	//self.theoScale = math.Clamp( ent:BoundingRadius()/64, 0.3, 8 )
	
	//self.spriteColor.a = 64 + 191*(1 - self.theoScale/8)
	//self.spriteColorBorder.a = self.spriteColor.a * 0.9
	self.spriteAngle = ent:GetAngles().y - dhradar_Angles().y + 90
	
	/*local driver = ent:GetDriver()
	if (ValidEntity(driver)) then
		self.spriteColor = dhradar_GetPlayerAlternateColor( driver )
	else*/
		self.spriteColor = self.spriteColorEmpty
	/*end*/
	
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColorBorder ,      1.25*self.spriteScale, self.spriteAngle, true, 0.5)
	dhradar_DrawPin(self.sprite, self.angle, self.dist     , self.spriteColor       , 1.00*self.spriteScale, self.spriteAngle, true, 0.5)
	
	return true
end
