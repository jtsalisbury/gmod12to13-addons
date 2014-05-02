
// My Computer Program for PCMod 2 \\

PROG.Name = "mycomputer"
PROG.Author = "[GU]thomasfn"
PROG.Title = "My Computer"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true

PROG.DeviceLink = "window_mycomp"
PROG.DeviceName = "window_mycomp"
PROG.DeviceData = {}

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
		return
	end
	if (com == "changepass") then
		local oldpass = args[1]
		if (!oldpass) then return end
		local newpass = args[2]
		if (!newpass) then return end
		local apass = PCMod.Data[ self.Entity:EntIndex() ].Password
		if ((!apass) || (oldpass == apass) || (apass == "")) then
			PCMod.Data[ self.Entity:EntIndex() ].Password = newpass
			self.DeviceData.PWE = 2
			self:UpdateSS()
		else
			self.DeviceData.PWE = 1
			self:UpdateSS()
		end
		return
	end
	if (com == "open_devman") then
		self:GetOS():RunCommand( "sys_openprog deviceman" )
		self:Exit()
	end
	if (com == "open_nettools") then
		self:GetOS():RunCommand( "sys_openprog nettools" )
		self:Exit()
	end
end