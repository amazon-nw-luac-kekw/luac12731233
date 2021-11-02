local dataLayer = RequireScript("LyShineUI.UiDataLayer")
FactionControlCapturePoint = {
  factionControlDataBusHandler = nil,
  beamEmitterId = nil,
  settlementId = nil,
  ownerFaction = eFactionType_None,
  contestingFaction = eFactionType_None,
  beams = {
    [eFactionType_None] = {
      beam = "FactionControl.Neutral.Beam",
      contesting = "FactionControl.Neutral.Contested",
      celebrate = "FactionControl.Neutral.Celebrate"
    },
    [eFactionType_Faction1] = {
      beam = "FactionControl.Faction1.Beam",
      contesting = "FactionControl.Faction1.Contested",
      celebrate = "FactionControl.Faction1.Celebrate"
    },
    [eFactionType_Faction2] = {
      beam = "FactionControl.Faction2.Beam",
      contesting = "FactionControl.Faction2.Contested",
      celebrate = "FactionControl.Faction2.Celebrate"
    },
    [eFactionType_Faction3] = {
      beam = "FactionControl.Faction3.Beam",
      contesting = "FactionControl.Faction3.Contested",
      celebrate = "FactionControl.Faction3.Celebrate"
    }
  },
  Properties = {
    ownershipEntityId = {
      default = EntityId()
    }
  }
}
function FactionControlCapturePoint:OnActivate()
  self.ownerFaction = eFactionType_None
  self.contestingFaction = eFactionType_None
  local settlementId = TerritoryDetectorServiceRequestBus.Event.GetDetectedTerritoryId(self.entityId)
  if self.settlementId ~= settlementId then
    self:SwitchTerritory(settlementId)
  end
  self:UpdateBeam()
end
function FactionControlCapturePoint:SwitchTerritory(newTerritoryId)
  if self.settlementId ~= nil and self.factionControlDataBusHandler ~= nil then
    self.factionControlDataBusHandler:Disconnect(self.settlementId)
    self.factionControlDataBusHandler = nil
  end
  self.settlementId = newTerritoryId
  if newTerritoryId ~= nil then
    self.ownerFaction = FactionControlClientDataRequestBus.Event.GetFactionControlOwner(self.entityId)
    self.contestingFaction = FactionControlClientDataRequestBus.Event.GetFactionControlContestingFaction(self.entityId)
    self.factionControlDataBusHandler = FactionControlClientDataNotificationBus.Connect(self, newTerritoryId)
  else
    self.ownerFaction = eFactionType_None
    self.contestingFaction = eFactionType_None
  end
end
function FactionControlCapturePoint:OnDeactivate()
  if self.factionControlDataBusHandler ~= nil then
    self.factionControlDataBusHandler:Disconnect()
    self.factionControlDataBusHandler = nil
  end
  self:KillBeamParticle()
  dataLayer:UnregisterObservers(self)
end
function FactionControlCapturePoint:UpdateBeam()
  if self.contestingFaction ~= eFactionType_None then
    self:SetBeamParticle(self.beams[self.contestingFaction].contesting)
  else
    self:SetBeamParticle(self.beams[self.ownerFaction].beam)
  end
end
function FactionControlCapturePoint:SetBeamParticle(particleName)
  self:KillBeamParticle()
  local dir = TransformBus.Event.GetWorldRotationQuaternion(self.entityId) * Vector3(0, 0, 1)
  self.beamEmitterId = ParticleManagerBus.Broadcast.SpawnParticleAttachedToEntity(self.entityId, particleName, dir, false, EmitterFollow_IgnoreRotation)
end
function FactionControlCapturePoint:KillBeamParticle()
  if self.beamEmitterId ~= nil then
    ParticleManagerBus.Broadcast.StopParticle(self.beamEmitterId, true)
    self.beamEmitterId = nil
  end
end
function FactionControlCapturePoint:ShowCelebration()
  local pos = TransformBus.Event.GetWorldTranslation(self.entityId)
  local dir = TransformBus.Event.GetWorldRotationQuaternion(self.entityId) * Vector3(0, 0, 1)
  ParticleManagerBus.Broadcast.SpawnParticle(self.beams[self.ownerFaction].celebrate, pos, dir, false)
end
function FactionControlCapturePoint:OnFactionControlPointChanged(claimKey, controllingFaction, captureStatus, contestingFaction, progress)
  if claimKey == self.settlementId then
    if contestingFaction ~= eFactionType_None then
      if contestingFaction ~= self.contestingFaction then
        self.contestingFaction = contestingFaction
        self:UpdateBeam()
      end
    elseif self.ownerFaction ~= controllingFaction then
      self.ownerFaction = controllingFaction
      self.contestingFaction = eFactionType_None
      self:UpdateBeam()
      self:ShowCelebration()
    elseif self.contestingFaction ~= eFactionType_None then
      self.contestingFaction = eFactionType_None
      self:UpdateBeam()
    end
  end
end
return FactionControlCapturePoint
