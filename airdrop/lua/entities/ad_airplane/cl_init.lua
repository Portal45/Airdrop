include( 'shared.lua' )

ENT.Draw = function( self )
	
	self:DrawModel()

end

ENT.OnRemove = function( self )
	
	if IsValid( self.sound ) then

		self.sound:Stop()

	end

end

ENT.Think = function( self )
	
	if self:GetNWBool( 'playsound', false ) then
	
		if not self.sound or not IsValid( self.sound ) then

			sound.PlayFile( airdrop.config.airplane.sound, '3d', function( station, errcode )
			
				if not IsValid( station ) then return end

				station:EnableLooping( true )

				station:SetVolume( airdrop.config.airplane.volume )
				
				station:Play()


				self.sound = station

			end )

		else
			
			self.sound:SetPos( self:GetPos() )

			if self.sound:GetVolume() != airdrop.config.airplane.volume then

				self.sound:SetVolume( airdrop.config.airplane.volume )

			end

		end

	else

		if self.sound and IsValid( self.sound ) then

			self.sound:Remove()

		end

	end
	
end