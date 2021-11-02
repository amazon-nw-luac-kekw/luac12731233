require("Scripts.Utils.TimingUtils")
local OnDeactivateScript = {
  Properties = {
    audioTriggerName = {
      default = "",
      description = "Name of audio trigger to execute.",
      order = 0
    },
    delay = {
      default = 0,
      description = "Delay in seconds before audio trigger is executed.",
      order = 1
    },
    playOnActivate = {
      default = false,
      description = "Or play sound on activate",
      order = 2
    }
  }
}
function OnDeactivateScript:OnActivate()
  if not self.Properties.playOnActivate then
    return
  end
  self:PlaySound()
end
function OnDeactivateScript:OnDeactivate()
  if self.Properties.playOnActivate then
    return
  end
  self:PlaySound()
end
function OnDeactivateScript:PlaySound()
  if not self.audioTriggerOptions then
    self.audioTriggerOptions = AudioTriggerOptions()
  end
  self.audioTriggerOptions.obstructionType = eAudioObstructionType_SingleRay
  if self.Properties.delay > 0 then
    TimingUtils:Delay(self.entityId, self.Properties.delay, function()
      local objectPosition = TransformBus.Event.GetWorldTranslation(self.entityId)
      AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions(self.Properties.audioTriggerName, objectPosition, self.audioTriggerOptions)
    end)
  else
    local objectPosition = TransformBus.Event.GetWorldTranslation(self.entityId)
    AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions(self.Properties.audioTriggerName, objectPosition, self.audioTriggerOptions)
  end
end
return OnDeactivateScript
