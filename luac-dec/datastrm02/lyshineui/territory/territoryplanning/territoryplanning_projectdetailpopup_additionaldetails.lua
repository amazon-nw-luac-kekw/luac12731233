local TerritoryPlanning_ProjectDetailPopup_AdditionalDetails = {
  Properties = {
    DetailRewardMultiple = {
      default = EntityId()
    },
    DetailHeader = {
      default = EntityId()
    },
    TierContainer = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_ProjectDetailPopup_AdditionalDetails)
local territoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function TerritoryPlanning_ProjectDetailPopup_AdditionalDetails:OnInit()
  BaseElement.OnInit(self)
end
function TerritoryPlanning_ProjectDetailPopup_AdditionalDetails:OnShutdown()
end
function TerritoryPlanning_ProjectDetailPopup_AdditionalDetails:SetProjectDetailData(upgradeData)
  local detailData = territoryDataHandler:GetAdditionalDetailsForProjectUpgrade(upgradeData.projectId, upgradeData.upgradeType)
  if upgradeData.upgradeType == eTerritoryUpgradeType_Lifestyle then
    UiTextBus.Event.SetTextWithFlags(self.Properties.DetailHeader, "@ui_project_reward", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.TierContainer, false)
    self.ScriptedEntityTweener:Set(self.entityId, {y = 262})
  elseif upgradeData.upgradeType == eTerritoryUpgradeType_Fortress then
    UiTextBus.Event.SetTextWithFlags(self.Properties.DetailHeader, "@ui_project_reward", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.TierContainer, true)
    self.ScriptedEntityTweener:Set(self.entityId, {y = 296})
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.DetailHeader, "@ui_craftable_items", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.TierContainer, true)
    self.ScriptedEntityTweener:Set(self.entityId, {y = 296})
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DetailRewardMultiple, true)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.DetailRewardMultiple)
  for i = 1, #childElements do
    local details = detailData[i]
    local uiElement = childElements[i]
    uiElement = self.registrar:GetEntityTable(uiElement)
    if details then
      uiElement:SetAdditionalItemDetail(details.upgradeDetailIcon, details.upgradeDetailText)
    else
      uiElement:SetAdditionalItemDetail()
    end
  end
end
function TerritoryPlanning_ProjectDetailPopup_AdditionalDetails:OnClose()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
return TerritoryPlanning_ProjectDetailPopup_AdditionalDetails
