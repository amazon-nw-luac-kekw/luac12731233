local dataLayer = RequireScript("LyShineUI.UiDataLayer")
CapturePoint = {
  capturePointBusHandler = nil,
  beamEmitterId = nil,
  neutralBeamParticle = "Siege.CapturePoint.Beam_Neutral",
  friendlyBeamParticle = "Siege.CapturePoint.Beam_Friendly",
  enemyBeamParticle = "Siege.CapturePoint.Beam_Enemy",
  contestedBeamParticleFriendly = "Siege.CapturePoint.Beam_Contested_Blue",
  contestedBeamParticleEnemy = "Siege.CapturePoint.Beam_Contested_Red",
  contestedBeamParticleNeutral = "Siege.CapturePoint.Beam_Contested_Neutral",
  celebrationBeamParticleFriendly = "Siege.CapturePoint.Celebration_Blue",
  celebrationBeamParticleEnemy = "Siege.CapturePoint.Lost_Red",
  Properties = {
    ownershipEntityId = {
      default = EntityId()
    }
  }
}
function CapturePoint:OnActivate()
  self.capturePointBusHandler = CapturePointNotificationBus.Connect(self, self.entityId)
  self:UpdateBeamRaidAffiliation()
  dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self:UpdateBeamRaidAffiliation()
  end)
end
function CapturePoint:OnDeactivate()
  if self.capturePointBusHandler ~= nil then
    self.capturePointBusHandler:Disconnect()
  end
  self:KillBeamParticle()
  dataLayer:UnregisterObservers(self)
end
function CapturePoint:OnSiegeBegan()
  self:UpdateBeamRaidAffiliation()
end
function CapturePoint:OnSiegeEnded()
  self:KillBeamParticle()
end
function CapturePoint:OnCapturePointClaimed(raidId)
  self:UpdateBeamRaidAffiliation()
  local pos = TransformBus.Event.GetWorldTranslation(self.entityId)
  local dir = TransformBus.Event.GetWorldRotationQuaternion(self.entityId) * Vector3(0, 0, 1)
  if self:IsSameTeamAsLocalPlayer() then
    ParticleManagerBus.Broadcast.SpawnParticle(CapturePoint.celebrationBeamParticleFriendly, pos, dir, false)
  else
    ParticleManagerBus.Broadcast.SpawnParticle(CapturePoint.celebrationBeamParticleEnemy, pos, dir, false)
  end
end
function CapturePoint:OnCapturePointContested()
  if self:IsNeutral() then
    self:SetBeamParticle(self.contestedBeamParticleNeutral)
  elseif self:IsSameTeamAsLocalPlayer() then
    self:SetBeamParticle(self.contestedBeamParticleEnemy)
  else
    self:SetBeamParticle(self.contestedBeamParticleFriendly)
  end
end
function CapturePoint:OnCapturePointUncontested()
  self:UpdateBeamRaidAffiliation()
end
function CapturePoint:UpdateBeamRaidAffiliation()
  if self:IsNeutral() then
    self:SetBeamParticle(self.neutralBeamParticle)
  elseif self:IsSameTeamAsLocalPlayer() then
    self:SetBeamParticle(self.friendlyBeamParticle)
  else
    self:SetBeamParticle(self.enemyBeamParticle)
  end
end
function CapturePoint:SetBeamParticle(particleName)
  self:KillBeamParticle()
  local dir = TransformBus.Event.GetWorldRotationQuaternion(self.entityId) * Vector3(0, 0, 1)
  self.beamEmitterId = ParticleManagerBus.Broadcast.SpawnParticleAttachedToEntity(self.entityId, particleName, dir, false, EmitterFollow_IgnoreRotation)
end
function CapturePoint:KillBeamParticle()
  if self.beamEmitterId ~= nil then
    ParticleManagerBus.Broadcast.StopParticle(self.beamEmitterId, true)
    self.beamEmitterId = nil
  end
end
function CapturePoint:IsSameTeamAsLocalPlayer()
  local curRaidId = GroupInfoRequestBus.Event.GetRaidId(self.Properties.ownershipEntityId)
  local localPlayerRaidId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  local curRaidIsValid = curRaidId ~= nil and curRaidId:IsValid()
  local localPlayerRaidIsValid = localPlayerRaidId ~= nil and localPlayerRaidId:IsValid()
  return curRaidIsValid and localPlayerRaidIsValid and curRaidId == localPlayerRaidId
end
function CapturePoint:IsNeutral()
  local curRaidId = GroupInfoRequestBus.Event.GetRaidId(self.Properties.ownershipEntityId)
  return curRaidId == nil or curRaidId:IsValid() == false
end
return CapturePoint
