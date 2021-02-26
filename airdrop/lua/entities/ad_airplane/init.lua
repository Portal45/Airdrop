AddCSLuaFile( 'cl_init.lua' )

AddCSLuaFile( 'shared.lua' )

include( 'shared.lua' )


ENT.Initialize = function( self )
	
	self:SetModel( 'models/kerry/airdrop/airplane.mdl' )

	self:PhysicsInit( SOLID_OBB_YAW )

	self:SetMoveType( MOVETYPE_VPHYSICS )
	
	self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

	self:StartMotionController( true )


	self:SetNWBool( 'playsound', true )

	self.spawnTime = CurTime()

	self.speed = math.Rand ( airdrop.config.airplane.minspeed, airdrop.config.airplane.maxspeed )


	local phys = self:GetPhysicsObject()

	if IsValid( phys ) then

		phys:Wake()
		phys:EnableGravity( false )

		self.phys = phys

	end

end


ENT.dropAirdrop = function( self, offset )
	
	local airdrop = ents.Create( 'ad_airdrop' )

	airdrop:SetPos( offset or self.droppos )

	airdrop:Spawn()

	airdrop.plane = self

	self.dropped = true

end

ENT.PhysicsSimulate = function( self, phys, delta )
	
	if not self.dropped then 

		local dropoffset = self:GetPos() + ( self.droppos - self.startpos ):Angle():Forward() * -200 + self:GetUp() * -100

		if dropoffset:DistToSqr( Vector(self.droppos.x, self.droppos.y, dropoffset.z) ) <= 100 * 100 then
			
			self:dropAirdrop( dropoffset )

		end

	end

	if not self:IsInWorld() then

		if not self.dropped and ( CurTime() - self.spawnTime ) > 4 then

			self:dropAirdrop()

		elseif self.dropped then

			self:Remove()

		end

	end

	return Vector( 0, 0, 0 ), (self:GetRight() / FrameTime() * 5 * self.speed) - self:GetVelocity(), SIM_GLOBAL_ACCELERATION

end