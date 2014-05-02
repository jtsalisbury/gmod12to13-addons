TOOL.Category		= "PCMod - Miscellaneous"
TOOL.Name			= "Sweps"
TOOL.Tab			= "PCMod 2"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if (CLIENT) then

	language.Add( 'Tool_pc_sweps_name', 'Swep Tool' )
	language.Add( 'Tool_pc_sweps_desc', 'Gives you Sweps from PCMod 2' )
	language.Add( 'Tool_pc_sweps_0', 'Left-Click: Give the swep' )

end

TOOL.ClientConVar[ "swepclass" ] = "installdisk"

function TOOL:LeftClick( trace )
	
	// This function is server-only stuff.
	if (CLIENT) then return false end

	// Give the swep
	local swep = ( self:GetClientInfo( "swepclass" ) )
	self:GetOwner():Give( "pcmod_" .. swep )
	local wep = self:GetOwner():GetWeapon( "pcmod_" .. swep )
	if ((!wep) || (!wep:IsValid())) then return false end
	
	// If an install disk, give all programs
	if (swep == "installdisk") then
		wep:Reset()
		wep:SetPackName( "Install Disk" )
		local progs = PCMod.Cfg.FullProgramList
		if (progs) then
			local ps = string.Explode( ",", progs )
			if (ps) then
				for k, v in pairs( ps ) do
					if (PCMod.Progs[ v ]) then
						local title = PCMod.Progs[ v ].Title
						local osid = PCMod.Progs[ v ].OS
						wep:AddProgram( v, title, osid )
					end
				end
			end
		end
	end
	
	return true
end

function TOOL:RightClick( trace )
	return false
end


function TOOL.BuildCPanel( CPanel )

	// Header
	CPanel:AddControl( "Header", { Text = "#Tool_pc_sweps_name", Description	= "#Tool_pc_sweps_desc" }  )
	
	// ent select
	combobox = {}
	combobox.Label = "Swep Choice"
	combobox.Options = {}
	combobox.Options[ "install disk" ] = {pc_sweps_swepclass = "installdisk"}
	combobox.Options[ "password cracker" ] = {pc_sweps_swepclass = "pwcrack"}
	combobox.Options[ "hard-disk copier" ] = {pc_sweps_swepclass = "hdcopier"}
	combobox.Options[ "network tester" ] = {pc_sweps_swepclass = "networktester"}
	
	CPanel:AddControl("ComboBox", combobox)


end