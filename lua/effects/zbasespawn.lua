local matRefract = Material( "models/props_combine/stasisshield_sheet" )

function EFFECT:Init( data )
	local conVar = GetConVar("cl_drawspawneffect")

	if ( conVar ) then
		if not ( conVar:GetBool() ) then
			return
		end
	end

	-- This is how long the spawn effect
	-- takes from start to finish.
	self.Time = 0.5
	self.LifeTime = CurTime() + self.Time
	local ent = data:GetEntity()

	if ( !IsValid( ent ) ) then return end
	if ( !ent:GetModel() ) then return end

	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent:GetAngles() )
	self:SetParent( ent )
	self.OldRenderOverride = self.ParentEntity.RenderOverride
	self.ParentEntity.SpawnEffect = self
	self.ParentEntity.RenderOverride = self.RenderParent
end

function EFFECT:Think()
	local conVar = GetConVar("cl_drawspawneffect")

	if ( conVar ) then
		if not ( conVar:GetBool() ) then
			return false
		end
	end

	if ( !IsValid( self.ParentEntity ) ) then return false end
	local PPos = self.ParentEntity:GetPos()
	self:SetPos( PPos + ( EyePos() - PPos ):GetNormal() )
	if ( self.LifeTime > CurTime() ) then
		return true
	end

	-- Remove the override only if our override was not overridden.
	if ( self.ParentEntity.RenderOverride == self.RenderParent ) then
		self.ParentEntity.RenderOverride = self.OldRenderOverride
	end

	self.ParentEntity.SpawnEffect = nil
	return false
end

function EFFECT:Render()
end

function EFFECT:RenderOverlay( entity )
	local Fraction = ( self.LifeTime - CurTime() ) / self.Time
	local ColFrac = ( Fraction - 0.5 ) * 2
	Fraction = math.Clamp( Fraction, 0, 1 )
	ColFrac = math.Clamp( ColFrac, 0, 1 )

	-- Change our model's alpha so the texture will fade out
	--entity:SetColor( 255, 255, 255, 1 + 254 * (ColFrac) )
	-- Place the camera a tiny bit closer to the entity.
	-- It will draw a big bigger and we will skip any z buffer problems
	local EyeNormal = entity:GetPos() - EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()
	local Pos = EyePos() + EyeNormal * Distance * 0.01
	-- Start the new 3d camera position
	local bClipping = self:StartClip( entity, 1.2 )
	cam.Start3D( Pos, EyeAngles() )
	-- If our card is DX8 or above draw the refraction effect
		if ( render.GetDXLevel() >= 80 ) then
			-- Update the refraction texture with whatever is drawn right now
			render.UpdateRefractTexture()
			matRefract:SetFloat( "$refractamount", Fraction * 0.1 )
			-- Draw model with refraction texture
			render.MaterialOverride( matRefract )
				entity:DrawModel()
			render.MaterialOverride( 0 )
		end
		-- Set the camera back to how it was
	cam.End3D()
	render.PopCustomClipPlane()
	render.EnableClipping( bClipping )
end

function EFFECT:RenderParent()
	if ( !IsValid( self ) ) then return end
	if ( !IsValid( self.SpawnEffect ) ) then self.RenderOverride = nil return end
	local bClipping = self.SpawnEffect:StartClip( self, 1 )
	self:DrawModel()
	render.PopCustomClipPlane()
	render.EnableClipping( bClipping )
	self.SpawnEffect:RenderOverlay( self )
end

function EFFECT:StartClip( model, spd )
	local mn, mx = model:GetRenderBounds()
	local Up = ( mx - mn ):GetNormal()
	local Bottom = model:GetPos() + mn
	local Top = model:GetPos() + mx
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	Fraction = math.Clamp( Fraction / spd, 0, 1 )
	local Lerped = LerpVector( Fraction, Bottom, Top )
	local normal = Up
	local distance = normal:Dot( Lerped )
	local bEnabled = render.EnableClipping( true )
	render.PushCustomClipPlane( normal, distance )
	return bEnabled
end
