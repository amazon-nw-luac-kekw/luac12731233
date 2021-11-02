local triggerArea_states = {
  Properties = {
    Trigger = {
      default = EntityId(),
      description = "Entity containing a Trigger Area component."
    },
    StateGroup = {
      default = "Music_FTUE",
      description = "Name of the state group"
    },
    OnEnter = {
      ShouldTrigger = {
        default = true,
        description = "Should Trigger?"
      },
      State = {
        default = "",
        description = "State name to pass to the State Group."
      }
    },
    OnExit = {
      ShouldTrigger = {
        default = false,
        description = "Should trigger?"
      },
      State = {
        default = "",
        description = "State name to pass to the State Group."
      }
    }
  }
}
function triggerArea_states:OnActivate()
  self.triggerAreaHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.Trigger)
end
function triggerArea_states:OnDeactivate()
  if self.triggerAreaHandler ~= nil then
    self.triggerAreaHandler:Disconnect()
    self.triggerAreaHandler = nil
  end
end
function triggerArea_states:OnTriggerAreaEntered(enteringEntityId)
  if self.Properties.OnEnter.ShouldTrigger then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState(self.Properties.StateGroup, self.Properties.OnEnter.State)
  end
end
function triggerArea_states:OnTriggerAreaExited(enteringEntityId)
  if self.Properties.OnExit.ShouldTrigger then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState(self.Properties.StateGroup, self.Properties.OnExit.State)
  end
end
return triggerArea_states
