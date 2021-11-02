require("Scripts.Utils.TimingUtils")
local ExecuteAudioTrigger = {
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
    }
  }
}
function ExecuteAudioTrigger:ExecuteAudioTrigger()
  if self.Properties.delay > 0 then
    TimingUtils:Delay(self.entityId, self.Properties.delay, function()
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, self.Properties.audioTriggerName)
    end)
  else
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, self.Properties.audioTriggerName)
  end
end
function ExecuteAudioTrigger:Play()
  if self.Properties.delay > 0 then
    TimingUtils:Delay(self.entityId, self.Properties.delay, function()
      AudioTriggerComponentRequestBus.Event.Play(self.entityId)
    end)
  else
    AudioTriggerComponentRequestBus.Event.Play(self.entityId)
  end
end
return ExecuteAudioTrigger
