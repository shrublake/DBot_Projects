include('shared.lua')
ENT.Initialize = function(self)
  self:DrawShadow(false)
  self:SetModel(self.IdleModel1)
  self:UpdateSequenceList()
  self.lastSeqModel = self.IdleModel1
  self.lastAnimTick = CurTime()
end
ENT.Think = function(self) end
ENT.Draw = function(self)
  self:DrawShadow(false)
  return self:DrawModel()
end
ENT.DrawHUD = function(self)
  return DTF2.DrawBuildingInfo(self)
end
ENT.GetHUDText = function(self)
  return ''
end
