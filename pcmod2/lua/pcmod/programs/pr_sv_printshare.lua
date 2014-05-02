
// My Computer Program for PCMod 2 \\

PROG.Name = "printshare"
PROG.Author = "[GU]thomasfn"
PROG.Title = "Print Share"
PROG.Icon = ""
PROG.OS = "server"

PROG.SimpleMode = true

PROG.DeviceLink = "server_printshare"
PROG.DeviceName = "server_printshare"
PROG.DeviceData = {}

PROG.Enabled = true
PROG.PCnt = 0

function PROG:OnStart()
	self:GetOS():OpenNetPort( 58, "prog", "printshare" )
end

function PROG:OnEnd()
	self:GetOS():CloseNetPort( 58 )
end

function PROG:ProcessPacket( pt, dat, hdl )
	if (pt == 58) then
		if (dat[1] == "netPrintDocument") then
			PCMod.Msg( "PrintShare recieved command to print!", true )
			self:PrintDocument( dat[2] or "", false )
			self.PCnt = self.PCnt + 1
			self:UpdateMe()
		end
	end
end

function PROG:UpdateMe()
	self.DeviceData.Ps = self.PCnt
	local on = 0
	if (self.Enabled) then on = 1 end
	self.DeviceData.On = on
	self:UpdateSS()
end

function PROG:DoCommand( com, args )
	if (com == "enable") then
		self.Enabled = true
		self:UpdateMe()
	end
	if (com == "disable") then
		self.Enabled = false
		self:UpdateMe()
	end
end