include( 'shared.lua' )


SWEP.PrimaryAttack = function( self ) return end
SWEP.SecondaryAttack = function( self ) return end

SWEP.CalcViewModelView = function( self, viewmodel )
	local state = self:GetNWInt('state', 0)

	if viewmodel:GetSkin() != state then
		viewmodel:SetSkin(state)
	end
end