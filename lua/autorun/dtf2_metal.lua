DTF2 = DTF2 or { }
local plyMeta = FindMetaTable('Player')
DTF2_MAX_METAL = CreateConVar('dtf2_max_metal', '200', {
  FCVAR_ARCHIVE,
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Max metal per player')
local PlayerClass = {
  GetMaxTF2Metal = function(self)
    return self:GetNWInt('DTF2.MaxMetal', DTF2_MAX_METAL:GetInt())
  end,
  MaxTF2Metal = function(self)
    return self:GetNWInt('DTF2.MaxMetal', DTF2_MAX_METAL:GetInt())
  end,
  SetMaxTF2Metal = function(self, amount)
    if amount == nil then
      amount = DTF2_MAX_METAL:GetInt()
    end
    return self:SetNWInt('DTF2.MaxMetal', amount)
  end,
  ResetMaxTF2Metal = function(self)
    return self:SetNWInt('DTF2.MaxMetal', DTF2_MAX_METAL:GetInt())
  end,
  ResetTF2Metal = function(self)
    return self:SetNWInt('DTF2.Metal', DTF2_MAX_METAL:GetInt())
  end,
  GetTF2Metal = function(self)
    return self:GetNWInt('DTF2.Metal')
  end,
  SetTF2Metal = function(self, amount)
    if amount == nil then
      amount = self:GetTF2Metal()
    end
    return self:SetNWInt('DTF2.Metal', amount)
  end,
  AddTF2Metal = function(self, amount)
    if amount == nil then
      amount = 0
    end
    return self:SetNWInt('DTF2.Metal', self:GetTF2Metal() + amount)
  end,
  ReduceTF2Metal = function(self, amount)
    if amount == nil then
      amount = 0
    end
    return self:SetNWInt('DTF2.Metal', self:GetTF2Metal() - amount)
  end,
  RemoveTF2Metal = function(self)
    return self:SetNWInt('DTF2.Metal', 0)
  end,
  HasTF2Metal = function(self, amount)
    if amount == nil then
      amount = 0
    end
    return self:GetTF2Metal() >= amount
  end,
  SimulateTF2MetalRemove = function(self, amount, apply)
    if amount == nil then
      amount = 0
    end
    if apply == nil then
      apply = true
    end
    if self:GetTF2Metal() <= 0 then
      return 0
    end
    local oldMetal = self:GetTF2Metal()
    local newMetal = math.Clamp(oldMetal - amount, 0, self:GetMaxTF2Metal())
    if apply then
      self:SetTF2Metal(newMetal)
    end
    return oldMetal - newMetal
  end,
  SimulateTF2MetalAdd = function(self, amount, apply, playSound)
    if amount == nil then
      amount = 0
    end
    if apply == nil then
      apply = true
    end
    if playSound == nil then
      playSound = apply
    end
    if self:GetTF2Metal() >= self:GetMaxTF2Metal() then
      return 0
    end
    local oldMetal = self:GetTF2Metal()
    local newMetal = math.Clamp(oldMetal + amount, 0, self:GetMaxTF2Metal())
    if apply then
      self:SetTF2Metal(newMetal)
    end
    if playSound then
      self:EmitSound('items/ammo_pickup.wav', 50, 100, 0.7)
    end
    return newMetal - oldMetal
  end
}
for k, v in pairs(PlayerClass) do
  plyMeta[k] = v
end
if SERVER then
  return hook.Add('PlayerSpawn', 'DTF2.Metal', function(self)
    return self:ResetTF2Metal()
  end)
end
