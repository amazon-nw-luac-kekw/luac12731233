require("Scripts.Utils.TimingUtils")
require("Scripts._Common.Common")
local ceilingRaycastAudioNPC = RequireScript("Scripts.Audio.NPCs.ceilingRaycastNPC_Audio")
local ProjectileAudio = {
  Properties = {
    projectileName = {
      default = "",
      description = " EX : 'Regurgitator_Gooball_loop' -> 'Play_SFX_Regurgitator_Gooball_loop'",
      order = 0
    },
    unitName = {
      default = "",
      description = " EX : 'DrownedGrenader' loads bank -> 'projectile_DrownedGrenader'",
      order = 1
    },
    timeToDestroy = {
      default = 0,
      description = " auto triggers stop event after this amount of time",
      order = 2
    },
    tractDetection = {
      default = false,
      description = "Enable tract detection to use different tails",
      order = 3
    }
  }
}
local prevEnvName
function ProjectileAudio:OnActivate()
  if self.Properties.unitName == nil or self.Properties.unitName == "" then
    return
  end
  if self.Properties.projectileName == nil or self.Properties.projectileName == "" then
    return
  end
  self.bankName = "projectile_" .. self.Properties.unitName
  AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, self.bankName)
  self.playEventName = "Play_SFX_" .. self.Properties.projectileName
  self.stopEventName = "Stop_SFX_" .. self.Properties.projectileName
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, self.playEventName)
  if self.Properties.timeToDestroy > 0 and self.Properties.timeToDestroy ~= nil then
    TimingUtils:Delay(self.entityId, self.Properties.timeToDestroy, function()
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, self.stopEventName)
    end)
  end
  self.acousticList = {
    "00_Small",
    "00_Small",
    "01_Medium",
    "01_Medium",
    "02_Big",
    "03_Large",
    "03_Large"
  }
  self.acousticRange = {
    0,
    5,
    10,
    15,
    20,
    25,
    30
  }
  self.position = TransformBus.Event.GetWorldTranslation(self.entityId)
  if self.Properties.tractDetection == true then
    local positionXY = Vector2.ConstructFromValues(self.position.x, self.position.y)
    local tractAtPosition = MapComponentBus.Broadcast.GetTractAtPosition(positionXY)
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityId, "Tract_switch", tostring(tractAtPosition))
  end
  if self.TopRaycastNPCBusHandler == nil then
    self.TopRaycastNPCBusHandler = DynamicBus.TopRaycastNPC.Connect(self.entityId, self)
  end
  ceilingRaycastAudioNPC:DetectCeiling(self.entityId, self.position)
end
function ProjectileAudio:onTopRayHitNPC(getHitCount, dist2Proj, surfaceType, entityId, entityName)
  if getHitCount == 0 then
    self:setAcoustics(0, "Acou_Ext")
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_FL", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_FR", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_BR", 1)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_BL", 1)
  else
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_FL", 0)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_FR", 0)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_BR", 0)
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "Delay_BL", 0)
    if surfaceType ~= nil and (surfaceType == 109 or surfaceType == 104 or surfaceType == 0) then
      for i = 1, #self.acousticRange do
        if dist2Proj < self.acousticRange[i] and dist2Proj > self.acousticRange[i - 1] then
          local envName, acouName
          if self.surfaceType == 104 or self.surfaceType == 0 then
            envName = "ENV_INT_" .. tostring(self.acousticList[i])
            acouName = "Acou_Int_" .. tostring(self.acousticList[i])
          else
            envName = "ENV_INT_" .. tostring(self.acousticList[i]) .. "_Stone"
            acouName = "Acou_Int_" .. tostring(self.acousticList[i]) .. "_Stone"
          end
          self:setAcoustics(1, acouName, envName)
        end
      end
    end
  end
end
function ProjectileAudio:setAcoustics(envValue, acousticName, envName)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityId, "Acoustics", acousticName)
  if envName ~= nil then
    AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, envName, envValue)
    if prevEnvName ~= nil and prevEnvName ~= envName then
      AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, prevEnvName, 0)
    end
  end
  prevEnvName = envName
end
function ProjectileAudio:OnDeactivate()
  if self.Properties.projectileName == nil or self.Properties.projectileName == "" then
    return
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, self.stopEventName)
end
return ProjectileAudio
