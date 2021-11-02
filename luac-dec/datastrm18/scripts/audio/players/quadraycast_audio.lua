local QuadRaycast = {
  Properties = {}
}
function QuadRaycast:OnActivate(characterId, characterPosition)
  self.occlusionRtpcName = {
    "Weight_Occlusion_FL",
    "Weight_Occlusion_FR",
    "Weight_Occlusion_BR",
    "Weight_Occlusion_BL"
  }
  self.occlusionValue = {
    0,
    0,
    0,
    0
  }
  self.vfxRays = {
    nil,
    nil,
    nil,
    nil
  }
  self.vfxColor = {
    "Green",
    "Red",
    "Blue",
    "Yellow"
  }
  self.rayCastConfig = {
    nil,
    nil,
    nil,
    nil
  }
  self.rayDirections = {
    Vector3(-1, 1, 0.5),
    Vector3(1, 1, 0.5),
    Vector3(1, -1, 0.5),
    Vector3(-1, -1, 0.5)
  }
  self.rayHits = {}
  if characterId ~= nil then
    self.entityIdOverride = characterId
    if characterPosition ~= nil then
      self.characterPosition = characterPosition
    else
      self.characterPosition = TransformBus.Event.GetWorldTranslation(self.entityIdOverride)
    end
    if PlayerComponentRequestsBus.Event.IsLocalPlayer(self.entityIdOverride) == true then
      self:DetectGeo(self.characterPosition)
    end
  end
end
function QuadRaycast:GetJitteredDirection(direction, k)
  local maxJitterXY = 0.5
  local maxJitterZ = 0.5
  local phi = math.random() * maxJitterXY
  local alpha = math.random() * maxJitterZ
  local theta = math.random() * 6.28318530718
  local sinPhi = Math.Sin(phi)
  local cosPhi = Math.Cos(alpha)
  local sinTheta = Math.Sin(theta)
  local cosTheta = Math.Cos(theta)
  local x = sinPhi * cosTheta
  local y = sinPhi * sinTheta
  local z = cosPhi
  local yAxis = Vector3(0, -direction.z, direction.y)
  yAxis:Normalize()
  local xAxis = Vector3.Cross(direction, yAxis)
  self.jitter = xAxis * x + yAxis * y + direction * z
  return self.jitter
end
function QuadRaycast:DetectGeo(playerPosition)
  for k = 4, 1, -1 do
    self.rayCastConfig[k] = RayCastConfiguration()
    self.rayCastConfig[k].origin = playerPosition + Vector3(0, 0, 2.5)
    self.rayCastConfig[k].maxDistance = 10
    self.rayCastConfig[k].maxHits = 1
    self.rayCastConfig[k].physicalEntityTypes = PhysicalEntityTypes.Static
    self.rayCastConfig[k].piercesSurfacesGreaterThan = 1
    self:GetJitteredDirection(self.rayDirections[k], k)
    if self.jitter ~= nil then
      self.rayCastConfig[k].direction = Vector3.GetNormalized(self.jitter)
      self.jitter = nil
    end
    self.rayHits[k] = PhysicsSystemRequestBus.Broadcast.RayCast(self.rayCastConfig[k])
    if #self.rayHits[k] == 0 then
      self.occlusionValue[k] = 0
    elseif 0 < #self.rayHits[k] then
      for i = 1, #self.rayHits[k] do
        local entityId = self.rayHits[k][i].entityId
        local entityName = GameEntityContextRequestBus.Broadcast.GetEntityName(entityId)
        local dist2Player = (self.rayHits[k][i].position - playerPosition):GetLength()
        local surfaceType = self.rayHits[k][i].surfaceTypeIndex
        if dist2Player <= 10 then
          self.occlusionValue[k] = (10 - dist2Player) / 10
        end
      end
    end
    if self.occlusionRtpcName[k] ~= nil and self.occlusionValue[k] ~= nil then
      AudioUtilsBus.Broadcast.SetGlobalAudioRtpc(self.occlusionRtpcName[k], self.occlusionValue[k])
      local occlusionSum = (self.occlusionValue[1] + self.occlusionValue[2] + self.occlusionValue[3] + self.occlusionValue[4]) / 4
      AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Weight_Occlusion_Sum", occlusionSum)
    end
  end
end
function QuadRaycast:OnDeactivate()
end
return QuadRaycast
