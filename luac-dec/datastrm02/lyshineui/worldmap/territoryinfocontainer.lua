local TerritoryInfoContainer = {
  Properties = {
    TitleText = {
      default = EntityId()
    },
    ContentContainer = {
      default = EntityId()
    },
    TerritoryImage = {
      default = EntityId()
    },
    CompanyCrest = {
      default = EntityId()
    },
    GoverningText = {
      default = EntityId()
    },
    RecommendedLevelSection = {
      default = EntityId()
    },
    RecommendedLevelText = {
      default = EntityId()
    },
    RecommendedLevelIcon = {
      default = EntityId()
    },
    DarknessText = {
      default = EntityId()
    },
    DarknessLevelIcon = {
      default = EntityId()
    },
    TerritoryOwnershipContainer = {
      default = EntityId()
    },
    TerritoryOwnershipAppearBefore = {
      default = EntityId()
    },
    TerritoryOwnershipButton = {
      default = EntityId()
    },
    TerritoryOwnershipButtonText = {
      default = EntityId()
    },
    StandingProgressBar = {
      default = EntityId()
    },
    StandingProgressBarLabel = {
      default = EntityId()
    },
    StandingTitleText = {
      default = EntityId()
    },
    StandingLevelText = {
      default = EntityId()
    },
    BonusesContent = {
      default = EntityId()
    },
    NoBonusesText = {
      default = EntityId()
    },
    RedeemTokensButton = {
      default = EntityId()
    },
    TokensCount = {
      default = EntityId()
    },
    BonusList = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    QuestionMark = {
      default = EntityId()
    },
    BonusesSection = {
      default = EntityId()
    },
    DarknessSection = {
      default = EntityId()
    },
    StandingSection = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    FactionText = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  },
  isVisible = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryInfoContainer)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local DifficultyColors = RequireScript("LyShineUI._Common.DifficultyColors")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function TerritoryInfoContainer:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.Map.Connect(self.entityId, self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.CloseButton:SetCallback(self.OnClose, self)
  self.RedeemTokensButton:SetCallback(self.OnRedeemTokens, self)
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.QuestionMark:SetSize(30, 30)
  self.QuestionMark:SetCallback(self.OnTerritoryOwnershipPressed, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_RIGHT)
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  self.maxDisplayLevel = ProgressionRequestBus.Event.GetMaxLevel(rootEntityId) + 1
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CharacterId", function(self, localCharacterIdString)
    self.localCharacterIdString = localCharacterIdString
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.territoryIncentivesEnabled = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-territory-incentives-screen")
  self.RedeemTokensButton:SetButtonStyle(self.RedeemTokensButton.BUTTON_STYLE_CTA)
end
function TerritoryInfoContainer:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
  self.socialDataHandler:OnDeactivate()
end
function TerritoryInfoContainer:OnClose()
  self:SetIsVisible(false)
end
function TerritoryInfoContainer:SetIsVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.35, {x = 0, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
      x = 600,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
  end
end
function TerritoryInfoContainer:IsCursorOnTerritoryInfoContainer()
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
function TerritoryInfoContainer:OnShowPanel(panelType, territoryId)
  self.panelType = panelType
  if panelType ~= self.panelTypes.Territory or territoryId == 0 then
    self:SetIsVisible(false)
    return
  end
  self:SetIsVisible(true)
  self:SetTerritoryInfo(territoryId)
end
function TerritoryInfoContainer:SetTerritoryInfo(territoryId)
  self.territoryId = territoryId
  local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(territoryId)
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(territoryId)
  local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  local territoryDefinition = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryId)
  local tractLoc = ""
  if posData.worldPos.x ~= 0 and posData.worldPos.y ~= 0 then
    local vec2Pos = Vector2(posData.worldPos.x, posData.worldPos.y)
    tractLoc = "@" .. MapComponentBus.Broadcast.GetTractAtPosition(vec2Pos)
    UiElementBus.Event.SetIsEnabled(self.Properties.BonusesSection, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DarknessSection, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.StandingSection, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonContainer, true)
    self.isClaimable = true
  else
    local vec3Pos = MapComponentBus.Broadcast.GetTerritoryPosition(territoryId)
    local vec2Pos = Vector2(vec3Pos.x, vec3Pos.y)
    tractLoc = "@" .. MapComponentBus.Broadcast.GetTractAtPosition(vec2Pos)
    UiElementBus.Event.SetIsEnabled(self.Properties.BonusesSection, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.DarknessSection, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.StandingSection, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonContainer, false)
    self.isClaimable = false
  end
  if territoryName == nil or territoryName == "" then
    territoryName = tractLoc
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, territoryName, eUiTextSet_SetLocalized)
  local imagePath = "lyshineui/images/map/panelImages/mapPanel_territory" .. self.territoryId .. ".dds"
  local invalidImagePath = "lyshineui/images/map/panelImages/mapPanel_territory_default.dds"
  if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(imagePath) then
    imagePath = invalidImagePath
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.TerritoryImage, imagePath)
  local recommendedLevelLow = territoryDefinition.recommendedLevel
  local recommendedLevelHigh = territoryDefinition.maximumLevel
  local difficultyString
  if recommendedLevelLow >= self.maxDisplayLevel then
    difficultyString = GetLocalizedReplacementText("@ui_level_identifier", {
      level = tostring(self.maxDisplayLevel) .. "+"
    })
  elseif recommendedLevelHigh > self.maxDisplayLevel then
    difficultyString = GetLocalizedReplacementText("@ui_recommended_level_range", {
      lowNumber = recommendedLevelLow,
      highNumber = tostring(self.maxDisplayLevel) .. "+"
    })
  else
    difficultyString = GetLocalizedReplacementText("@ui_recommended_level_range", {lowNumber = recommendedLevelLow, highNumber = recommendedLevelHigh})
  end
  UiTextBus.Event.SetText(self.Properties.RecommendedLevelText, difficultyString)
  local difficultyColor = DifficultyColors:GetColorRange(recommendedLevelLow, recommendedLevelHigh)
  UiTextBus.Event.SetColor(self.Properties.RecommendedLevelText, difficultyColor)
  local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
  UiImageBus.Event.SetColor(self.Properties.RecommendedLevelIcon, recommendedLevelLow < playerLevel and self.UIStyle.COLOR_GREEN_BRIGHT or self.UIStyle.COLOR_RED)
  local territoryDarknessThreshold = LandClaimRequestBus.Broadcast.GetTerritoryDarknessThreshold(territoryId)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DarknessText, "@ui_darkness_threshold_desc_" .. territoryDarknessThreshold, eUiTextSet_SetLocalized)
  local darknessIconPath = "lyshineui/images/icons/misc/icon_darknessLevel" .. territoryDarknessThreshold .. ".png"
  UiImageBus.Event.SetSpritePathname(self.Properties.DarknessLevelIcon, darknessIconPath)
  if territoryDarknessThreshold == 0 then
    UiImageBus.Event.SetColor(self.Properties.DarknessLevelIcon, self.UIStyle.COLOR_GREEN)
  else
    UiImageBus.Event.SetColor(self.Properties.DarknessLevelIcon, self.UIStyle.COLOR_RED_DARK)
  end
  local guildIdValid = ownerData.guildId and ownerData.guildId:IsValid()
  if guildIdValid then
    local governingText = GetLocalizedReplacementText("@ui_governing_company", {
      name = ownerData.guildName
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.GoverningText, governingText, eUiTextSet_SetAsIs)
    self.CompanyCrest:SetSmallIcon(ownerData.guildCrestData)
    UiElementBus.Event.SetIsEnabled(self.Properties.CompanyCrest, true)
    self.ScriptedEntityTweener:Set(self.Properties.GoverningText, {x = 48})
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.CompanyCrest, false)
    if self.isClaimable then
      UiTextBus.Event.SetTextWithFlags(self.Properties.GoverningText, "@ui_territoryinfo_notclaimed", eUiTextSet_SetLocalized)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.GoverningText, "@ui_territoryinfo_notclaimable", eUiTextSet_SetLocalized)
    end
    self.ScriptedEntityTweener:Set(self.Properties.GoverningText, {x = 0})
  end
  self:UpdateFactionInfo(ownerData.faction)
  self:UpdateTerritoryOwnership(ownerData.faction)
  self:UpdateTerritoryInfoContainerBonuses()
end
function TerritoryInfoContainer:UpdateFactionInfo(faction)
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
function TerritoryInfoContainer:UpdateTerritoryOwnership(faction)
  local enableTerritoryOwnershipButton = false
  if self.territoryIncentivesEnabled and faction ~= eFactionType_None then
    local localPlayerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    if localPlayerFaction and localPlayerFaction == faction then
      enableTerritoryOwnershipButton = true
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryOwnershipButton, enableTerritoryOwnershipButton)
  UiElementBus.Event.Reparent(self.Properties.TerritoryOwnershipContainer, enableTerritoryOwnershipButton and self.Properties.ContentContainer or EntityId(), enableTerritoryOwnershipButton and self.Properties.TerritoryOwnershipAppearBefore or EntityId())
end
function TerritoryInfoContainer:UpdateTerritoryInfoContainerBonuses()
  if self.panelType ~= self.panelTypes.Territory then
    return
  end
  local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId)
  local standing = TerritoryDataHandler:GetTerritoryStanding(self.territoryId)
  local summaryData = LandClaimRequestBus.Broadcast.GetTerritoryProgressionData(self.territoryId)
  local progressionId = Math.CreateCrc32(tostring(self.territoryId))
  local currentLevel = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, progressionId) or 0
  local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, progressionId) or 0
  local maxProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, progressionId, currentLevel) or 1
  UiTextBus.Event.SetTextWithFlags(self.Properties.StandingLevelText, tostring(currentLevel), eUiTextSet_SetAsIs)
  local standingText = GetLocalizedReplacementText("@ui_standing_title_display", {
    standing = standing.displayName,
    territory = territoryName
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.StandingTitleText, standingText, eUiTextSet_SetLocalized)
  local percent = currentProgress / maxProgress
  self.ScriptedEntityTweener:Set(self.Properties.StandingProgressBar, {scaleX = percent})
  UiTextBus.Event.SetText(self.Properties.StandingProgressBarLabel, currentProgress .. " / " .. maxProgress)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TokensCount, tostring(standing.tokens), eUiTextSet_SetAsIs)
  self.RedeemTokensButton:SetEnabled(0 < standing.tokens)
  local bonuses = TerritoryDataHandler:GetCurrentTerritoryRewards(self.territoryId)
  UiElementBus.Event.SetIsEnabled(self.Properties.NoBonusesText, #bonuses == 0)
  UiElementBus.Event.SetIsEnabled(self.Properties.BonusList, 0 < #bonuses)
  if 0 < #bonuses then
    UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.BonusList, #bonuses)
    for i = 1, #bonuses do
      local bonusData = bonuses[i]
      local bonusItem = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.BonusList, i - 1))
      local description = GetLocalizedReplacementText(bonusData.description, {
        territory = bonusData.territoryName,
        stat = bonusData.stat,
        description = bonusData.description,
        value = bonusData.value
      })
      UiTextBus.Event.SetTextWithFlags(bonusItem.Properties.Name, bonusData.category, eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(bonusItem.Properties.Description, description, eUiTextSet_SetLocalized)
      local icon = string.sub(bonusData.bg, 1, string.len(bonusData.bg) - 4) .. "_icon.png"
      UiImageBus.Event.SetSpritePathname(bonusItem.Properties.Icon, icon)
    end
    local bonusContentPadding = 40
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.BonusesContent, bonusContentPadding + 90 + #bonuses * 90)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.BonusesSection, bonusContentPadding + 0 + #bonuses * 90)
  else
    UiTextBus.Event.SetText(self.Properties.NoBonusesText, GetLocalizedReplacementText("@ui_territory_standing_no_bonuses", {territory = territoryName}))
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.BonusesContent, 60)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.BonusesSection, 60)
  end
end
function TerritoryInfoContainer:OnRedeemTokens()
  DynamicBus.TerritoryBonusPopupBus.Broadcast.OpenTerritoryBonusPopup(self.territoryId)
end
function TerritoryInfoContainer:OnTerritoryOwnershipPressed()
  if self.territoryId == nil then
    return
  end
  DynamicBus.TerritoryIncentivesNotifications.Broadcast.OnRequestTerritoryIncentivesScreen(self.territoryId)
end
function TerritoryInfoContainer:OnHoverTerritoryOwnershipButton()
  self.ScriptedEntityTweener:Play(self.Properties.TerritoryOwnershipButtonText, 0.15, {
    textColor = self.UIStyle.COLOR_WHITE
  })
end
function TerritoryInfoContainer:OnUnHoverTerritoryOwnershipButton()
  self.ScriptedEntityTweener:Play(self.Properties.TerritoryOwnershipButtonText, 0.15, {
    textColor = self.UIStyle.COLOR_TAN
  })
end
return TerritoryInfoContainer
