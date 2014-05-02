
// ---------------------------------------------------------------------------------------------------------
// sh_resources.lua - Revision 1
// Shared
// Collects and controls use of resources (materials, models, sounds)
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------

PCMod.Res = {}
PCMod.Res.Version = "1.0"
PCMod.Res.Mats = {}

PCMod.Msg( "Resources Library Loaded! (V".. PCMod.Res.Version .. ")", true )


// ---------------------------------------------------------------------------------------------------------
// AddModel - Adds a model to the global table (path/model)
// ---------------------------------------------------------------------------------------------------------
function PCMod.Res.AddModel( modelname )
	local pt = "models/" .. modelname
	if (SERVER) then
		PCMod.Res.ServeItem( pt .. ".mdl" )
		PCMod.Res.ServeItem( pt .. ".phy" )
		PCMod.Res.ServeItem( pt .. ".vvd" )
		PCMod.Res.ServeItem( pt .. ".sw.vtx" )
		PCMod.Res.ServeItem( pt .. ".dx80.vtx" )
		PCMod.Res.ServeItem( pt .. ".dx90.vtx" )
	end
	util.PrecacheModel( pt .. ".mdl" )
end

// ---------------------------------------------------------------------------------------------------------
// AddMaterial - Adds a material to the global table (path/mat)
// ---------------------------------------------------------------------------------------------------------
function PCMod.Res.AddMaterial( matname )
	local pt = "materials/" .. matname
	if (SERVER) then
		PCMod.Res.ServeItem( pt .. ".vtf" )
		PCMod.Res.ServeItem( pt .. ".vmt" )
	end
	if (CLIENT) then
		PCMod.Res.Mats[ matname ] = surface.GetTextureID( matname )
	end
end

if (SERVER) then
	// ---------------------------------------------------------------------------------------------------------
	// ServeItem - Adds an item to the resource (to be downloaded)
	// ---------------------------------------------------------------------------------------------------------
	function PCMod.Res.ServeItem( filename )
		if (file.Exists(filename, "GAME")) then
			resource.AddFile( filename )
			PCMod.Msg( "Added file '" .. filename .. "'!", true )
		else
			PCMod.Msg( "Unexistant file '" .. filename .. "'!", true )
		end
	end
end


// ---------------------------------------------------------------------------------------------------------
// Add all of the materials we need
// ---------------------------------------------------------------------------------------------------------
for _, v in pairs( PCMod.Cfg.Mats ) do
	PCMod.Res.AddMaterial( v )
end

// ---------------------------------------------------------------------------------------------------------
// Add all of the models we need
// ---------------------------------------------------------------------------------------------------------
for _, v in pairs( PCMod.Cfg.Models ) do
	PCMod.Res.AddModel( v )
end