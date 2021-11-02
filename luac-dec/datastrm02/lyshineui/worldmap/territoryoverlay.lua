BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local DifficultyColors = RequireScript("LyShineUI._Common.DifficultyColors")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local TerritoryOverlay = {
  Properties = {
    TerritoryInfo = {
      default = EntityId()
    },
    TerritoryName = {
      default = EntityId()
    },
    TerritoryNameBackground = {
      default = EntityId()
    },
    CompanyNameContainer = {
      default = EntityId()
    },
    CompanyName = {
      default = EntityId()
    },
    DifficultyContainer = {
      default = EntityId()
    },
    DifficultyText = {
      default = EntityId()
    },
    DarknessLevelContainer = {
      default = EntityId()
    },
    DarknessLevelIcon = {
      default = EntityId()
    },
    TerritoryOverlayImage = {
      default = EntityId()
    },
    TerritoryOutlineImage = {
      default = EntityId()
    },
    TextContainer = {
      default = EntityId()
    },
    TerritoryCrest = {
      default = EntityId()
    },
    TerritoryIconContainer = {
      default = EntityId()
    },
    TerritoryIconButton = {
      default = EntityId()
    },
    TerritoryNameContainer = {
      default = EntityId()
    },
    ConflictBg = {
      default = EntityId()
    },
    ConflictText = {
      default = EntityId()
    },
    InfluenceWarWidget = {
      default = EntityId()
    }
  },
  DEFAULT_IMAGE_PATH = "TerritoryOverlays",
  OUTLINE_IMAGE_PATH = "TerritoryOverlays_outline",
  ZOOM_MIN = 4,
  ZOOM_MAX = 7,
  DEFAULT_CREST_SIZE = 80,
  zoomLevel = 7,
  outlineOpacity = 0.25,
  enableTerritoryMechanics = false
}
BaseElement:CreateNewElement(TerritoryOverlay)
function TerritoryOverlay:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  self.isVisible = false
  self.ownerGuildId = GuildId()
  self.settlementKey = 0
  self.territoryDarknessThreshold = 0
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.territoryColor = self.UIStyle.COLOR_TERRITORY_UNCLAIMED
  UiImageBus.Event.SetColor(self.Properties.TerritoryOutlineImage, self.territoryColor)
  UiImageBus.Event.SetColor(self.Properties.TerritoryOverlayImage, self.territoryColor)
  self.textContainerPosition = UiTransformBus.Event.GetLocalPositionY(self.Properties.TextContainer)
  self.territoryNameHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.TerritoryNameContainer)
  self.difficultyHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.DifficultyContainer)
  self.darknessLevelHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.DarknessLevelContainer)
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  self.maxDisplayLevel = ProgressionRequestBus.Event.GetMaxLevel(rootEntityId) + 1
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableTerritoryMechanics", function(self, enableTerritoryMechanics)
    if enableTerritoryMechanics ~= nil then
      self.enableTerritoryMechanics = enableTerritoryMechanics
      self:UpdateTerritoryInfo()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isLandClaimManagerAvailable)
    if isLandClaimManagerAvailable == true then
      self.isLandClaimManagerAvailable = isLandClaimManagerAvailable
      if self.isVisible then
        self:UpdateLandClaimData()
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.Filter.Map.FactionInfluence", function(self, isInfluenceFilterVisible)
    self.isInfluenceFilterVisible = isInfluenceFilterVisible
    self:UpdateFactionInfluenceVisibility()
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Progression.Level", self.UpdateDifficultyColor)
  DynamicBus.Map.Connect(self.entityId, self)
  self.logSettings = {"Map"}
  UiFaderBus.Event.SetFadeValue(self.Properties.TerritoryOutlineImage, self.outlineOpacity)
end
function TerritoryOverlay:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function TerritoryOverlay:UpdateDarkness()
  if self.lastDarknessThreshold ~= self.territoryDarknessThreshold then
    self.lastDarknessThreshold = self.territoryDarknessThreshold
    if self.territoryDarknessThreshold > 0 then
      UiElementBus.Event.SetIsEnabled(self.Properties.DarknessLevelContainer, true)
      local darknessIconPath = "lyshineui/images/icons/misc/icon_darknessLevel" .. self.territoryDarknessThreshold .. ".png"
      UiImageBus.Event.SetSpritePathname(self.Properties.DarknessLevelIcon, darknessIconPath)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.DarknessLevelContainer, false)
    end
  end
end
function TerritoryOverlay:UpdateTerritoryInfo()
  if self.enableTerritoryMechanics then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryName, self.territoryName, eUiTextSet_SetLocalized)
    local textSize = UiTextBus.Event.GetTextSize(self.Properties.TerritoryName).x
    local paddingX = 100
    local textWidth = textSize + paddingX
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.TerritoryNameBackground, textWidth)
    self:UpdateDarkness()
    if self.isClaimed then
      UiTextBus.Event.SetTextWithFlags(self.Properties.CompanyName, self.ownerGuildName, eUiTextSet_SetAsIs)
      self.TerritoryCrest:SetIcon(self.ownerGuildCrest)
      self.TerritoryCrest:SetBackgroundVisibility(true)
    else
      self.isInfluenceEnabled = false
      self:UpdateFactionInfluenceVisibility()
      self.TerritoryCrest:SetForeground("lyshineui/images/map/icon/icon_map_territory.dds", self.UIStyle.COLOR_WHITE)
      self.TerritoryCrest:SetBackgroundVisibility(false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.CompanyName, self.isClaimed)
    local territoryNameIsValid = self.territoryName ~= nil and self.territoryName ~= ""
    UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryNameBackground, territoryNameIsValid)
    UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryName, territoryNameIsValid)
  end
  self:UpdateTerritoryInfoVisibility()
end
function TerritoryOverlay:SetTerritoryInfo(territoryLayer, territoryInfo, zoomLevel)
  self.territoryLayer = territoryLayer
  self.territoryInfo = territoryInfo
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, territoryInfo.anchors)
  UiTransformBus.Event.SetLocalPosition(self.entityId, Vector2(0, 0))
  self:UpdateOverlayVisibility()
  self:SetZoomLevel(zoomLevel, true)
  local territoryDefinition = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryInfo.id)
  self.recommendedLevelLow = territoryDefinition.recommendedLevel
  self.recommendedLevelHigh = territoryDefinition.maximumLevel
  local difficultyString
  if self.recommendedLevelLow >= self.maxDisplayLevel then
    difficultyString = tostring(self.recommendedLevelLow) .. "+"
  elseif self.recommendedLevelHigh > self.maxDisplayLevel then
    difficultyString = GetLocalizedReplacementText("@ui_number_range", {
      lowNumber = self.recommendedLevelLow,
      highNumber = tostring(self.maxDisplayLevel) .. "+"
    })
  else
    difficultyString = GetLocalizedReplacementText("@ui_number_range", {
      lowNumber = self.recommendedLevelLow,
      highNumber = self.recommendedLevelHigh
    })
  end
  UiTextBus.Event.SetText(self.Properties.DifficultyText, difficultyString)
  self:UpdateDifficultyColor()
end
function TerritoryOverlay:UpdateDifficultyColor()
  local textColor = DifficultyColors:GetColorRange(self.recommendedLevelLow, self.recommendedLevelHigh, true)
  UiTextBus.Event.SetColor(self.Properties.DifficultyText, textColor)
end
function TerritoryOverlay:OnTerritoryInfoHover(entityId, actionName)
  if self.enableTerritoryMechanics then
    self.ScriptedEntityTweener:Play(self.Properties.TerritoryName, 0.05, {
      textColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.TerritoryOutlineImage, 0.05, {
      opacity = 1,
      imgColor = self.highlightColor,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.TerritoryIconContainer, 0.05, {
      scaleX = 1.1,
      scaleY = 1.1,
      ease = "QuadOut"
    })
    if not self.isClaimed then
      self.TerritoryCrest:SetForeground("lyshineui/images/map/icon/icon_map_territory_selected.dds", self.UIStyle.COLOR_WHITE)
    end
    self.isHovering = true
    self.audioHelper:PlaySound(self.audioHelper.MapIconOnHover)
  end
end
function TerritoryOverlay:UpdateOverlayVisibility()
  local isVisible = false
  if self.territoryInfo then
    isVisible = self.territoryInfo.isInBounds
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
end
function TerritoryOverlay:OnTerritoryInfoUnhover(entityId, actionName)
  if self.enableTerritoryMechanics then
    self.ScriptedEntityTweener:Play(self.Properties.TerritoryName, 0.05, {
      textColor = self.UIStyle.COLOR_TAN_LIGHT
    })
    self.ScriptedEntityTweener:Play(self.Properties.TerritoryOutlineImage, 0.05, {
      opacity = self.outlineOpacity,
      imgColor = self.territoryColor,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.TerritoryIconContainer, 0.05, {
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    self.isHovering = false
    if not self.isClaimed then
      self.TerritoryCrest:SetForeground("lyshineui/images/map/icon/icon_map_territory.dds", self.UIStyle.COLOR_WHITE)
    end
  end
end
function TerritoryOverlay:UpdateTerritoryInfoVisibility()
  local previousInfoEnabled = self.infoEnabled
  local previousTextEnabled = self.textEnabled
  self.infoEnabled = self.enableTerritoryMechanics and self.zoomLevel > self.ZOOM_MIN
  self.textEnabled = self.enableTerritoryMechanics and self.zoomLevel < self.ZOOM_MAX
  local needsReposition = false
  if previousTextEnabled ~= self.textEnabled then
    UiElementBus.Event.SetIsEnabled(self.Properties.TextContainer, self.textEnabled)
    needsReposition = true
  end
  if previousInfoEnabled ~= self.infoEnabled then
    if self.infoEnabled then
      UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryInfo, true)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryInfo, self.infoEnabled)
    needsReposition = true
  end
  if needsReposition then
    self:UpdateInfoPositions()
  end
end
function TerritoryOverlay:SetIsVisible(isVisible)
  self.isVisible = isVisible
  if isVisible and self.pendingColor then
    self:ChangeColor(self.pendingColor)
  end
  if self.isVisible then
    UiImageBus.Event.SetSpritePathname(self.Properties.TerritoryOverlayImage, self.currentFilename)
    UiImageBus.Event.SetSpritePathname(self.Properties.TerritoryOutlineImage, self.currentOutlineFilename)
    if self.isLandClaimManagerAvailable then
      self:UpdateLandClaimData()
    end
    if not self.landClaimHandler then
      self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.settlementKey)
    end
  else
    UiImageBus.Event.UnloadTexture(self.Properties.TerritoryOverlayImage)
    UiImageBus.Event.UnloadTexture(self.Properties.TerritoryOutlineImage)
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
      self.landClaimHandler = nil
    end
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
end
function TerritoryOverlay:UpdateLandClaimData()
  self.territoryDarknessThreshold = LandClaimRequestBus.Broadcast.GetTerritoryDarknessThreshold(self.settlementKey)
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.settlementKey)
  self:OnClaimOwnerChanged(self.settlementKey, ownerData)
  self:UpdateDarkness()
  self:UpdateFactionInfluence()
  self:UpdateInfoPositions()
end
function TerritoryOverlay:UpdateInfoPositions()
  local currentHeight = 0
  if UiElementBus.Event.IsEnabled(self.Properties.TextContainer) then
    if UiElementBus.Event.IsEnabled(self.Properties.TerritoryName) then
      currentHeight = currentHeight + self.territoryNameHeight
    end
    if UiElementBus.Event.IsEnabled(self.Properties.DifficultyContainer) then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.DifficultyContainer, currentHeight)
      currentHeight = currentHeight + self.difficultyHeight
    end
    if UiElementBus.Event.IsEnabled(self.Properties.CompanyName) then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.CompanyNameContainer, currentHeight)
      local companyNameHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.CompanyName)
      currentHeight = currentHeight + companyNameHeight
    end
    if UiElementBus.Event.IsEnabled(self.Properties.DarknessLevelContainer) then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.DarknessLevelContainer, currentHeight)
      currentHeight = currentHeight + self.darknessLevelHeight
    end
  end
  if self.isInfluenceEnabled then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.InfluenceWarWidget, currentHeight + self.textContainerPosition)
  end
end
function TerritoryOverlay:SetSettlementKey(settlementKey, initialOwnerData, animate, territoryName)
  local guildIdValid = self.ownerGuildId and self.ownerGuildId:IsValid()
  if self.settlementKey == settlementKey and guildIdValid then
    return
  end
  if self.landClaimHandler then
    self:BusDisconnect(self.landClaimHandler)
    self.landClaimHandler = nil
  end
  self.settlementKey = settlementKey
  self.ownerGuildId = initialOwnerData.guildId
  self.ownerGuildName = initialOwnerData.guildName
  self.ownerGuildCrest = initialOwnerData.guildCrestData
  self.guildFaction = initialOwnerData.faction
  self.territoryName = territoryName
  self.territoryDarknessThreshold = LandClaimRequestBus.Broadcast.GetTerritoryDarknessThreshold(settlementKey)
  self.isClaimed = initialOwnerData.guildId and initialOwnerData.guildId:IsValid()
  self:SetZoomLevel(self.zoomLevel, true)
  if self.isVisible and not self.landClaimHandler then
    self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.settlementKey)
  end
  if self.enableTerritoryMechanics then
    self:UpdateTerritoryInfo()
  end
  if animate then
    if not self.isClaimed then
      self:ChangeColor(self.UIStyle.COLOR_TERRITORY_UNCLAIMED)
    else
      self:OnClaimOwnerChanged(self.settlementKey, initialOwnerData)
    end
  else
    self:OnTerritoryOwnershipChange()
  end
end
function TerritoryOverlay:UpdateTerritoryColor(guildFaction)
  local newColor = self.UIStyle.COLOR_TERRITORY_UNCLAIMED
  if guildFaction then
    local factionData = factionCommon.factionInfoTable[guildFaction]
    if factionData then
      newColor = factionData.crestBgColorDark
    end
  end
  self.highlightColor = MixColors(newColor, self.UIStyle.COLOR_WHITE, 0.2)
  self:ChangeColor(newColor)
end
function TerritoryOverlay:OnClaimOwnerChanged(claimKey, newOwnerData)
  if claimKey ~= self.settlementKey then
    return
  end
  self.ownerGuildId = newOwnerData.guildId
  self.ownerGuildCrest = newOwnerData.guildCrestData
  self.ownerGuildName = newOwnerData.guildName
  self.guildFaction = newOwnerData.faction
  self:OnTerritoryOwnershipChange()
end
function TerritoryOverlay:OnTerritoryFactionInfluenceChanged(claimKey, influenceData)
  if claimKey ~= self.settlementKey then
    return
  end
  if self.isVisible then
    self:UpdateFactionInfluence()
  end
end
function TerritoryOverlay:OnTerritoryDarknessThresholdChanged(claimKey, darknessThreshold)
  if claimKey ~= self.settlementKey then
    return
  end
  self.territoryDarknessThreshold = darknessThreshold
  self:UpdateDarkness()
  self:UpdateInfoPositions()
end
function TerritoryOverlay:UpdateFactionInfluenceVisibility()
  if self.isInfluenceFilterVisible and self.isInfluenceEnabled then
    self.InfluenceWarWidget:SetIsEnabled(true)
  else
    self.InfluenceWarWidget:SetIsEnabled(false)
  end
end
function TerritoryOverlay:UpdateFactionInfluence()
  if self.guildFaction and self.guildFaction ~= eFactionType_None then
    local influenceData = LandClaimRequestBus.Broadcast.GetTerritoryFactionInfluencePercentages(self.settlementKey)
    local conflictFaction = -1
    for i = 1, #influenceData do
      if 100 <= influenceData[i] then
        conflictFaction = i
      end
    end
    local validWarDetails
    if self.settlementKey and self.settlementKey ~= 0 then
      local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.settlementKey)
      if warDetails and warDetails:IsValid() and warDetails:IsWarActive() then
        validWarDetails = warDetails
      end
    end
    local showConflict = conflictFaction ~= -1 or validWarDetails ~= nil
    UiElementBus.Event.SetIsEnabled(self.Properties.ConflictBg, showConflict)
    if not showConflict then
      self.InfluenceWarWidget:SetInfluenceWarData(self.territoryName, self.guildFaction, self.ownerGuildCrest, influenceData)
    elseif validWarDetails then
      UiImageBus.Event.SetColor(self.Properties.ConflictBg, self.UIStyle.COLOR_RED_DARK)
      local warPhase = validWarDetails:GetWarPhase()
      local isConflict = warPhase == eWarPhase_Conquest
      local isResolution = warPhase == eWarPhase_Resolution
      if not validWarDetails:IsInvasion() then
        if isConflict or isResolution then
          UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_ongoingwar", eUiTextSet_SetLocalized)
        else
          UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_upcomingwar", eUiTextSet_SetLocalized)
        end
      elseif isConflict or isResolution then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_ongoinginvasion", eUiTextSet_SetLocalized)
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_upcominginvasion", eUiTextSet_SetLocalized)
      end
    else
      local factionData = factionCommon.factionInfoTable[conflictFaction]
      UiImageBus.Event.SetColor(self.Properties.ConflictBg, factionData.crestBgColor)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_in_conflict", eUiTextSet_SetLocalized)
    end
    self.isInfluenceEnabled = true
    self:UpdateFactionInfluenceVisibility()
  end
end
function TerritoryOverlay:OnTerritoryOwnershipChange()
  local guildIdValid = self.ownerGuildId and self.ownerGuildId:IsValid()
  self.isClaimed = guildIdValid
  self:UpdateTerritoryInfo()
  if guildIdValid then
    self:UpdateTerritoryColor(self.guildFaction)
    local factionData = factionCommon.factionInfoTable[self.guildFaction]
    if factionData then
      self:UpdateFactionInfluence()
    end
  else
    self:UpdateTerritoryColor(eFactionType_None)
  end
end
function TerritoryOverlay:SetZoomLevel(zoomLevel, forceUpdate)
  if not forceUpdate and zoomLevel == self.zoomLevel then
    return
  end
  self.zoomLevel = zoomLevel
  local filename = ""
  local outlinename = ""
  local assetName = ""
  local worldPos = {
    x = math.floor(self.territoryInfo.center.x),
    y = math.floor(self.territoryInfo.center.y)
  }
  local folderPath = self.DEFAULT_IMAGE_PATH
  local outlinePath = self.OUTLINE_IMAGE_PATH
  for contentLevel = zoomLevel, 1, -1 do
    assetname = string.format("@assets@/lyshineui/images/map/%s/TerritoryOverlay_%d_%d.dds", folderPath, self.territoryInfo.id, contentLevel)
    if LyShineScriptBindRequestBus.Broadcast.IsFileExists(assetname) then
      filename = string.format("lyshineui/images/map/%s/TerritoryOverlay_%d_%d.dds", folderPath, self.territoryInfo.id, contentLevel)
      outlinename = string.format("lyshineui/images/map/%s/TerritoryOverlay_%d_%d.dds", outlinePath, self.territoryInfo.id, contentLevel)
      break
    end
    if zoomLevel == 1 then
      Debug.Log("ERROR: TerritoryOverlay: Could not find " .. assetname)
    end
  end
  if not self.territoryInfo or filename == "" then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    return
  end
  if self.currentFilename ~= filename then
    self.currentFilename = filename
    self.currentOutlineFilename = outlinename
    if self.isVisible then
      UiImageBus.Event.SetSpritePathname(self.Properties.TerritoryOverlayImage, self.currentFilename)
      UiImageBus.Event.SetSpritePathname(self.Properties.TerritoryOutlineImage, self.currentOutlineFilename)
    end
  end
  self:UpdateTerritoryInfoVisibility()
  local zoomMPP = self.territoryLayer.MagicMap.levelMPP[zoomLevel]
  local osWidth = self.territoryInfo.width / zoomMPP
  local osHeight = self.territoryInfo.height / zoomMPP
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, osWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, osHeight)
  scale = Math.Clamp(self.ZOOM_MIN / zoomMPP, 0.75, 1)
  UiTransformBus.Event.SetScale(self.Properties.TerritoryInfo, Vector2(scale, scale))
  local zeroOpacityZoomLevel = 3
  local overlayOpacity = math.max(0, (zoomLevel - zeroOpacityZoomLevel) / (self.ZOOM_MAX - zeroOpacityZoomLevel))
  UiFaderBus.Event.SetFadeValue(self.Properties.TerritoryOverlayImage, overlayOpacity)
  self.outlineOpacity = Lerp(0.25, 0.5, (zoomLevel - 1) / (self.ZOOM_MAX - 1))
  if self.isHovering then
    UiFaderBus.Event.SetFadeValue(self.Properties.TerritoryOutlineImage, 1)
  else
    UiFaderBus.Event.SetFadeValue(self.Properties.TerritoryOutlineImage, self.outlineOpacity)
  end
end
function TerritoryOverlay:ChangeColor(newColor)
  if self.inTransition then
    return
  end
  if newColor == self.territoryColor then
    return
  end
  if not self.isVisible then
    self.pendingColor = newColor
    return
  end
  self.pendingColor = nil
  local oldColor = self.territoryColor
  self.inTransition = true
  self.ScriptedEntityTweener:StartAnimation({
    id = self.Properties.TerritoryOverlayImage,
    duration = 0.25,
    scaleX = 1.25,
    scaleY = 1.25,
    onComplete = function()
      self.ScriptedEntityTweener:StartAnimation({
        id = self.Properties.TerritoryOverlayImage,
        duration = 0.1,
        imgColor = newColor,
        onComplete = function()
          self.ScriptedEntityTweener:StartAnimation({
            id = self.Properties.TerritoryOverlayImage,
            duration = 0.1,
            imgColor = oldColor,
            onComplete = function()
              self.ScriptedEntityTweener:StartAnimation({
                id = self.Properties.TerritoryOverlayImage,
                duration = 0.25,
                imgColor = newColor,
                scaleX = 1,
                scaleY = 1,
                onComplete = function()
                  self.territoryColor = newColor
                  self.inTransition = false
                end
              })
            end
          })
        end
      })
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.TerritoryOutlineImage, 0.05, {
    opacity = self.outlineOpacity,
    imgColor = newColor,
    ease = "QuadOut"
  })
end
return TerritoryOverlay
