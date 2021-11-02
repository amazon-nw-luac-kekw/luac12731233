local FlyoutRow_CapitalInfo = {
  Properties = {
    HeaderText = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    ImageMask = {
      default = EntityId()
    },
    Subtext = {
      default = EntityId()
    },
    CompanyText = {
      default = EntityId()
    },
    ContentContainer = {
      default = EntityId()
    },
    GuildCrestBackground = {
      default = EntityId()
    },
    GuildCrestForeground = {
      default = EntityId()
    },
    CompanySection = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    }
  }
}
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_CapitalInfo)
function FlyoutRow_CapitalInfo:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
end
function FlyoutRow_CapitalInfo:SetData(data)
  if not (data and data.capitalType) or not data.id then
    Log("[FlyoutRow_CapitalInfo] Error: invalid data passed to SetData")
    return
  end
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(data.id)
  local territoryName = data.territoryName
  local capitalTypeLoc = "@ui_" .. data.capitalType
  local header = territoryName
  if data.capitalType ~= "territory" then
    local tierType = eTerritoryUpgradeType_Settlement
    if data.capitalType == "fortress" then
      tierType = eTerritoryUpgradeType_Fortress
    end
    local tierInfo = TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId(data.id, tierType)
    header = GetLocalizedReplacementText(capitalTypeLoc .. "_header", {
      name = territoryName,
      tier = tierInfo.name
    })
  end
  local companyText = GetLocalizedReplacementText("@ui_governing_company", {
    name = ownerData.guildName
  })
  if ownerData.guildId and ownerData.guildId:IsValid() then
    local backgroundImage = GetSmallImagePath(ownerData.guildCrestData.backgroundImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCrestBackground, backgroundImage)
    UiImageBus.Event.SetColor(self.Properties.GuildCrestBackground, ownerData.guildCrestData.backgroundColor)
    local foregroundImage = GetSmallImagePath(ownerData.guildCrestData.foregroundImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCrestForeground, foregroundImage)
    UiImageBus.Event.SetColor(self.Properties.GuildCrestForeground, ownerData.guildCrestData.foregroundColor)
    UiElementBus.Event.SetIsEnabled(self.Properties.CompanySection, data.enableCompany)
    UiElementBus.Event.SetIsEnabled(self.Properties.Divider, data.enableCompany)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ContentContainer, 170)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ImageMask, 170)
    if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") and data.capitalType == "fortress" then
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.ContentContainer, 88)
    end
  else
    companyText = ""
    UiElementBus.Event.SetIsEnabled(self.Properties.CompanySection, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Divider, false)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ContentContainer, 108)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ImageMask, 170)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, header, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Subtext, capitalTypeLoc, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CompanyText, companyText, eUiTextSet_SetLocalized)
  local flyoutImage = "lyShineui/images/map/tooltipimages/mapTooltip_" .. data.capitalType .. data.id .. ".dds"
  local invalidImagePath = "lyShineui/images/map/tooltipimages/mapTooltip_" .. data.capitalType .. "_default.dds"
  if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(flyoutImage) then
    flyoutImage = invalidImagePath
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Image, flyoutImage)
  local containerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ContentContainer)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, containerHeight)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, containerHeight)
end
return FlyoutRow_CapitalInfo
