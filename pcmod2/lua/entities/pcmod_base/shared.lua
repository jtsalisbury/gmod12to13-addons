
// ---------------------------------------------------------------------------------------------------------
// pcmod_base
// Base entity file for all PCMod entities
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "PCMod Entity"
ENT.Author = "[GU]thomasfn"
ENT.Category = "PCMod"
ENT.Class = "pcmod_base"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (SERVER) then

	AddCSLuaFile( "shared.lua" )

end

if (CLIENT) then

	ENT.RenderGroup = RENDERGROUP_OPAQUE

end

------------------|

	ENT.IsPCMod = true -- This entity belongs to the PCMod addon

	ENT.UseDelay = 1 -- Delay between use event fired (secs)
	ENT.NextUse = 0 -- Internal usage data

	ENT.IsScreen = false -- Does the entity have a screen?

	ENT.AlwaysOn = true -- Is the entity always on?

	ENT.ItemModel = "models/props_lab/harddrive01.mdl"

------------------|

if (SERVER) then

	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Setup Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------

		function ENT:Initialize()
		
			// Setup all our physics stuff
			self:ChangeModel( self.ItemModel )
			
			// Clear out all GVars
			self:ClearGVars()
			
			PCMod.Msg( "Creating entity derived from pcmod_base...", true )
			
			self.Entity:CallOnRemove( "Cleanup_Data_"..self.Entity:EntIndex(), function(ent)
				PCMod.Msg( "Start OnRemove", true )
				local i = 1
				if (ent.IsComputer) then
					PCMod.Msg( "Properly close programs", true )
					ent:CloseAllPrograms()
				end
				PCMod.Msg( "Unlink ports", true )
				for k, _ in pairs(ent:Ports()) do
					PCMod.Wiring.UnlinkPort( ent, k )
				end
				PCMod.Msg( "Ports unlinked, now for drivers", true )
				for k, _ in pairs(PCMod.Data[ self:EntIndex() ].Drivers) do
					PCMod.Data[ self:EntIndex() ].Drivers[ k ]:OnRemove()
				end
				PCMod.Msg( "Data!", true )
				for k, _ in pairs(PCMod.Data) do
					if (k == ent:EntIndex()) then
						table.remove( PCMod.Data, i )
					end
					i = i + 1
				end
				PCMod.Msg( "RunOnRemove!", true )
				ent:RunOnRemove()
				PCMod.Msg( "Unlinked all ports and deleted Data slot for entity "..ent:EntIndex()..", removing entity...", true )
			end, self.Entity )

			self:SetNWString( "IP", "" )
			self:SetNWString( "IP.Back", "" )

			// Set up a slot for us in the PCMod Data table
			self:CreateSlotData()
			
			// self:Setup()
			
			if (self.AlwaysOn) then self:TurnOn() end
			if (!self.AlwaysOn) then self:TurnOff() end
			
			if (self.IsScreen) then
				self:SetGVar( "mouse_enable", 0 )
			end
			
		end
		
		function ENT:Setup( setupdata )
			-- Override Compatibility
			-- Note that this will be called after our entity has been created
			-- Setupdata will contain information from the toolgun needed to spawn the entity
		end

		function ENT:ForceRemove( error )
			if (error) then
				PCMod.Notice( error, self:GetOwner() )
			end

			self:Remove()
		end
		
		function ENT:RunOnRemove()
			//Override for compatability
		end
		
		function ENT:CreateSlotData()
			local tmp = {}
			tmp.ItemType = self:GetClass()
			tmp.PortData = self.Ports
			tmp.ItemModel = self.ItemModel
			tmp.Ent = self
			tmp.IP = {}
			tmp.IP.Add = false
			tmp.IP.Sub = false
			tmp.IP.Full = false
			tmp.IP.Back = {}
			tmp.IP.Back.Add = false
			tmp.IP.Back.Sub = false
			tmp.IP.Back.Full = false
			tmp.Memory = {}
			tmp.Ports = {}
			tmp.HardDrive = {}
			tmp.Drivers = {}
			tmp.EHooks = {}
			tmp.ScreenSpace = PCMod.MakeScreenSpace()
			tmp.IsOn = false
			tmp.OS_FirstRun = true
			tmp.Password = ""
			PCMod.Data[ self:EntIndex() ] = tmp
		end


	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- OS Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------		
	

		function ENT:InstallOS( osname )
			local osd = PCMod.OSys[ osname ]
			if (!osd) then return false end
			PCMod.Data[ self:EntIndex() ].OS = table.Copy( osd )
			PCMod.Data[ self:EntIndex() ].OS:Initialize( self )
		end
		
		function ENT:GetOS()
			return PCMod.Data[ self:EntIndex() ].OS
		end
	
		function ENT:CloseAllPrograms()
			if(PCMod.Data[ self:EntIndex() ] && PCMod.Data[ self:EntIndex() ].OS) then
				PCMod.Data[ self:EntIndex() ].OS:ShutDown()
			elseif(self:Data().Drivers[ "gen_bios" ] && self:Data().Drivers[ "gen_bios" ].OS) then
				self:Data().Drivers[ "gen_bios" ].OS:ShutDown()
			else
				PCMod.Warning( "PCMod2: Cant find OS!" )
			end
		end
		
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Port Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------
	

		function ENT:CreatePort( ptype )
			local tmp = {}
			tmp.Type = ptype
			tmp.Name = PCMod.Wiring.TypeToName( ptype )
			tmp.CanWireSameType = PCMod.Wiring.CanWireSameType( ptype )
			tmp.Connected = false
			tmp.ConEnt = nil
			tmp.RemotePort = 0
			return tmp
		end
		
		function ENT:UpdatePort( pid, data )
			local dt = self:Data()
			dt.Ports[ pid ] = data
			self:UpdateData( dt )
		end
		
		// Return Code
		// 0 = success
		// 1 = invalid port
		// 2 = no connection
	
		function ENT:GivenData( portid, data )
			// Called from another entity, that is giving us data through one of our ports
			local prt = self:Ports()[ portid ]
			if (!prt) then return 1 end
			self:DataRecieved( portid, data )
			// This is causing problems when entities are recieved data that aren't packets
			if ((prt.Type == "network") || (prt.Type == "optic")) then
				local packet = data[2]
				local pid
				if (type( packet ) == "number") then
					// If we just have a PID, get the packet itself
					pid = packet
					packet = PCMod.Network.Packets[ pid ]
					if (!PCMod.Network.Packets[ pid ]) then packet = nil end
				end
				if (!packet) then
					PCMod.Msg( "Invalid packet! (" .. self.Entity:EntIndex() .. ")", true )
					return 0
				end
				PCMod.Msg( "Got packet containing the source " .. packet.Source .. " (" .. self:GetClass() .. ":"..self:EntIndex() .. ")", true )
				if ((packet.Dest == self:GetFullIP()) || (packet.Dest == self:GetFullBIP())) then
					PCMod.Msg( "This packet was directed at us! Port: " .. packet.Port, true )

					PCMod.Network.Packets[ pid ].Delivered = true
					
					// Forward data to network driver
					if (self.IsComputer) then
						if (PCMod.Data[ self:EntIndex() ].Drivers[ "gen_network" ]) then
							PCMod.Data[ self:EntIndex() ].Drivers[ "gen_network" ]:PacketRecieved( packet )
						end
					end
				else
					// Are we a router? If so forward it to webgear
					if (self.IsNetworkDevice) then
						if (PCMod.Data[ self:EntIndex() ].Drivers[ "webgr_router" ]) then
							PCMod.Data[ self:EntIndex() ].Drivers[ "webgr_router" ]:DataRecieved( packet )
						end
					end
				end
			end
			return 0
		end
		
		function ENT:DataRecieved( port, data )
			-- Override Compatibility
		end
		
		function ENT:PushData( port, data )
			// Called from us, sends data through the port to our peer
			if (type( port ) == "number") then port = self:Ports()[ port ] end
			if (!port) then return 1 end
			if (!port.Connected) then return 2 end
			local ent = port.ConEnt
			if ((ent) && (ent:IsValid())) then
				return ent:GivenData( port.RemotePort, data )
			end
			return 2
		end
		
		function ENT:FullPushData( data, filter )
			// Called from us, sends a global message through every port
			for k, v in pairs( self:Ports() ) do
				if ((!filter) || ((filter) && (filter == v.Type))) then
					self:PushData( k, data )
				end
			end
		end
		
		function ENT:Ports()
			return (self:Data().Ports)
		end
	
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Basic Entity Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------
	
	
		function ENT:Think()
			for _, v in pairs( PCMod.Data[ self:EntIndex() ].Drivers ) do
				v:Think()
			end
			self.harddrive = self:Data().HardDrive -- Duplicator support
			self:CustomThink()
		end
		
		function ENT:CustomThink()
			// Override compatability
		end
		
		function ENT:Use( activator, caller )
			if (CurTime()<self.NextUse) then return end
			self.NextUse = CurTime() + self.UseDelay
			self:FireEvent( { "use", activator } )
		end
		
		function ENT:TurnOn()
			if (self:Data().IsOn) then return end
			PCMod.Msg( "Turning device on! (" .. tostring( self:EntIndex() ) .. ")", true )
			PCMod.Data[ self:EntIndex() ].IsOn = true
			self:ClearMemory()
			self:FireEvent( { "turnon" } )
			self:SetNWInt( "device_on", true )
		end
		
		function ENT:TurnOff()
			if (!self:Data().IsOn) then return end
			if (self.AlwaysOn) then return end
			PCMod.Msg( "Turning device off! (" .. tostring( self:EntIndex() ) .. ")", true )
			PCMod.Data[ self:EntIndex() ].IsOn = false
			self:FireEvent( { "turnoff" } )
			if (self.IsComputer) then
				self:CloseAllPrograms()
			end
			self:ClearMemory()
			self:SetNWInt( "device_on", false )
		end
		
		function ENT:SetPlayer( ply )
			PCMod.Data[ self:EntIndex() ].Owner = ply
		end
		
		function ENT:GetOwner()
			return PCMod.Data[ self:EntIndex() ].Owner
		end
		
		function ENT:ChangeModel( mdl )
			self.Entity:SetModel( mdl )
			self.Entity:PhysicsInit(SOLID_VPHYSICS)
			self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
			self.Entity:SetSolid(SOLID_VPHYSICS)
			local phys = self.Entity:GetPhysicsObject()
			if ((phys) && (phys:IsValid())) then phys:Wake() end
		end
		
		
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Networking Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------

	
		function ENT:GetSubnet()
			return PCMod.Data[ self:EntIndex() ].IP.Sub
		end

		function ENT:GetIP()
			return PCMod.Data[ self:EntIndex() ].IP.Add
		end

		function ENT:GetFullIP()
			return PCMod.Data[ self:EntIndex() ].IP.Full
		end

		function ENT:GetBSubnet()
			return PCMod.Data[ self:EntIndex() ].IP.Back.Sub
		end

		function ENT:GetBIP()
			return PCMod.Data[ self:EntIndex() ].IP.Back.Add
		end

		function ENT:GetFullBIP()
			return PCMod.Data[ self:EntIndex() ].IP.Back.Full
		end

		function ENT:SetSubnet( subnet )
			PCMod.Data[ self:EntIndex() ].IP.Sub = subnet
			self:SetIPText()
		end

		function ENT:SetIP( ip )
			PCMod.Data[ self:EntIndex() ].IP.Add = ip
			self:SetIPText()
		end

		function ENT:SetBSubnet( subnet )
			PCMod.Data[ self:EntIndex() ].IP.Back.Sub = subnet
			self:SetBIPText()
		end

		function ENT:SetBIP( ip )
			PCMod.Data[ self:EntIndex() ].IP.Back.Add = ip
			self:SetBIPText()
		end
		
		function ENT:SetIPText()
			local tmp = PCMod.Data[ self:EntIndex() ].IP
			if (tmp.Add && tmp.Sub) then
				PCMod.Data[ self:EntIndex() ].IP.Full = "192.168."..tmp.Sub.."."..tmp.Add
				self:SetNWString( "IP", PCMod.Data[ self:EntIndex() ].IP.Full )
			else
				PCMod.Data[ self:EntIndex() ].IP.Full = false
				self:SetNWString( "IP", "" )
			end
		end

		function ENT:SetBIPText()
			local tmp = PCMod.Data[ self:EntIndex() ].IP.Back
			if (tmp.Add && tmp.Sub) then
				PCMod.Data[ self:EntIndex() ].IP.Back.Full = "10.0."..tmp.Sub.."."..tmp.Add
				self:SetNWString( "IP.Back", PCMod.Data[ self:EntIndex() ].IP.Back.Full )
			else
				PCMod.Data[ self:EntIndex() ].IP.Back.Full = false
				self:SetNWString( "IP.Back", "" )
			end
		end
		
		function ENT:SendPacket( portid, dest, port, body )
			// Called from this entity, sends a new packet
			if (!portid) then
				for k, v in pairs( self:Ports() ) do
					if ((v.Type == "network") || (v.Type == "optic")) then
						portid = k
						break
					end
				end
			end
			PCMod.Msg("Sending packet from "..self.Entity:GetClass().." {"..tostring(portid)..", "..tostring(dest)..", "..tostring(port)..", "..tostring(body).."}", true)
			local prt = self:Ports()[ portid ]
			if (!prt) then return 1 end
			if (!prt.Connected) then return 2 end
			local portid2 = prt.RemotePort
			local data = {}
			data[1] = "sendpacket"
			data[2] = { self:GetFullIP(), dest, port, body }
			if (!self:GetFullIP()) then data[2][1] = self:GetFullBIP() end
			if (!self.IsNetworkDevice) then
				prt.ConEnt:DataRecieved( portid2, data )
				// self:PushData
			else
				self:DataRecieved( portid, data )
			end
			return 0
		end
		
		
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Entity Data Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------

	
		function ENT:Data()
			local dt = PCMod.Data[ self:EntIndex() ]
			if (!dt) then
				PCMod.Warning( "Entity has no data slot! (" .. tostring( self:EntIndex() ) .. ")" )
				dt = {}
			end
			return (dt)
		end
		
		function ENT:Memory()
			return (self:Data().Memory)
		end
		
		function ENT:UpdateData( newdata )
			PCMod.Data[ self:EntIndex() ] = newdata
		end
		
		function ENT:UpdateMemory( newmem )
			PCMod.Data[ self:EntIndex() ].Memory = newmem
		end
		
		function ENT:ClearMemory()
			self:UpdateMemory( {} )
		end
		
		
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Driver Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------
	
	
		function ENT:InstallDriver( drivername )
			local drv = PCMod.Drivers[ drivername ]
			if (!drv) then
				PCMod.Msg( "No such driver '" .. drivername .. "'!", true )
				return
			end
			local mydrv = table.Copy( drv )
			mydrv.Entity = self
			PCMod.Data[ self:EntIndex() ].Drivers[ drivername ] = mydrv
			PCMod.Data[ self:EntIndex() ].Drivers[ drivername ]:Initialize()
			PCMod.Msg( "Installing driver '" .. drivername .. "' to (" .. tostring( self:EntIndex() ) .. ")", true )
			return PCMod.Data[ self:EntIndex() ].Drivers[ drivername ]
		end
		
		function ENT:PushDriverData( drivername, port, data )
			if (!PCMod.Data[ self:EntIndex() ].Drivers[ drivername ]) then return end
			PCMod.Data[ self:EntIndex() ].Drivers[ drivername ]:DataRecieved( port, data )
		end
		
		function ENT:CallDriver( drivername, func, ... )
			if (!PCMod.Data[ self:EntIndex() ].Drivers[ drivername ]) then return end
			return PCMod.Data[ self:EntIndex() ].Drivers[ drivername ][ func ]( ... ) -- Now that's what I call a function call :D
		end
		
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- File Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------
	
	
		function ENT:LinkFolder( dir )
			if (self:IsLocked( dir )) then
				PCMod.Msg( "Tried to overwrite locked folder: " .. dir .. " (" .. tostring( self:EntIndex() ) .. ")", true )
				return
			end
			local tmp = {}
			tmp.ItemType = "folder"
			tmp.ItemName = dir
			tmp.ItemContent = ""
			tmp.Locked = false
			PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. dir ] = tmp
		end
		
		function ENT:UnlinkItem( dir )
			if (self:IsLocked( dir )) then
				PCMod.Msg( "Tried to unlink locked folder: " .. dir .. " (" .. tostring( self:EntIndex() ) .. ")", true )
				return
			end
			PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. dir ] = nil
		end
		
		function ENT:LockItem( dir )
			if (PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. dir ]) then
				PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. dir ].Locked = true
			end
		end
		function ENT:UnLockItem( dir )
			if (PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. dir ]) then
				PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. dir ].Locked = false
			end
		end
		
		function ENT:WriteFile( filename, content )
			if (self:IsLocked( filename )) then
				PCMod.Msg( "Tried to overwrite locked file: " .. filename .. " (" .. tostring( self:EntIndex() ) .. ")", true )
				return
			end
			local fdir = string.Explode( "/", filename )
			table.remove( fdir )
			local dir = table.concat( fdir, "/" )
			if (self:IsLocked( dir )) then
				PCMod.Msg( "Tried to write in locked folder: " .. dir .. " (" .. tostring( self:EntIndex() ) .. ")", true )
				return
			end
			if (self:FileFolderExist( dir ) && (PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. dir ].ItemType == "file")) then
				PCMod.Msg( "Tried to use file as a folder: " .. dir .. " (" .. tostring( self:EntIndex() ) .. ")", true )
				return
			end
			local tmp = {}
			tmp.ItemType = "file"
			tmp.ItemName = filename
			tmp.ItemContent = content
			tmp.Locked = false
			PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. filename ] = tmp
		end
		
		function ENT:ReadFile( filename )
			local item = PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. filename ]
			if (!item) then
				PCMod.Msg( "Tried to read unexistant file: " .. filename .. " (" .. tostring( self:EntIndex() ) .. ")", true )
				return ""
			end
			if (item.ItemType == "file") then return item.ItemContent end
			PCMod.Msg( "Tried to read a folder: " .. filename .. " (" .. tostring( self:EntIndex() ) .. ")", true )
			return ""
		end
		
		function ENT:FileFolderExist( filename )
			if (PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. filename ]) then return true end
			return false
		end

		function ENT:IsLocked( target )
			if (!PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. target ]) then return false end
			return PCMod.Data[ self:EntIndex() ].HardDrive[ "/" .. target ].Locked
		end
		
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Event Handling Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------
	
	
		function ENT:AddEHook( target, id, event )
			local hk = {}
				hk.Target = target
				hk.ID = id
				hk.Event = event
			table.insert( PCMod.Data[ self:EntIndex() ].EHooks, hk )
			PCMod.Msg( "Adding EHook: " .. target .. ", " .. tostring(id) .. ", " .. event, true )
		end
	
		function ENT:FireEvent( event )
			if (!event) then return end
			if (!event[1]) then return end
			local ename = event[1]
			table.remove( event, 1 )
			local edata = event
			self:CustomFire( ename, edata )
			// edata[1] is likely to be a player, or activator
			PCMod.Msg( "Entity " .. tostring( self:EntIndex() ) .. " reported event '" .. ename .. "'", true )
			for _, v in pairs( PCMod.Data[ self:EntIndex() ].EHooks ) do
				if (v.Event == ename) then
					// Call the hook
					self:CallHook( v, event )
				end
			end
		end
		
		function ENT:CustomFire( ename, edata )
			if (ename == "toggleon") then
				PCMod.Msg( "Toggleon hook called (CustomFire[ename,edata])", true )
				if (self:Data().IsOn) then self:TurnOff() return end
				self:TurnOn()
			end
		end
		
		function ENT:CallHook( hk, data )
			PCMod.Msg( "Calling hook! (" .. hk.Event .. ")", true )
			if (!data) then data = {} end
			data.Event = hk.Event
			if (hk.Target == "driver") then
				if (!self:Data().Drivers[ hk.ID ]) then return end
				PCMod.Msg( "Calling driver hook!", true )
				self:Data().Drivers[ hk.ID ]:CallEvent( data )
			end
			if (hk.Target == "ent") then
				PCMod.Msg( "Calling entity hook!", true )
				self:CallEvent( data )
			end
			if (hk.Target == "patch") then
				PCMod.Msg( "Calling patch hook!", true )
				self:FireEvent( { hk.ID, data } )
			end
		end
		
		function ENT:CallEvent( data )
			-- Override Compatibility
		end
		
		function ENT:DoCommand( pl, com, args )
			-- Override Compatibility
		end
		
		
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- ScreenSpace Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------
	
	
		function ENT:ScreenSpace()
			return (self:Data().ScreenSpace)
		end
		
		function ENT:UpdateScreenSpace( ss )
			PCMod.Data[ self:EntIndex() ].ScreenSpace = ss
			self:InvalidateScreenSpace()
		end
		
		function ENT:InvalidateScreenSpace()
			for _, v in pairs( player.GetAll() ) do
				if (!v.SSBeam) then v.SSBeam = {} end
				v.SSBeam[ self:EntIndex() ] = false
			end
			self:FireEvent( { "ss_inval" } )
			if (self.IsScreen) then	PCMod.Beam.BeamEntSS( self, PCMod.Beam.Range_SS ) end
		end
		
	-------------------------------------------------------------------------------------------------------------------------------------------------
	-- Misc Functions --
	-------------------------------------------------------------------------------------------------------------------------------------------------
		
		function ENT:SetGVar( key, val )
			local id = self:EntIndex()
			PCMod.Beam.SetEntData( id, key, val )
		end
		
		function ENT:ClearGVars()
			PCMod.Beam.ClearEntData( self:EntIndex())
		end
		
		function ENT:BuildDupeInfo()
			PCMod.Msg( "==> BUILDING DUPE INFO <==", true )
			local tmp = {}
			Msg( "Converting TTS...\n" )
			tmp.harddrive = PCMod.TableToString( PCMod.Data[ self:EntIndex() ].HardDrive )
			Msg( "TTS Complete!\n" )
			return tmp
		end

		function ENT:ApplyDupeInfo( ply, ent, info, GetEntByID )
			PCMod.Msg( "==> APPLYING DUPE INFO <==", true )
			PCMod.Data[ self:EntIndex() ].HardDrive = PCMod.StringToTable( info.harddrive )
		end
		
		function ENT:PreEntityCopy()
			// Build the DupeInfo table and save it as an entity mod
			local DupeInfo = self:BuildDupeInfo()
			if (DupeInfo) then
				duplicator.StoreEntityModifier( self.Entity, "PCModDupeInfo", DupeInfo )
			end
		end

		function ENT:PostEntityPaste( ply, ent, CreatedEntities )
			// Apply the DupeInfo
			if ((ent.EntityMods) && (ent.EntityMods.PCModDupeInfo)) then
				ent:ApplyDupeInfo( ply, ent, ent.EntityMods.PCModDupeInfo, function(id) return CreatedEntities[id] end )
			end
		end

end

if (CLIENT) then

	function ENT:GetGVar( key )
		return PCMod.Beam.GetEntData( self:EntIndex(), key )
	end
	
	function ENT:Draw()
	
		// See if the PCMod library exists or not
		if (!PCMod_IsValid()) then
			// Check if we have attempted to kick start
			if (_G.PCMod_Kicked) then
				// No luck, draw and finish
				self.Entity:DrawModel()
				return
			end
			
			// Try to kick start
			Msg( "\n", "==== {WARNING} ====", "\n" )
			ErrorNoHalt( "PCMod 2 libraries not loaded (CL)! About to kick start!" )
			_G.PCMod_Kicked = true
			
			// Kick start
			PCMod_KickStart()
			
			// Determine if we are successful or not
			if (PCMod_IsValid()) then
				ErrorNoHalt( "PCMod 2 was kick-started successfully!" )
				self.Entity:DrawModel()
				return
			end
			
			// Unsuccessful!
			ErrorNoHalt( "PCMod 2 FAILED to kick-start! Please post your console log on the forums." )
			self.Entity:DrawModel()
			return
		end
	
		// See if player is looking at the entity
		local tr = LocalPlayer():GetEyeTrace()
		if (tr.Entity == self) then			
			PCMod.SelEntity = self:EntIndex()
		end
	
		self.Entity:DrawModel() -- Draw the model
		
		if (self.IsScreen) then
			
			// We are a screen, we need to draw			
			if ((PCMod.Gui.CamLocked) && (PCMod.Gui.CamLockID == self:EntIndex())) then
				PCMod.SDraw.DrawScreen( self ) -- This entity is in focus!
			else
				PCMod.SDraw.DrawScreen( self ) -- This entity is NOT in focus!
			end
			
		end
	
	end
	
	function ENT:DrawInfo( origin )
		// If we are wireless then draw wireless info
		local wireless = self:GetGVar( "wireless" )
		if (wireless) then PCMod.Gui.DrawWirelessLinks( self ) end
		
		// Get the IP info
		local IP = {}
		IP.Back = {}
		IP.Full = self:GetNWString( "IP" )
		IP.Back.Full = self:GetNWString( "IP.Back" )
		
		// Fill in the info table
		local txt = {}
		txt[1] = self.PrintName
		if (wireless) then table.insert( txt, "Wireless" ) end
		if (IP.Full != "") then table.insert( txt, IP.Full) end
		if (IP.Back.Full != "") then table.insert( txt, IP.Back.Full ) end
		if (self:GetGVar( "noreg" )) then table.insert( txt, "Hardware Failure" ) end
		
		// Draw the label
		PCMod.Gui.DrawLabel( origin.x, origin.y, "ScoreboardText", txt, 10, Color( 50, 50, 50, 200 ), Color( 255, 255, 255, 255 ) )
	end

end
