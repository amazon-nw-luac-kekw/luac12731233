local CeilingRaycast = {
  Properties = {}
}
function CeilingRaycast:OnActivate(characterId, characterPosition)
  if characterId ~= nil then
    self.entityIdOverride = characterId
    if characterPosition ~= nil then
      self.characterPosition = characterPosition
    else
      self.characterPosition = TransformBus.Event.GetWorldTranslation(self.entityIdOverride)
    end
    if PlayerComponentRequestsBus.Event.IsLocalPlayer(self.entityIdOverride) then
      self.isLocalPlayer = true
    else
      self.isLocalPlayer = false
    end
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_FL", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_FR", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_BR", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityIdOverride, "Delay_BL", 1)
  end
end
function CeilingRaycast:DetectCeiling(characterId, characterPosition)
  if characterId ~= nil then
    self.entityIdOverride = characterId
    if characterPosition ~= nil then
      self.characterPosition = characterPosition
    else
      self.characterPosition = TransformBus.Event.GetWorldTranslation(self.entityIdOverride)
    end
  end
  self.rayCastConfig = RayCastConfiguration()
  self.rayCastConfig.origin = self.characterPosition + Vector3(0, 0, 1.5)
  self.rayCastConfig.maxDistance = 30
  self.rayCastConfig.maxHits = 1
  self.rayCastConfig.physicalEntityTypes = PhysicalEntityTypes.Static
  self.rayCastConfig.piercesSurfacesGreaterThan = 1
  self.rayCastConfig.direction = Vector3(0, 0, 1)
  self.rayHits = PhysicsSystemRequestBus.Broadcast.RayCast(self.rayCastConfig)
  self.getHitCount = self.rayHits:GetHitCount()
  if #self.rayHits == 0 then
    DynamicBus.TopRaycast.Event.onTopRayHit(self.entityIdOverride, 0, nil, nil, nil, nil)
    AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Ceiling_Distance", 1)
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "Ceiling_Distance", 1)
  elseif 0 < #self.rayHits then
    for i = 1, #self.rayHits do
      local entityId = self.rayHits[i].entityId
      local entityName = GameEntityContextRequestBus.Broadcast.GetEntityName(entityId)
      local dist2Character = (self.rayHits[i].position - self.characterPosition):GetLength()
      local surfaceType = self.rayHits[i].surfaceTypeIndex
      if dist2Character <= 30 then
        if self.isLocalPlayer == true then
          local scaledCeilingDistance = dist2Character / 30
          AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Ceiling_Distance", scaledCeilingDistance)
          AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityIdOverride, "Ceiling_Distance", scaledCeilingDistance)
        end
        DynamicBus.TopRaycast.Event.onTopRayHit(self.entityIdOverride, self.getHitCount, dist2Character, surfaceType, entityId, entityName)
      end
    end
  end
end
function CeilingRaycast:OnDeactivate()
end
return CeilingRaycast
