local DungeonAdditionalInfo = {
  Properties = {
    LevelRequirementIcon = {
      default = EntityId()
    },
    LevelRequirementText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DungeonAdditionalInfo)
function DungeonAdditionalInfo:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiInteractOptionAdditionalInfoRequestsBus, self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    self.rootPlayerId = rootEntityId
  end)
end
function DungeonAdditionalInfo:OnShutdown()
end
function DungeonAdditionalInfo:PopulateAdditionalInfo(additionalInfoType, playerComponentData, interactionEntityId)
  if additionalInfoType == eInteractAdditionalType_DungeonEnter then
    local isArenaActive = not ArenaRequestBus.Event.IsArenaActive(interactionEntityId)
    UiElementBus.Event.SetIsEnabled(self.entityId, isArenaActive)
    if isArenaActive then
      local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
      local gameModeId = 1784989592
      local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.rootPlayerId, gameModeId)
      local levelRequirementText = GetLocalizedReplacementText("@ui_dungeon_level_requirement", {
        level = gameModeData.requiredLevel
      })
      UiTextBus.Event.SetText(self.Properties.LevelRequirementText, levelRequirementText)
      if playerLevel >= gameModeData.requiredLevel then
        UiImageBus.Event.SetColor(self.Properties.LevelRequirementIcon, self.UIStyle.COLOR_GREEN)
        UiTextBus.Event.SetColor(self.Properties.LevelRequirementText, self.UIStyle.COLOR_GREEN)
      else
        UiImageBus.Event.SetColor(self.Properties.LevelRequirementIcon, self.UIStyle.COLOR_RED_DARK)
        UiTextBus.Event.SetColor(self.Properties.LevelRequirementText, self.UIStyle.COLOR_RED_MEDIUM)
      end
    end
  end
end
return DungeonAdditionalInfo
