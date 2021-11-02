local structureDamageScript = {
  Properties = {
    rootEntity = {
      default = EntityId(),
      description = "Root EntityId",
      order = 1
    }
  }
}
function structureDamageScript:OnActivate()
  if TagComponentRequestBus.Event.HasTag(self.Properties.rootEntity, 2904472120) then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Structure_Damage_1_Small")
  elseif TagComponentRequestBus.Event.HasTag(self.Properties.rootEntity, 2797463353) then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Structure_Damage_1_Medium")
  elseif TagComponentRequestBus.Event.HasTag(self.Properties.rootEntity, 1628322332) then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Structure_Damage_1_Large")
  end
end
function structureDamageScript:OnDeactivate()
end
return structureDamageScript
