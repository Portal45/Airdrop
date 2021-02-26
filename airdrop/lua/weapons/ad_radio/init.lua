AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

SWEP.Initialize = function( self )
	self:SetNWInt('state', 0)
end

SWEP.PrimaryAttack = function( self )
	if not IsValid( self.Owner ) or not self.Owner:Alive() then return end		
	if self:GetNWInt('state', 0) != 0 then return end

	self:SetNWInt('state', 1)
	self:EmitSound('airdrop/radio.wav', 65)

	timer.Simple(1.5, function()
		if IsValid( self ) and IsValid( self.Owner ) and self.Owner:Alive() then
			airdrop.call( self:GetPos() )
			self:Remove()
		end
	end )
end

SWEP.SecondaryAttack = function( self ) return end
