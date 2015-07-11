ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "WEAPON BENCH"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Weapon Crafting"

AddCSLuaFile()

if CLIENT then
	surface.CreateFont( "LargeWeaponFont", {
		font = "Arial",
		size = 100,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	} )
	
	surface.CreateFont( "SmallWeaponFont", {
		font = "Arial",
		size = 50,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	} )
end

local CSSWeaponsTable = {}

function ENT:Initialize()

	if SERVER then
	
		self:SetModel("models/props_combine/breendesk.mdl") 
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetBuoyancyRatio(0)
		end
		
		self:SetNWInt("ScrapCount",0)
		self:SetNWFloat("BuildPercent",0)
		
		self.Building = false
		self.NextTick = 0
		
		self:GenerateWeapons()
		--self:SpawnWeapon()
		
	end
end




function ENT:GenerateWeapons()

	for k,v in pairs(weapons.GetList()) do

		if v.Base == "weapon_cs_base" then
		
			if v.WeaponType	~= "Free" and v.WeaponType ~= "Throwable" then
			
				table.Add(CSSWeaponsTable,{v.ClassName})
				
			end
				
		end
			
	end

end



function ENT:PhysicsCollide(data, physobj)


end

function ENT:Use(activator,caller,useType,value)
	if self:GetNWFloat("BuildPercent",0) == 0 and self:GetNWInt("ScrapCount",0) >= 4 then
		self:SetNWFloat("BuildPercent",1)
		self:SetNWInt("ScrapCount",self:GetNWInt("ScrapCount",4) - 4)
		self.Building = true
	end
end


function ENT:Think()

	if SERVER then
		if self.Building == true then
			if self.NextTick <= CurTime() then
			
				local AddBuild = self:GetNWFloat("BuildPercent",0) + math.random(1,3)
			
				if AddBuild >= 100 then
					self.Building = false
					self:SpawnWeapon()
					self:SetNWFloat("BuildPercent",0)
				else
					self:SetNWFloat("BuildPercent",AddBuild)
				end
	
	
				self.NextTick = CurTime() + 1
			end
		end
	end
end





function ENT:Draw()
	if CLIENT then
		self:DrawModel()
		
		local AdjVec, AdjAng = LocalToWorld(Vector(-21,-43,32),Angle(0,90,0),self:GetPos(),self:GetAngles())
		
		
		if not self.PulseOne then
			self.PulseOne = 0
		end
		
		if self.PulseOne <= 255 then
			self.PulseOne = self.PulseOne + (255*FrameTime())
		else
			self.PulseOne = 0
		end
	
		
		cam.Start3D2D( AdjVec, AdjAng  , 0.1 )	
		
			surface.SetFont( "LargeWeaponFont" )
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( 0, 0 )
			surface.DrawText( "[Weapon Workbench]" )
			
			if self:GetNWFloat("BuildPercent",0) == 0 and self:GetNWInt("ScrapCount",0) < 4 then
				surface.SetTextPos( 78, 200 )
				surface.SetTextColor( 255, 255, 255, self.PulseOne )
				surface.DrawText( "[INSERT SCRAP]" )
			elseif self:GetNWFloat("BuildPercent",0) == 0 and self:GetNWInt("ScrapCount",0) >= 4 then
				surface.SetTextPos( 200, 200 )
				surface.SetTextColor( 255, 255, 255, self.PulseOne )
				surface.DrawText( "[PRESS E]" )
			else
				surface.SetTextPos( 325, 200 )
				surface.SetTextColor( 255, 255, 255, 255 )
				surface.DrawText( self:GetNWFloat("BuildPercent",0) .. "%" )
			end
			
			surface.SetFont( "SmallWeaponFont" )
			surface.SetTextPos( 300, 360 )
			if self:GetNWInt("ScrapCount",0) < 4 and self:GetNWFloat("BuildPercent",0) == 0 then
				surface.SetTextColor( 255, 255, 255, self.PulseOne )
			else
				surface.SetTextColor( 255, 255, 255, 255 )
			end
			
			surface.DrawText( "[Scrap: ".. self:GetNWInt("ScrapCount",0) .."/4]" )
			
			
			
		cam.End3D2D()
		
		
		
	end
end




function ENT:SpawnWeapon()

	local Choice = CSSWeaponsTable[math.random(1,table.Count(CSSWeaponsTable))]
	
	local gun = ents.Create("spawned_weapon")
	gun:SetModel(weapons.GetStored(Choice).WorldModel)
	gun:SetWeaponClass(Choice)
	local gunPos = self:GetPos()
	gun:SetPos(Vector(gunPos.x, gunPos.y, gunPos.z + 27))
	gun.ShareGravgun = true
	gun.nodupe = true
	gun:Spawn()
	self.sparking = true

end