
ENT.Type = 'anim'

ENT.Base = 'base_gmodentity'

ENT.PrintName = 'airdrop airplane'

ENT.Author = 'KERRY'

ENT.Spawnable = true


ENT.SetupDataTables = function( self )

	self:NetworkVar( 'Vector', 0, 'StartPos' )

	self:NetworkVar( 'String', 0, 'SoundName' )

	self:NetworkVar( 'Int', 0, 'SoundVolume' )

	self:NetworkVar( 'Vector', 1, 'TargetPos' )

end