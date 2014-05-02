
// ---------------------------------------------------------------------------------------------------------
// cl_sselements.lua - Revision 1
// Client-Side
// Controls the 2D 3D Screen-Space device elements
// ---------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------
// Define our library
// ---------------------------------------------------------------------------------------------------------


PCMod.SSEL = {}
PCMod.SSEL.Version = "1.0"
PCMod.SSEL.Bases = {}
PCMod.SSEL.BaseLoaded = false

PCMod.Msg( "Screen-Space Element Library Loaded (V" .. PCMod.SSEL.Version .. ")", true )


// ---------------------------------------------------------------------------------------------------------
// Register - Registers SSD element
// ---------------------------------------------------------------------------------------------------------
function PCMod.SSEL.Register( name, tbl )
	local o = {}
	table.Merge( o, PCMod.SSEL.GetBase() )
	table.Merge( o, tbl )
	PCMod.SSEL.Bases[ name ] = o
	PCMod.Msg( "Registered element '" .. name .. "'!", true )
end

// ---------------------------------------------------------------------------------------------------------
// RegisterBase - Registers the base element
// ---------------------------------------------------------------------------------------------------------
function PCMod.SSEL.RegisterBase( tbl )
	if (PCMod.SSEL.BaseLoaded) then return end
	PCMod.SSEL.Bases[ "base" ] = tbl
	PCMod.SSEL.BaseLoaded = true
	PCMod.Msg( "Registered base element!", true )
end

// ---------------------------------------------------------------------------------------------------------
// GetBase - Gets/loads the base element
// ---------------------------------------------------------------------------------------------------------
function PCMod.SSEL.GetBase( nocont )
	if (PCMod.SSEL.Bases[ "base" ]) then return PCMod.SSEL.Bases[ "base" ] end
	if (nocont) then return {} end
	include( "pcmod/sselements/base.lua" )
	return PCMod.SSEL.GetBase( true )
end

// ---------------------------------------------------------------------------------------------------------
// Create - Creates a new SSD element
// ---------------------------------------------------------------------------------------------------------
function PCMod.SSEL.Create( name )
	local base = PCMod.SSEL.Bases[ name ]
	if (!base) then
		PCMod.Warning( "Attempt to create unexistant element! (" .. name .. ")" )
		return
	end
	local o = {}
	setmetatable( o, { __index = base } )
	if (o.OnCreate) then o:OnCreate() end
	o.EL_NAME = name
	o.EL_PCMOD = true
	return o
end

// ---------------------------------------------------------------------------------------------------------
// Derive - Derives an element from another element
// ---------------------------------------------------------------------------------------------------------
function PCMod.SSEL.Derive( tbl, basename )
	local base = PCMod.SSEL.Bases[ basename ]
	if (!base) then return false end
	table.Merge( tbl, base )
end

// ---------------------------------------------------------------------------------------------------------
// Destroy - Destroys an existing SSD element
// ---------------------------------------------------------------------------------------------------------
function PCMod.SSEL.Destroy( tbl )
	if (!tbl.EL_PCMOD) then return end
	if (tbl.OnDestroy) then tbl:OnDestroy() end
end


// ---------------------------------------------------------------------------------------------------------
// Load everything in the ss-elements folder
// ---------------------------------------------------------------------------------------------------------

for _, v in pairs( file.Find( "pcmod/sselements/*.lua", "LUA") ) do
	include( "pcmod/sselements/" .. v )
end