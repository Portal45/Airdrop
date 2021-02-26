ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'
ENT.PrintName = 'airdrop'
ENT.Author = 'KERRY'
ENT.Spawnable = false


ENT.SetupDataTables = function( self )
	self:NetworkVar( 'Bool', 0, 'OnGround' )
end