local HousingAdditionalInfo = {
  Properties = {
    TerritoryNameText = {
      default = EntityId()
    },
    TaxesText = {
      default = EntityId()
    },
    PriceIcon = {
      default = EntityId()
    },
    PriceText = {
      default = EntityId()
    },
    StandingIcon = {
      default = EntityId()
    },
    StandingText = {
      default = EntityId()
    }
  },
  purchaseHouseProgressionId = 972880053
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(HousingAdditionalInfo)
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function HousingAdditionalInfo:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiInteractOptionAdditionalInfoRequestsBus, self.entityId)
end
function HousingAdditionalInfo:OnShutdown()
end
function HousingAdditionalInfo:PopulateAdditionalInfo(additionalInfoType, playerComponentData, interactionEntityId)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  if additionalInfoType == eInteractAdditionalType_HousingEnter then
    local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryNameText, territoryName, eUiTextSet_SetLocalized)
    local standingText
    local taxesPaid = true
    local ownedHouseData = PlayerHousingClientRequestBus.Broadcast.GetOwnedHouseDataOnPlotByEntityId(interactionEntityId)
    local taxesTextYOffset = -163
    local nameTextYOffset = -131.5
    if ownedHouseData then
      taxesPaid = ownedHouseData.taxesDue > timeHelpers:ServerNow()
      taxesTextYOffset = taxesTextYOffset - 50
      nameTextYOffset = nameTextYOffset - 50
    else
      local houseCostMultiplier = PlayerHousingClientRequestBus.Broadcast.GetHousingCostMultiplier(interactionEntityId, true)
      local plotCost = HousingPlotRequestBus.Event.GetPlotCost(interactionEntityId) * houseCostMultiplier
      UiTextBus.Event.SetTextWithFlags(self.Properties.PriceText, GetLocalizedCurrency(plotCost), eUiTextSet_SetAsIs)
      local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      local houseTypeData = HousingPlotRequestBus.Event.GetHouseTypeData(interactionEntityId)
      local requiredStanding = houseTypeData.territoryStandingRequiredRank
      local currentStanding = TerritoryDataHandler:GetTerritoryStandingRank(territoryId)
      if requiredStanding <= currentStanding then
        local territoryProgressionId = Math.CreateCrc32(tostring(territoryId))
        local purchaseHouseRank = ProgressionPointRequestBus.Event.GetTerritoryStandingRank(playerEntityId, territoryProgressionId, self.purchaseHouseProgressionId)
        if purchaseHouseRank == 0 then
          standingText = GetLocalizedReplacementText("@ui_house_purchase_standing_bonus_requirement", {standingName = territoryName})
        end
      else
        standingText = GetLocalizedReplacementText("@ui_house_purchase_standing_requirement", {standingValue = requiredStanding, standingName = territoryName})
      end
      if standingText then
        UiTextBus.Event.SetTextWithFlags(self.Properties.StandingText, standingText, eUiTextSet_SetAsIs)
      end
    end
    UiTransformBus.Event.SetLocalPositionY(self.Properties.TerritoryNameText, nameTextYOffset)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.TaxesText, taxesTextYOffset)
    UiElementBus.Event.SetIsEnabled(self.Properties.TaxesText, not taxesPaid)
    UiElementBus.Event.SetIsEnabled(self.Properties.PriceIcon, not ownedHouseData)
    UiElementBus.Event.SetIsEnabled(self.Properties.PriceText, not ownedHouseData)
    UiElementBus.Event.SetIsEnabled(self.Properties.StandingIcon, standingText)
    UiElementBus.Event.SetIsEnabled(self.Properties.StandingText, standingText)
  end
end
return HousingAdditionalInfo
