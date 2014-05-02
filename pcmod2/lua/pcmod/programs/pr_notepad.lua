
// Notepad Program for PCMod 2 \\

PROG.Name = "notepad"
PROG.Author = "[GU]thomasfn"
PROG.Title = "Notepad"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true

PROG.DeviceLink = "window_notepad"
PROG.DeviceName = "window_notepad"
PROG.DeviceData = {}
PROG.DeviceData.TC = ""

PROG.SaveRoot = "mydocs/text/"

function PROG:OnInstall()
	self:GetOS():AddProg( self.Icon, self.Title, "sys_openprog " .. self.Name )
	self.Entity:LinkFolder( "mydocs/text/" )
end

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
		return
	end
	if (com == "ct_clear") then
		self.DeviceData.TC = ""
		return
	end
	if (com == "ct_start") then
		self.CTSegs = ""
		return
	end
	if (com == "ct_seg") then
		self.CTSegs = self.CTSegs .. table.concat( args, " " )
		return
	end
	if (com == "ct_end") then
		self.DeviceData.TC = self.CTSegs
		self.CTSegs = ""
		self:UpdateSS()
		return
	end
	if (com == "savecontent") then
		local filename = args[1]
		table.remove( args, 1 )
		local text = table.concat( args, " " )
		PCMod.Msg( "Recieved content to save! (" .. text .. ")", true )
		self.DeviceData.TC = text
		// self:UpdateSS()
		self:DoCommand( "save", { filename } )
		return
	end
	if (com == "update") then
		self:UpdateSS()
		return
	end
	if (com == "save") then
		local txt = self.DeviceData.TC
		if (!txt) then txt = "" end
		local fname = args[1]
		if (!fname) then fname = "untitled.txt" end
		local fn = self.SaveRoot .. fname
		self.Entity:WriteFile( fn, txt )
		self.DeviceData.St = 1
		self:UpdateSS()
		return
	end
	if (com == "open") then
		local fname = args[1]
		if (!fname) then fname = "untitled.txt" end
		local fn = self.SaveRoot .. fname
		if (self.Entity:FileFolderExist( fn )) then
			local text = self.Entity:ReadFile( fn )
			if (!text) then text = "" end
			self.DeviceData.TC = text
			self.DeviceData.St = 2
		else
			self.DeviceData.TC = ""
			self.DeviceData.St = 3
		end
		self:UpdateSS()
		return
	end
	if (com == "browse") then
		self:ShowOpenFile( self.SaveRoot )
		return
	end
	if (com == "closebrowse") then
		self:CloseOpenFile()
		return
	end
	if (com == "print") then
		if (tonumber(args[1]) == 1) then
			self:ShowPrintLocation( true )
		else
			self:ShowPrintLocation( false )
		end
		return
	end
	if (com == "closeprint") then
		self:ClosePrintLocation()
		return
	end
	if (com == "printdoc") then
		self:ClosePrintLocation()
		local txt = self.DeviceData.TC
		if (!txt) then return end
		if ((!args[1]) || (args[1] == "local")) then
			self:PrintDocument( txt, false ) -- false means print to ALL linked printers, true means print to only 1 - thomasfn
		else
			self:GetOS():SendNetMessage( args[1], 58, { "netPrintDocument", txt } )
		end
		self.DeviceData.St = 5
		self:UpdateSS()
		return
	end
end