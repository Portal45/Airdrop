AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )
ENT.Initialize = function( self )
	
	self:SetModel( 'models/kerry/props/airdrop_box.mdl' )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetCollisionGroup( COLLISION_GROUP_NONE )

	local phys = self:GetPhysicsObject()
		
	if IsValid( phys ) then
		phys:Wake()

		self.phys = phys
	end
end

ENT.Think = function( self )
	
	if not IsValid( self.phys ) then return end
	if airdrop.config.airdrop.force == 0 then return end
	if not self:GetOnGround() then
		local trace = util.TraceLine( {
		    start = self:GetPos(),
		    endpos = self:GetPos() - Vector( 0, 0, 2500 ),
		    filter = function(ent) return not table.HasValue({'ad_airdrop', 'ad_airplane'}, ent:GetClass()) end
		} )
		if trace.HitPos:DistToSqr( self:GetPos() ) <= 50 * 50 and ( IsValid( trace.Entity ) and trace.Entity:GetClass() != self:GetClass() or true ) or self:WaterLevel() > 0 then
		
			self:SetOnGround( true )
			self.phys:SetMass( 1000 )
			self:SetBodygroup( 1, 1 )
		end
	end
	
end

ENT.Use = function( self, activator, caller )
		
	if not IsValid( caller ) or not caller:IsPlayer() then return end
	if caller.ad_lastuse and CurTime() - caller.ad_lastuse < 1 then return end
	caller.ad_lastuse = CurTime()
	
	airdrop.sendContent( self, caller )
end
