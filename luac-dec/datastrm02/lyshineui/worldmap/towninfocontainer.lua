local TownInfoContainer = {
  Properties = {
    TitleText = {
      default = EntityId()
    },
    SettlementImage = {
      default = EntityId()
    },
    SubtitleText = {
      default = EntityId()
    },
    CompanySection = {
      default = EntityId()
    },
    CompanyCrest = {
      default = EntityId()
    },
    GoverningText = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    FactionText = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    PropertyTaxAmount = {
      default = EntityId()
    },
    TradingTaxAmount = {
      default = EntityId()
    },
    CraftingFeeAmount = {
      default = EntityId()
    },
    RefiningFeeAmount = {
      default = EntityId()
    },
    CraftingStationsContainer = {
      default = EntityId()
    },
    CraftingStationElement = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    TerritoryOwnershipButton = {
      default = EntityId()
    },
    RunATownButton = {
      default = EntityId()
    }
  },
  isVisible = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TownInfoContainer)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function TownInfoContainer:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.Map.Connect(self.entityId, self)
  self.territoryIncentivesEnabled = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-territory-incentives-screen")
  self.CloseButton:SetCallback(self.OnClose, self)
  self.TerritoryOwnershipButton:SetCallback(self.OnTerritoryOwnershipPressed, self)
  self.RunATownButton:SetCallback(self.OnRunATownPressed, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_RIGHT)
end
function TownInfoContainer:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function TownInfoContainer:OnClose()
  self:SetIsVisible(false)
end
function TownInfoContainer:SetIsVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.35, {
      x = 0,
      alpha = 1,
      ease = "QuadOut"
    })
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.25, {
      x = 600,
      alpha = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
  end
end
function TownInfoContainer:IsCursorOnTownInfoContainer()
  if self.isVisible then
    local screenPoint = CursorBus.Broadcast.GetCursorPosition()
    local viewportRect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
    local viewportLeft = viewportRect:GetCenterX() - viewportRect:GetWidth() / 2
    if viewportLeft <= screenPoint.x then
      return true
    end
  end
  return false
end
function TownInfoContainer:OnShowPanel(panelType, settlementId, outpostId)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    self:SetIsVisible(false)
    return
  end
  if panelType ~= self.panelTypes.Town then
    self:SetIsVisible(false)
    return
  end
  self:SetIsVisible(true)
  self.settlementId = settlementId
  self.outpostId = outpostId
  self:UpdateTownInfo()
end
function TownInfoContainer:UpdateTerritoryName()
  local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(self.settlementId)
  local territoryName = posData.territoryName
  local vec2Pos = Vector2(posData.worldPos.x, posData.worldPos.y)
  local tractLoc = "@" .. MapComponentBus.Broadcast.GetTractAtPosition(vec2Pos)
  if territoryName == nil or territoryName == "" then
    territoryName = tractLoc
  end
  local tierInfo = TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId(self.settlementId, eTerritoryUpgradeType_Settlement)
  self.header = GetLocalizedReplacementText("@ui_township_header", {
    name = territoryName,
    tier = tierInfo.name
  })
  UiTextBus.Event.SetText(self.Properties.TitleText, self.header)
  local detailText = GetLocalizedReplacementText("@ui_settlement_major_resources", {territory = territoryName})
  UiTextBus.Event.SetTextWithFlags(self.Properties.SubtitleText, detailText, eUiTextSet_SetAsIs)
end
function TownInfoContainer:UpdateTownInfo()
  self:UpdateTerritoryName()
  local imagePath = "lyshineui/images/map/panelImages/mapPanel_settlement" .. self.settlementId .. ".dds"
  local invalidImagePath = "lyshineui/images/map/panelImages/mapPanel_settlement_default.dds"
  if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(imagePath) then
    imagePath = invalidImagePath
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.SettlementImage, imagePath)
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.settlementId)
  local guildIdValid = ownerData.guildId and ownerData.guildId:IsValid()
  if guildIdValid then
    local governingText = GetLocalizedReplacementText("@ui_governing_company", {
      name = ownerData.guildName
    })
    UiTextBus.Event.SetText(self.Properties.GoverningText, governingText)
    self.CompanyCrest:SetSmallIcon(ownerData.guildCrestData)
    UiElementBus.Event.SetIsEnabled(self.Properties.CompanyCrest, true)
    self.ScriptedEntityTweener:Set(self.Properties.GoverningText, {x = 48})
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.CompanySection, 92)
    self:UpdateFactionInfo(ownerData.faction)
    self:UpdateTerritoryTownOwnershipButtons(ownerData.faction, ownerData.guildId)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.CompanyCrest, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.GoverningText, "@ui_settlementinfo_notclaimed", eUiTextSet_SetLocalized)
    self.ScriptedEntityTweener:Set(self.Properties.GoverningText, {x = 0})
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryOwnershipButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RunATownButton, false)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.CompanySection, 50)
  end
  local taxData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceData(self.settlementId)
  UiTextBus.Event.SetText(self.Properties.PropertyTaxAmount, TerritoryDataHandler:GetTaxOrFeeDisplayText(taxData.houseFee, eTaxOrFee_PropertyTax))
  UiTextBus.Event.SetText(self.Properties.TradingTaxAmount, TerritoryDataHandler:GetTaxOrFeeDisplayText(taxData.tradingFee, eTaxOrFee_TradingTax))
  UiTextBus.Event.SetText(self.Properties.CraftingFeeAmount, TerritoryDataHandler:GetTaxOrFeeDisplayText(taxData.craftingFee, eTaxOrFee_CraftingFee))
  UiTextBus.Event.SetText(self.Properties.RefiningFeeAmount, TerritoryDataHandler:GetTaxOrFeeDisplayText(taxData.refiningFee, eTaxOrFee_RefiningFee))
end
function TownInfoContainer:UpdateFactionInfo(faction)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionText, false)
  if faction == eFactionType_None then
    return
  end
  local factionData = FactionCommon.factionInfoTable[faction]
  if factionData then
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionText, true)
    self.FactionIcon:SetBackground("lyshineui/images/icons/misc/empty.dds", factionData.crestBgColor)
    self.FactionIcon:SetForeground(factionData.crestFgSmall, factionData.crestBgColor)
    local factionText = GetLocalizedReplacementText("@ui_controlling_faction", {
      name = factionData.factionName
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.FactionText, factionText, eUiTextSet_SetAsIs)
  end
end
function TownInfoContainer:UpdateTerritoryTownOwnershipButtons(faction, guildId)
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryOwnershipButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RunATownButton, false)
  if not self.territoryIncentivesEnabled or faction == eFactionType_None then
    return
  end
  local localPlayerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  if localPlayerFaction and localPlayerFaction == faction then
    UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryOwnershipButton, true)
    local companySectionTargetHeight = 132
    if guildId and guildId:IsValid() then
      local localPlayerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
      if localPlayerGuildId and localPlayerGuildId:IsValid() and localPlayerGuildId == guildId then
        UiElementBus.Event.SetIsEnabled(self.Properties.RunATownButton, true)
        companySectionTargetHeight = 167
      end
    end
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.CompanySection, companySectionTargetHeight)
  end
end
function TownInfoContainer:OnTerritoryOwnershipPressed()
  if self.settlementId == nil then
    return
  end
  DynamicBus.TerritoryIncentivesNotifications.Broadcast.OnRequestTerritoryIncentivesScreen(self.settlementId)
end
function TownInfoContainer:OnRunATownPressed()
  DynamicBus.TerritoryIncentivesNotifications.Broadcast.OnRequestHowToRunATownPopup()
end
return TownInfoContainer
