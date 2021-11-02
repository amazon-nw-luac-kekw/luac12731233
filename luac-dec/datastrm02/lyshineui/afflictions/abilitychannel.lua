local AbilityChannel = {
  Properties = {
    AbilityChannelRadial = {
      default = EntityId()
    }
  },
  abilityCrcToDesc = {
    [3529122176] = "@ui_fast_travel_channel"
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AbilityChannel)
function AbilityChannel:OnInit()
  BaseElement.OnInit(self)
  self.AbilityChannelRadial:SetIsVisible(false, 0, true)
  self:BusConnect(AbilityCooldownNotificationsBus)
  self.AbilityChannelRadial:SetTimerCompleteCallback(self.OnTimerComplete, self)
end
function AbilityChannel:OnShutdown()
end
function AbilityChannel:GetDescriptionForAbility(abilityCrc)
  local descOverride = self.abilityCrcToDesc[abilityCrc]
  return descOverride and descOverride or "@ui_casting"
end
function AbilityChannel:OnAbilityTriggered(abilityCrc, cooldownTimeSeconds, isChanneled)
  if isChanneled then
    DynamicBus.AbilityChannelNotifications.Broadcast.OnAbilityStarted()
    self.AbilityChannelRadial:SetTimer(cooldownTimeSeconds)
    self.AbilityChannelRadial:SetDescription(self:GetDescriptionForAbility(abilityCrc))
    self.currentChanneledAbility = abilityCrc
  end
end
function AbilityChannel:OnAbilityCooldownReset(abilityCrc)
  if self.currentChanneledAbility == abilityCrc then
    self.AbilityChannelRadial:ForceStopTimer()
  end
end
function AbilityChannel:OnTimerComplete(abilityCrc)
  DynamicBus.AbilityChannelNotifications.Broadcast.OnAbilityEnded()
end
return AbilityChannel
