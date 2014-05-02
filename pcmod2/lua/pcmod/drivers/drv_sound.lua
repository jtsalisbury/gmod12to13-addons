
// Sound Driver for PCMod 2
// Controls the sound

DRV = PCMod.DeriveDriver( "base" )

DRV.NiceName = "Sound Control"
DRV.Name = "gen_sound"
DRV.Type = "sound"

DRV.SndPorts = {}

function DRV:Initialize()
	if (!self.Entity) then return end
	
	self.Entity:AddEHook( "driver", self.Name, "linked" )
	self.Entity:AddEHook( "driver", self.Name, "unlinked" )
	self.Entity:AddEHook( "driver", self.Name, "snd_stop" )
	self.Entity:AddEHook( "driver", self.Name, "snd_play" )
	
	for k, v in pairs( self.Entity:Ports() ) do
		if (v.Type == "minijack") then
			table.insert( self.SndPorts, k )
		end
	end
end

function DRV:CallEvent( data )
	if ((!data) || (!data.Event)) then return end
	local e = data.Event
	PCMod.Msg( "Sound Driver CallEvent called! (" .. e .. ")", true )
	if (e == "snd_stop") then
		local dat = { "snd_stop" }
		for _, v in pairs( self.SndPorts ) do
			local pt = self.Entity:Ports()[ v ]
			self.Entity:PushData( pt, dat )
		end
		return
	end
	if (e == "snd_play") then
		local dat = { "snd_play", data[1] }
		for _, v in pairs( self.SndPorts ) do
			local pt = self.Entity:Ports()[ v ]
			self.Entity:PushData( pt, dat )
		end
		return
	end
end

function DRV:PlaySound( snd )
	self:CallEvent( { Event = "snd_play", [1] = snd} )
end

function DRV:StopSounds()
	self:CallEvent( { Event = "snd_stop" } )
end