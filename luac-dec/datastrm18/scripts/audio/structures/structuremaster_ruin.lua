local structureRuinScript = {
  Properties = {
    rootEntity = {
      default = EntityId(),
      description = "Root EntityId",
      order = 1
    }
  }
}
function structureRuinScript:OnActivate()
  if TagComponentRequestBus.Event.HasTag(self.Properties.rootEntity, 2904472120) then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Structure_Ruin_Small")
  elseif TagComponentRequestBus.Event.HasTag(self.Properties.rootEntity, 2797463353) then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Structure_Ruin_Medium")
  elseif TagComponentRequestBus.Event.HasTag(self.Properties.rootEntity, 1628322332) then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Structure_Ruin_Large")
  end
end
function structureRuinScript:OnDeactivate()
end
return structureRuinScript
