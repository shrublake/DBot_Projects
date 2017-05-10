AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-005'
ENT.Author = 'DBot'
ENT.Category = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/spartex117/key.mdl')
  if CLIENT then
    return 
  end
  self:SetSolid(SOLID_VPHYSICS)
  return self:SetMoveType(SOLID_VPHYSICS)
end
ENT.TryOpenDoor = function(self, ent)
  ent.SCP_INSANITY_LAST_OPEN = ent.SCP_INSANITY_LAST_OPEN or 0
  if ent.SCP_INSANITY_LAST_OPEN > CurTime() then
    return 
  end
  ent.SCP_INSANITY_LAST_OPEN = CurTime() + 5
  ent:Fire('unlock', '', 0)
  self:EmitSound("npc/metropolice/gear" .. tostring(math.random(1, 7)) .. ".wav")
  return timer.Simple(0.5, function()
    if IsValid(ent) then
      return ent:Fire('Open', '', 0)
    end
  end)
end
ENT.PhysicsCollide = function(self, data)
  local ent = data.HitEntity
  if not IsValid(ent) then
    return 
  end
  local nClass = ent:GetClass()
  if nClass == "func_door" or nClass == "func_door_rotating" or nClass == "prop_door_rotating" or nClass == "func_movelinear" or nClass == "prop_dynamic" then
    return self:TryOpenDoor(ent)
  end
end
