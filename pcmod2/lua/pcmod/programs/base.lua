
// Base Program for PCMod 2 \\

PROG.Name = "base"
PROG.Author = "[GU]thomasfn"
PROG.Title = "Base Program"
PROG.Icon = "app"

PROG.State = 0
PROG.OS = "personal"

PROG.SimpleMode = false

PROG.DeviceLink = ""
PROG.DeviceName = ""
PROG.DeviceData = {}

PROG.NoShortcut = false

PROG.Slot = -1

function PROG:Initialize() end
function PROG:Think() end
function PROG:DoCommand( com, args ) end
function PROG:OnStart() end
function PROG:OnEnd() end
function PROG:ProcessPacket() end
function PROG:PingSuccess() end
function PROG:TraceSuccess() end
function PROG:MessageFailed() end

function PROG:CanUse()
	return true
end

function PROG:OnInstall()
	if (!self.NoShortcut) then
		local com = "sys_openprog " .. self.Name
		if (self.OS == "server") then com = self.Name end
		self:GetOS():AddProg( self.Icon, self.Title, com )
	end
end

function PROG:Start()
	self:RequestFocus( false )
	self:SetState( 1 )
end

function PROG:Exit()
	self:RemoveFocus()
	self:SetState( 0 )
end

function PROG:GetScreenSpace()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	return PCMod.Data[ ent:EntIndex() ].Drivers[ "gen_display" ]:GetScreen()
end

function PROG:SetScreenSpace( ss )
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	PCMod.Data[ ent:EntIndex() ].Drivers[ "gen_display" ]:SetScreen( ss )
end

function PROG:GetOS()
	local ent = self.Entity
	if ((!ent) || (!ent:IsValid())) then return end
	return PCMod.Data[ ent:EntIndex() ].Drivers[ "gen_bios" ].OS
end

function PROG:SetState( st )
	if (self.State == st) then return end
	self.State = st
	self:TriggerState( st )
end

function PROG:Tick()
	if (self.State == 0) then return end
	self:Think()
end

function PROG:TriggerState( st )
	if (!self.SimpleMode) then return end
	if (!self.DeviceData) then self.DeviceData = {} end
	if (self:GetOS()) then self.DeviceData.Th = self:GetOS():GetTheme() end
	if (st == 0) then
		if (self.OS == "server") then
			self:GetOS().CP = nil
			self:GetOS():BuildDesktop()
		end
		self:OnEnd()
		local ss = self:GetScreenSpace()
		ss:RemoveDevice( self.DeviceName )
		ss:RemoveDevice( "win_" .. self.Name .. "_openfile" )
		ss:RemoveDevice( "win_" .. self.Name .. "_printloc" )
		self:SetScreenSpace( ss )
	end
	if (st == 1) then
		if (self.OS == "server") then
			self:GetOS().CP = self.Title
			self:GetOS():BuildDesktop()
		end
		self:OnStart()
		self:UpdateSS()
	end
end

function PROG:UpdateSS()
	local ss = self:GetScreenSpace()
	local dms = self:GetDimensions()
	local dev = ss:MakeDevice( self.DeviceLink, dms.x, dms.y, dms.w, dms.h, self.DeviceData, self:GetPriority() )
	ss:AddDevice( self.DeviceName, dev )
	self:SetScreenSpace( ss )
end

function PROG:ShowOpenFile( path )
	local ss = self:GetScreenSpace()
	local tmp = {}
	tmp.Th = self:GetOS():GetTheme()
	tmp.Fs = PCMod.Beam.FileList( self.Entity, path )
	tmp.Parent = self.DeviceName
	local dev = ss:MakeDevice( "window_openfile", 0.2, 0.2, 0.6, 0.6, tmp, 7 )
	local on = "win_" .. self.Name .. "_openfile"
	ss:AddDevice( on, dev )
	self:SetScreenSpace( ss )
end

function PROG:CloseOpenFile()
	local ss = self:GetScreenSpace()
	local on = "win_" .. self.Name .. "_openfile"
	ss:RemoveDevice( on )
	self:SetScreenSpace( ss )
end

function PROG:ShowPrintLocation( isChanged )
	if (!isChanged) then
		isChanged = false
	end
	PCMod.Msg( "isChanged = "..PCMod.BTN( isChanged ), true )
	local ss = self:GetScreenSpace()
	local tmp = {}
	tmp.Th = self:GetOS():GetTheme()
	tmp.Parent = self.DeviceName
	local dev = ss:MakeDevice( "window_printloc", 0.2, 0.2, 0.6, 0.6, tmp, 7 )
	local on = "win_" .. self.Name .. "_printloc"
	PCMod.SetDevParam( self.Entity:EntIndex(), "window_printloc", 1, { "bool", isChanged } )
	ss:AddDevice( on, dev )
	self:SetScreenSpace( ss )
end

function PROG:ClosePrintLocation()
	local ss = self:GetScreenSpace()
	local on = "win_" .. self.Name .. "_printloc"
	ss:RemoveDevice( on )
	self:SetScreenSpace( ss )
end

function PROG:PrintDocument( txt, singleprinter )
	local printers = self:GetOS():GetUSBDevicePorts( "printer" )
	if (!singleprinter) then
		for _, v in pairs( printers ) do
			self:GetOS():SendUSBData( v, { "print_doc", txt } )
		end
	else
		if (printers[1]) then self:GetOS():SendUSBData( printers[1], { "print_doc", txt } ) end
	end
end

function PROG:GetDimensions()
	local tmp = {}
	tmp.x = 0
	tmp.y = 0
	tmp.w = 1
	tmp.h = 1
	if (self.OS == "personal") then
		tmp.x = 0
		tmp.y = 0
		tmp.w = 1
		tmp.h = 0.9
	end
	if (self.OS == "server") then
		tmp.x = 0.58
		tmp.y = 0.12
		tmp.w = 0.36
		tmp.h = 0.84
	end
	return tmp
end

function PROG:RequestFocus( update )
	self:GetOS().ProgFocus = self.Name
	if (update) then self:UpdateSS() end
	for progname, prog in pairs( self:GetOS().Progs ) do
		if (prog.State > 0) then
			self:GetOS().Progs[ progname ]:UpdateSS()
			return
		end
	end
end

function PROG:RemoveFocus()
	self:GetOS().ProgFocus = ""
	for progname, prog in pairs( self:GetOS().Progs ) do
		if (prog.State > 0) then
			self:GetOS().Progs[ progname ]:RequestFocus( true )
			return
		end
	end
end

function PROG:GetPriority()
	if (self:GetOS().ProgFocus == self.Name) then return 6 end
	return 5
end