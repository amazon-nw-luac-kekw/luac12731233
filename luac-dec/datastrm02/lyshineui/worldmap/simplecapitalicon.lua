BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local SimpleCapitalIcon = {
  Properties = {
    IconContainer = {
      default = EntityId()
    },
    IconImage = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    FactionGuildIconContainer = {
      default = EntityId()
    },
    GuildCrestContainer = {
      default = EntityId()
    },
    GuildCrestBackground = {
      default = EntityId()
    },
    GuildCrestForeground = {
      default = EntityId()
    },
    FactionIconContainer = {
      default = EntityId()
    },
    FactionIconBackground = {
      default = EntityId()
    },
    FactionIconForeground = {
      default = EntityId()
    },
    ControlPointContainer = {
      default = EntityId()
    },
    ContestedIcon = {
      default = EntityId()
    },
    ZoomedContestedIcon = {
      default = EntityId()
    },
    ControlPointFactionIconContainer = {
      default = EntityId()
    },
    ControlPointFactionIconBackground = {
      default = EntityId()
    },
    ControlPointFactionIconForeground = {
      default = EntityId()
    },
    ControlPointLockIcon = {
      default = EntityId()
    },
    ZoomedOutFactionContainer = {
      default = EntityId()
    },
    ZoomedOutFactionIconContainer = {
      default = EntityId()
    },
    ZoomedOutFactionIconBackground = {
      default = EntityId()
    },
    ZoomedOutFactionIconForeground = {
      default = EntityId()
    },
    ZoomedOutLockIcon = {
      default = EntityId()
    },
    ZoomedOutControlPointContainer = {
      default = EntityId()
    },
    CapitalIcon = {
      default = EntityId()
    },
    InnIcon = {
      default = EntityId()
    },
    HouseIcon = {
      default = EntityId()
    },
    ObjectivesIcon = {
      default = EntityId()
    },
    CompletableObjectivesIcon = {
      default = EntityId()
    },
    EncounterContainer = {
      default = EntityId()
    },
    EncounterZoomContainer = {
      default = EntityId()
    }
  },
  CAPITAL_TYPE_TOWNSHIP = "township",
  CAPITAL_TYPE_FORTRESS = "fortress",
  CAPITAL_TYPE_OUTPOST = "outpost",
  ZOOM_BARRIER = 3.5,
  ZOOM_ENCOUNTER = 3.5,
  currentZoom = 2,
  numAvailableQuests = 0,
  capitalIconPath = "",
  capitalIconSelectedPath = "",
  houseIconPath = "lyshineui/images/map/icon/icon_map_house.dds",
  disabledHouseIconPath = "lyshineui/images/map/icon/icon_map_house_disabled.dds",
  houseIconButtonPath = "lyshineui/images/map/icon/icon_house_button.dds",
  disabledHouseIconButtonPath = "lyshineui/images/map/icon/icon_house_inactive_button.dds",
  houseIconPathFlyout = "lyshineui/images/icons/misc/icon_house.dds",
  warningIconPath = "lyshineui/images/icons/misc/icon_exclamation_white.dds",
  activeInnIconButtonPath = "lyshineui/images/map/icon/icon_inn_button.dds",
  inactiveInnIconButtonPath = "lyshineui/images/map/icon/icon_inn_inactive_button.dds",
  houseIconButtonFlyoutContext = "houseIconButton",
  hourglassIcon = "lyshineui/images/icons/misc/icon_hourglass.dds",
  leftMouseIcon = "lyshineui/images/icons/misc/Icon_LeftMouseButton_square.dds",
  storageIcon = "lyshineui/images/map/icon/icon_storage.dds",
  viewTaxIcon = "lyshineui/images/map/icon/icon_viewTax.dds",
  viewWarIcon = "lyshineui/images/map/icon/icon_viewWar.dds",
  completableObjectivesIconPath = "lyshineui/images/icons/objectives/icon_questReadyForTurnIn.dds",
  completableObjectivesPinnedIconPath = "lyshineui/images/icons/objectives/icon_questReadyForTurnIn_pinned.dds"
}
BaseElement:CreateNewElement(SimpleCapitalIcon)
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local fastTravelCommon = RequireScript("LyShineUI._Common.FastTravelCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local objectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
local TooltipCommon = RequireScript("LyShineUI._Common.TooltipCommon")
function SimpleCapitalIcon:OnInit()
  BaseElement.OnInit(self)
  self.iconTypes = mapTypes.iconTypes
  self.sourceTypes = mapTypes.sourceTypes
  self.panelTypes = mapTypes.panelTypes
  self.houses = {}
  self.fastTravelPopupId = "fast_travel_popup_id"
  self.fastTravelErrorToText = fastTravelCommon.fastTravelErrorToText
  UiElementBus.Event.SetIsEnabled(self.Properties.ObjectivesIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompletableObjectivesIcon, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.SocialEntityId", function(self, socialEntityId)
    if not socialEntityId then
      return
    end
    if self.socialNotificationsHandler then
      self:BusDisconnect(self.socialNotificationsHandler)
    end
    self.socialNotificationsHandler = self:BusConnect(SocialNotificationsBus, socialEntityId)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    if rootPlayerId then
      self.rootPlayerId = rootPlayerId
    end
  end)
  if not self.canvasNotificationBus then
    self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    self.canvasNotificationBus = self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  end
  UiInteractableBus.Event.SetHoverEnterEventHandlingScale(self.Properties.CapitalIcon, Vector2(0.8, 0.8))
end
function SimpleCapitalIcon:OnHoverStart(entityId)
  self.ScriptedEntityTweener:Play(entityId, 0.05, {
    scaleX = 1.2,
    scaleY = 1.2,
    ease = "QuadOut"
  })
  if entityId == self.Properties.CapitalIcon then
    UiImageBus.Event.SetSpritePathname(self.Properties.CapitalIcon, self.capitalIconSelectedPath)
    if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP then
      self.audioHelper:PlaySound(self.audioHelper.MapIconOnHoverSettlement)
    elseif self.capitalType == self.CAPITAL_TYPE_FORTRESS then
      self.audioHelper:PlaySound(self.audioHelper.MapIconOnHoverFort)
    else
      self.audioHelper:PlaySound(self.audioHelper.MapIconOnHoverTerritory)
    end
    self.audioHelper:PlaySound(self.audioHelper.MapIconOnHoverSettlement)
  end
  hoverIntentDetector:OnHoverDetected(self, function()
    self:OpenFlyout(entityId)
  end)
end
function SimpleCapitalIcon:OnHoverEnd(entityId)
  self.ScriptedEntityTweener:Play(entityId, 0.05, {scaleX = 1, scaleY = 1})
  if entityId == self.Properties.CapitalIcon then
    UiImageBus.Event.SetSpritePathname(self.Properties.CapitalIcon, self.capitalIconPath)
  end
  hoverIntentDetector:StopHoverDetected(self)
end
function SimpleCapitalIcon:OnClickViewInfoPanel()
  if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP then
    DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Town, self.territoryId, self.actorId)
  elseif self.capitalType == self.CAPITAL_TYPE_FORTRESS then
    DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Fortress, self.territoryId, self.actorId, self.name)
  elseif self.capitalType == self.CAPITAL_TYPE_OUTPOST then
    DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Storage, self.actorId, self.name)
  end
end
function SimpleCapitalIcon:OnClickViewPersonalStorage()
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Storage, self.actorId, self.name)
end
function SimpleCapitalIcon:OnRightClick()
  local worldPosition = DynamicBus.MagicMap.Broadcast.GetCursorWorldPosition()
  if worldPosition then
    WaypointsRequestBus.Broadcast.RequestSetWaypoint(worldPosition)
  end
end
function SimpleCapitalIcon:SetData(iconData)
  self.territoryId = iconData.territoryId
  self.name = iconData.name
  self.sourceType = iconData.sourceType
  self.actorId = iconData.actorId
  self.worldPosition = iconData.worldPosition
  self.worldPositionVec3 = Vector3(self.worldPosition.x, self.worldPosition.y, 0)
  if self.capitalType == self.CAPITAL_TYPE_OUTPOST then
    self.capitalTerritoryId = MapComponentBus.Broadcast.GetContainingTerritory(self.worldPositionVec3)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.HouseIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.InnIcon, false)
  if iconData.iconType == self.iconTypes.Settlement then
    self.capitalType = self.CAPITAL_TYPE_TOWNSHIP
    self.capitalIconPath = "lyshineui/images/map/icon/icon_capital.dds"
    self.capitalIconSelectedPath = "lyshineui/images/map/icon/icon_capital_selected.dds"
    self.largeIconPath = "lyShineui/images/map/icon/township.dds"
    if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
      if self.landClaimHandler then
        self:BusDisconnect(self.landClaimHandler)
      end
      self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.territoryId)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isAvailable)
        if isAvailable == true then
          local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.territoryId)
          self:UpdateOwnership(ownerData)
          self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable")
        end
      end)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestContainer, false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointFactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointLockIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutLockIcon, false)
  elseif iconData.iconType == self.iconTypes.Territory then
    self.capitalType = self.CAPITAL_TYPE_FORTRESS
    self.capitalIconPath = "lyshineui/images/map/icon/icon_map_fort.dds"
    self.capitalIconSelectedPath = "lyshineui/images/map/icon/icon_map_fort_selected.dds"
    self.largeIconPath = "lyShineui/images/map/icon/fortress.dds"
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
    end
    self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.territoryId)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isAvailable)
      if isAvailable == true then
        if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
          local factionOwner = LandClaimRequestBus.Broadcast.GetFactionControlOwner(self.territoryId)
          local captureStatus = LandClaimRequestBus.Broadcast.GetFactionControlCaptureStatus(self.territoryId)
          self.isContested = captureStatus == eFactionControlCaptureStatus_Contested
          self:UpdateFactionOwnership(factionOwner, captureStatus)
        else
          local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.territoryId)
          self:UpdateOwnership(ownerData)
        end
        self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable")
      end
    end)
    UiElementBus.Event.SetIsEnabled(self.Properties.HouseIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.InnIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointLockIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutLockIcon, false)
  elseif iconData.iconType == self.iconTypes.Outpost then
    self.capitalType = self.CAPITAL_TYPE_OUTPOST
    self.capitalIconPath = "lyshineui/images/map/icon/icon_outpost_button.dds"
    self.capitalIconSelectedPath = "lyshineui/images/map/icon/icon_outpost_button_selected.dds"
    self.largeIconPath = "lyShineui/images/map/icon/outpost.dds"
    UiElementBus.Event.SetIsEnabled(self.Properties.HouseIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.InnIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointFactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointLockIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutLockIcon, false)
  end
  local capitalTypeLoc = "@ui_" .. self.capitalType
  UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, capitalTypeLoc, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.CapitalIcon, self.capitalIconPath)
  UiImageBus.Event.SetSpritePathname(self.Properties.IconImage, self.largeIconPath)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.ZoomLevelMPP." .. iconData.sourceType, self.OnZoomLevelChanged)
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, iconData.anchors)
end
function SimpleCapitalIcon:OnZoomLevelChanged(zoomLevel)
  if not zoomLevel or zoomLevel == self.currentZoom then
    return
  end
  self.currentZoom = zoomLevel
  if self.currentZoom > self.ZOOM_BARRIER then
    UiElementBus.Event.SetIsEnabled(self.Properties.IconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionGuildIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TitleText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionContainer, true)
    if self.currentZoom > 15 then
      self.scale = 0.5
    elseif self.currentZoom > 7 then
      self.scale = 0.7
    else
      self.scale = 1
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.IconContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionGuildIconContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TitleText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionContainer, false)
    self.scale = Math.Clamp(2 / self.currentZoom, 0.3, 1.5)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, false)
    self:UpdateContestIconZoom()
  end
  if self.currentZoom > self.ZOOM_ENCOUNTER then
    UiElementBus.Event.SetIsEnabled(self.Properties.EncounterZoomContainer, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.EncounterZoomContainer, true)
  end
  UiTransformBus.Event.SetScale(self.entityId, Vector2(self.scale, self.scale))
end
function SimpleCapitalIcon:OnClaimOwnerChanged(claimKey, newOwnerData)
  if claimKey ~= self.territoryId then
    return
  end
  self:UpdateOwnership(newOwnerData)
end
function SimpleCapitalIcon:OnLocalWarsChanged()
  if not self.territoryId then
    return
  end
  local destinationIcon = self.CAPITAL_TYPE_FORTRESS
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    destinationIcon = self.CAPITAL_TYPE_TOWNSHIP
  end
  if self.sourceType == self.sourceTypes.Map and self.capitalType == destinationIcon then
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.territoryId)
    self.EncounterContainer:SetEncounterData(self.territoryId, ownerData)
  end
end
function SimpleCapitalIcon:UpdateOwnership(ownerData)
  local guildIdValid = ownerData and ownerData.guildId and ownerData.guildId:IsValid()
  local factionControlEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled")
  if guildIdValid then
    local isSettlement = self.capitalType == self.CAPITAL_TYPE_TOWNSHIP
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestContainer, isSettlement)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, not isSettlement)
    local backgroundImage = GetSmallImagePath(ownerData.guildCrestData.backgroundImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCrestBackground, backgroundImage)
    UiImageBus.Event.SetColor(self.Properties.GuildCrestBackground, ownerData.guildCrestData.backgroundColor)
    local foregroundImage = GetSmallImagePath(ownerData.guildCrestData.foregroundImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCrestForeground, foregroundImage)
    UiImageBus.Event.SetColor(self.Properties.GuildCrestForeground, ownerData.guildCrestData.foregroundColor)
    if not isSettlement then
      self:UpdateFaction(ownerData.faction)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointFactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointLockIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutLockIcon, false)
  end
  local destinationIcon = self.CAPITAL_TYPE_FORTRESS
  if factionControlEnabled then
    destinationIcon = self.CAPITAL_TYPE_TOWNSHIP
  end
  if self.sourceType == self.sourceTypes.Map and self.capitalType == destinationIcon then
    self.EncounterContainer:SetEncounterData(self.territoryId, ownerData)
  end
end
function SimpleCapitalIcon:UpdateFactionOwnership(faction, status)
  if faction ~= eFactionType_None then
    if self.capitalType == self.CAPITAL_TYPE_FORTRESS then
      UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestContainer, false)
    end
    self:UpdateFaction(faction)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointFactionIconContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointLockIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutLockIcon, false)
  end
end
function SimpleCapitalIcon:UpdateFaction(faction)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionIconContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointFactionIconContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointLockIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutLockIcon, false)
  if faction == eFactionType_None then
    return
  end
  local factionData = FactionCommon.factionInfoTable[faction]
  if factionData then
    if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
      UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointFactionIconContainer, self.capitalType == self.CAPITAL_TYPE_FORTRESS)
      UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionIconContainer, self.capitalType == self.CAPITAL_TYPE_FORTRESS)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconContainer, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutFactionIconContainer, true)
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.FactionIconBackground, factionData.crestFgSmallOutline)
    UiImageBus.Event.SetColor(self.Properties.FactionIconBackground, self.UIStyle.COLOR_BLACK)
    UiImageBus.Event.SetSpritePathname(self.Properties.ZoomedOutFactionIconBackground, factionData.crestFgSmallOutline)
    UiImageBus.Event.SetColor(self.Properties.ZoomedOutFactionIconBackground, self.UIStyle.COLOR_BLACK)
    UiImageBus.Event.SetSpritePathname(self.Properties.ControlPointFactionIconBackground, factionData.crestFgSmallOutline)
    UiImageBus.Event.SetColor(self.Properties.ControlPointFactionIconBackground, self.UIStyle.COLOR_BLACK)
    UiImageBus.Event.SetSpritePathname(self.Properties.FactionIconForeground, factionData.crestFgSmall)
    UiImageBus.Event.SetColor(self.Properties.FactionIconForeground, factionData.crestBgColor)
    UiImageBus.Event.SetSpritePathname(self.Properties.ZoomedOutFactionIconForeground, factionData.crestFgSmall)
    UiImageBus.Event.SetColor(self.Properties.ZoomedOutFactionIconForeground, factionData.crestBgColor)
    UiImageBus.Event.SetSpritePathname(self.Properties.ControlPointFactionIconForeground, factionData.crestFgSmall)
    UiImageBus.Event.SetColor(self.Properties.ControlPointFactionIconForeground, factionData.crestBgColor)
  end
end
function SimpleCapitalIcon:UpdateInns()
  self.innAtThisSettlementIsActive = PlayerHousingClientRequestBus.Broadcast.HasFastTravelPointInTerritory(self.territoryId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.InnIcon, self.innAtThisSettlementIsActive)
  local hasHouse = #self.houses > 0
  UiTransformBus.Event.SetLocalPosition(self.Properties.InnIcon, Vector2(24, hasHouse and 13 or -13))
end
function SimpleCapitalIcon:UpdateObjectives()
  local objectiveTerritory = self.territoryId
  if self.capitalType == self.CAPITAL_TYPE_OUTPOST then
    objectiveTerritory = self.capitalTerritoryId or MapComponentBus.Broadcast.GetContainingTerritory(self.worldPositionVec3)
    self.capitalTerritoryId = objectiveTerritory
  end
  local availableQuests = objectivesDataHandler:GetAvailableObjectivesByTerritoryId(objectiveTerritory, true)
  self.numAvailableQuests = 0
  local posVec2 = Vector2(0, 0)
  for i = 1, #availableQuests do
    local questData = availableQuests[i]
    posVec2.x = questData.worldPosition.x
    posVec2.y = questData.worldPosition.y
    if posVec2:GetDistanceSq(self.worldPosition) < objectivesDataHandler.settlementBoundsToleranceSq then
      self.numAvailableQuests = self.numAvailableQuests + 1
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ObjectivesIcon, self.numAvailableQuests > 0)
  local numCompletableObjectives, usePinned = objectivesDataHandler:GetCompletableObjectivesNearPositionCount(self.worldPosition)
  self.completableObjectives = numCompletableObjectives
  UiElementBus.Event.SetIsEnabled(self.Properties.CompletableObjectivesIcon, 0 < self.completableObjectives)
  if usePinned then
    UiImageBus.Event.SetSpritePathname(self.Properties.CompletableObjectivesIcon, self.completableObjectivesPinnedIconPath)
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.CompletableObjectivesIcon, self.completableObjectivesIconPath)
  end
  if self.numAvailableQuests > 0 and 0 < self.completableObjectives then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ObjectivesIcon, -10)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.CompletableObjectivesIcon, 10)
    self.ScriptedEntityTweener:Set(self.Properties.ObjectivesIcon, {scaleX = 0.8, scaleY = 0.8})
    self.ScriptedEntityTweener:Set(self.Properties.CompletableObjectivesIcon, {scaleX = 0.8, scaleY = 0.8})
  else
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ObjectivesIcon, 0)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.CompletableObjectivesIcon, 0)
    self.ScriptedEntityTweener:Set(self.Properties.ObjectivesIcon, {scaleX = 1, scaleY = 1})
    self.ScriptedEntityTweener:Set(self.Properties.CompletableObjectivesIcon, {scaleX = 1, scaleY = 1})
  end
end
function SimpleCapitalIcon:UpdateHousing(taxesPaid)
  if taxesPaid == nil then
    ClearTable(self.houses)
    local ownedHouses = PlayerHousingClientRequestBus.Broadcast.GetOwnedHouseData()
    if #ownedHouses == 0 then
      UiElementBus.Event.SetIsEnabled(self.Properties.HouseIcon, false)
      return
    end
    local hasUnpaidTaxes = false
    local plotEntityId
    for i = 1, #ownedHouses do
      local houseData = ownedHouses[i]
      local territoryId = MapComponentBus.Broadcast.GetContainingTerritory(houseData.housingPlotPos)
      if territoryId == self.territoryId then
        plotEntityId = PlayerHousingClientRequestBus.Broadcast.GetPlotEntityIdFromOwnedHouseData(houseData)
        hasUnpaidTaxes = houseData.taxesDue <= timeHelpers:ServerNow()
        table.insert(self.houses, i)
        break
      end
    end
    self.houseIconPath = hasUnpaidTaxes and self.disabledHouseIconPath or "lyshineui/images/map/icon/icon_map_house.dds"
    self.houseIconButtonPath = hasUnpaidTaxes and self.disabledHouseIconButtonPath or "lyshineui/images/map/icon/icon_house_button.dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.HouseIcon, self.houseIconPath)
    UiElementBus.Event.SetIsEnabled(self.Properties.HouseIcon, #self.houses > 0)
    UiTransformBus.Event.SetLocalPosition(self.Properties.HouseIcon, Vector2(24, -13))
    return plotEntityId
  else
    self.houseIconPath = taxesPaid and "lyshineui/images/map/icon/icon_map_house.dds" or self.disabledHouseIconPath
    self.houseIconButtonPath = taxesPaid and "lyshineui/images/map/icon/icon_house_button.dds" or self.disabledHouseIconButtonPath
    UiImageBus.Event.SetSpritePathname(self.Properties.HouseIcon, self.houseIconPath)
  end
end
function SimpleCapitalIcon:OnTaxesPaid()
  self:UpdateHousing(true)
end
function SimpleCapitalIcon:OnTaxesDue()
  self:UpdateHousing(false)
end
function SimpleCapitalIcon:OnObjectivesChanged()
  self:UpdateObjectives()
end
function SimpleCapitalIcon:OnCanvasEnabledChanged(isEnabled)
  local factionControlEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled")
  if isEnabled then
    if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP or self.capitalType == self.CAPITAL_TYPE_OUTPOST then
      if self.capitalType ~= self.CAPITAL_TYPE_OUTPOST then
        if not self.landClaimHandler and self.territoryId then
          self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.territoryId)
        end
        local ownerData
        if self.territoryId then
          ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.territoryId)
        end
        self:UpdateOwnership(ownerData)
        local plotEntityId = self:UpdateHousing()
        if plotEntityId and not self.playerHousingClientNotificationBusHandler then
          self.playerHousingClientNotificationBusHandler = self:BusConnect(PlayerHousingClientNotificationBus, plotEntityId)
        end
      end
      self:UpdateInns()
      self:UpdateObjectives()
      if not self.objectivesComponentBusHandler then
        local objectiveEntityId = self.dataLayer:GetData("Hud.LocalPlayer.HudComponent.ObjectiveEntityId")
        self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, objectiveEntityId)
      end
    end
    if factionControlEnabled and self.capitalType == self.CAPITAL_TYPE_FORTRESS then
      if not self.landClaimHandler and self.territoryId then
        self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.territoryId)
      end
      local factionOwner = LandClaimRequestBus.Broadcast.GetFactionControlOwner(self.territoryId)
      local captureStatus = LandClaimRequestBus.Broadcast.GetFactionControlCaptureStatus(self.territoryId)
      self.isContested = captureStatus == eFactionControlCaptureStatus_Contested
      self:UpdateFactionOwnership(factionOwner, captureStatus)
      local isFcpActive = true
      if factionOwner ~= eFactionType_None then
        isFcpActive = FactionControlLandClaimClientRequestBus.Broadcast.GetFactionControlIsActive(self.territoryId)
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointLockIcon, not isFcpActive)
      UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutLockIcon, not isFcpActive)
      self:UpdateContestIconZoom()
    end
  else
    if self.objectivesComponentBusHandler then
      self:BusDisconnect(self.objectivesComponentBusHandler)
      self.objectivesComponentBusHandler = nil
    end
    if self.flyoutTimingDelay then
      timingUtils:StopDelay(self)
      self.flyoutTimingDelay = nil
    end
    if self.playerHousingClientNotificationBusHandler then
      self:BusDisconnect(self.playerHousingClientNotificationBusHandler)
      self.playerHousingClientNotificationBusHandler = nil
    end
    if factionControlEnabled and self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
      self.landClaimHandler = nil
    end
  end
end
function SimpleCapitalIcon:MakeHomeFlyout(rows, isZoomedIn)
  local numHouses = #self.houses
  if numHouses <= 0 then
    return
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  local myRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  local isAtWar = myRaidId and myRaidId:IsValid()
  local headerText = 1 < numHouses and "@ui_my_houses_map_title" or "@ui_my_house_map_title"
  local isEncumbered = LocalPlayerUIRequestsBus.Broadcast.IsEncumbered()
  local usingAzoth = self.dataLayer:GetDataFromNode("javelin.use-azoth-currency")
  local isInArena = PlayerArenaRequestBus.Event.IsInArena(self.rootPlayerId) or PlayerArenaRequestBus.Event.IsArenaTeleportPending(self.rootPlayerId)
  local fastTravelCost = usingAzoth and 0 or PlayerHousingClientRequestBus.Broadcast.GetFastTravelCost()
  local currencyAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
  local hasEnoughCurrency = fastTravelCost <= currencyAmount
  local vitalsId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.VitalsEntityId")
  local isInDeathsDoor = VitalsComponentRequestBus.Event.IsDeathsDoor(vitalsId)
  local isDead = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.IsDead")
  local bottomPadding = 0
  if isZoomedIn then
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_House,
      text = headerText
    })
    bottomPadding = 28
  end
  local ownedHouseData = PlayerHousingClientRequestBus.Broadcast.GetOwnedHouseData()
  for i = 1, numHouses do
    local areTaxesPaid = false
    local isHubAvailable = true
    local taxesDueTime
    local remainingFastTravelCooldownTime = 0
    local trophyItems = {}
    if self.houses[i] <= #ownedHouseData then
      local thisHouseData = ownedHouseData[self.houses[i]]
      areTaxesPaid = thisHouseData.taxesDue > timeHelpers:ServerNow()
      isHubAvailable = thisHouseData:IsHubAvailable()
      taxesDueTime = thisHouseData.taxesDue
      remainingFastTravelCooldownTime = PlayerHousingClientRequestBus.Broadcast.GetRemainingFastTravelCooldownTimeInSeconds(self.houses[i] - 1)
      trophyItems = thisHouseData.housingBuffItems
    end
    if isZoomedIn then
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Subheader,
        header = areTaxesPaid and "@ui_housing_trophy_buffs" or "@ui_housing_trophy_buffs_disabled"
      })
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_HouseTrophies,
        enabled = areTaxesPaid,
        trophyItems = trophyItems
      })
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Separator,
        paddingTop = 0
      })
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Label,
        text = "@ui_your_house_desc",
        textColor = self.UIStyle.COLOR_TAN,
        bottomPadding = 22
      })
    end
    local houseText = GetLocalizedReplacementText(areTaxesPaid and "@ui_my_house_map_desc" or "@ui_my_house_map_desc_disabled", {
      location = self.name,
      number = tostring(i)
    })
    local canFastTravel = not isAtWar and remainingFastTravelCooldownTime <= 0 and isHubAvailable and not isDead and not isInDeathsDoor and not isEncumbered and hasEnoughCurrency
    local buttonTextTertiary
    if isAtWar then
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Button,
        buttonText = "@ui_recall_to_house",
        buttonTextTertiary = "@ui_cannot_travel_in_war",
        isEnabled = false,
        icon = self.houseIconButtonPath
      })
    elseif not areTaxesPaid then
      if isDead or isInDeathsDoor then
        bottomPadding = 28
      end
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Button,
        buttonText = "@ui_pay_property_tax",
        buttonTextTertiary = "@ui_pay_property_tax_desc",
        isEnabled = true,
        icon = self.houseIconButtonPath,
        bottomPadding = bottomPadding,
        skipLocalization = false,
        callbackTable = self,
        callback = function(self)
          PlayerHousingClientRequestBus.Broadcast.RequestTaxesDue(self.houses[i] - 1)
          DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 5, self, function(self)
            local notificationData = NotificationData()
            notificationData.type = "Minor"
            notificationData.text = "@ui_remote_house_payment_unavailable"
            UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
          end)
          self.dataLayer:RegisterDataCallback(self, "Hud.Housing.OnRequestedTaxes", function(self, taxesDue)
            self.dataLayer:UnregisterObserver(self, "Hud.Housing.OnRequestedTaxes")
            DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
            DynamicBus.HousingManagement.Broadcast.OnRequestPayPropertyTaxPopup(taxesDue, taxesDueTime, self, function(self)
              local playerWallet = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
              if playerWallet < taxesDue then
                local notificationData = NotificationData()
                notificationData.type = "Minor"
                notificationData.text = "@ui_remote_house_payment_need_coin"
                UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
                return
              end
              DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 5, self, function(self)
                local notificationData = NotificationData()
                notificationData.type = "Minor"
                notificationData.text = "@ui_remote_house_payment_unavailable"
                UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
              end)
              PlayerHousingClientRequestBus.Broadcast.RequestPayTaxes(self.houses[i] - 1)
              self.dataLayer:RegisterDataCallback(self, "Hud.Housing.OnPayTaxResponse", function(self, success)
                self.dataLayer:UnregisterObserver(self, "Hud.Housing.OnPayTaxResponse")
                DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
                local taxesDueText = GetLocalizedReplacementText("@ui_coin_icon", {
                  coin = GetLocalizedCurrency(taxesDue)
                })
                if success then
                  LyShineManagerBus.Broadcast.SetState(2702338936)
                  popupWrapper:RequestPopupWithParams({
                    title = "@ui_payment_successful",
                    message = "@ui_property_tax_success_desc",
                    eventId = "RemoteHousingPaySuccess",
                    buttonText = "@ui_close",
                    customData = {
                      {
                        detailType = "TextLabelAndValue",
                        label = "@ui_paid",
                        value = taxesDueText
                      }
                    }
                  })
                end
              end)
            end)
          end)
        end
      })
    elseif 0 < remainingFastTravelCooldownTime then
      if usingAzoth then
        local azothAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount")
        local cooldownResetCost = PlayerHousingClientRequestBus.Broadcast.GetFastTravelCooldownResetCost(self.houses[i] - 1)
        local canAffordResetCooldown = azothAmount >= cooldownResetCost
        local replacementText
        if canAffordResetCooldown then
          replacementText = "@ui_cannot_reset_travel_currency"
        else
          replacementText = "@ui_need_reset_travel_currency"
        end
        buttonTextTertiary = GetLocalizedReplacementText(replacementText, {
          coin = GetFormattedNumber(cooldownResetCost)
        })
        local cooldownTimeWallClock = WallClockTimePoint:Now():AddDuration(Duration.FromSecondsUnrounded(remainingFastTravelCooldownTime))
        table.insert(rows, {
          type = flyoutMenu.ROW_TYPE_Button,
          buttonText = "@ui_recall_to_house",
          buttonTextTertiary = buttonTextTertiary,
          isEnabled = canAffordResetCooldown,
          bottomPadding = bottomPadding,
          timerIcon = self.hourglassIcon,
          timer = timeHelpers:ConvertSecondsToHrsMinSecString(remainingFastTravelCooldownTime),
          refreshTimer = true,
          timeWallClock = cooldownTimeWallClock,
          icon = self.houseIconButtonPath,
          callbackTable = self,
          callback = function(self)
            popupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_fast_travel_reset_popup", "@ui_fast_travel_reset_popup_confirm", self.fastTravelPopupId, self, function(self, result, eventId)
              if result == ePopupResult_Yes then
                PlayerHousingClientRequestBus.Broadcast.RequestResetCooldown(self.houses[i] - 1)
              end
            end)
          end
        })
      end
    elseif isDead or isInDeathsDoor then
      if isZoomedIn then
        table.insert(rows, {
          type = flyoutMenu.ROW_TYPE_Label,
          text = "@ui_cannot_travel_dead",
          topPadding = 0,
          bottomPadding = 30,
          textColor = self.UIStyle.COLOR_RED
        })
      end
    elseif isInArena then
      if isZoomedIn then
        table.insert(rows, {
          type = flyoutMenu.ROW_TYPE_Label,
          text = "@ui_cannot_travel_encounter",
          topPadding = 0,
          bottomPadding = 30,
          textColor = self.UIStyle.COLOR_RED
        })
      end
    else
      do
        local isButtonEnabled = true
        if not isHubAvailable then
          buttonTextTertiary = "@ui_recall_not_available_server_error"
          isButtonEnabled = false
        elseif isEncumbered then
          if isZoomedIn then
            table.insert(rows, {
              type = flyoutMenu.ROW_TYPE_Label,
              text = "@ui_cannot_travel_encumbered",
              topPadding = 0,
              bottomPadding = 16,
              textColor = self.UIStyle.COLOR_RED
            })
          end
          isButtonEnabled = false
        elseif not hasEnoughCurrency then
          buttonTextTertiary = GetLocalizedReplacementText("@ui_cannot_travel_currency", {
            coin = GetLocalizedCurrency(fastTravelCost)
          })
          isButtonEnabled = false
        end
        local fastTravelHeader = "@ui_my_house_map_title"
        local fastTravelDesc = "@ui_house_recall_popup_confirm"
        table.insert(rows, {
          type = flyoutMenu.ROW_TYPE_Button,
          buttonText = "@ui_recall_to_house",
          buttonTextTertiary = buttonTextTertiary,
          isEnabled = isButtonEnabled,
          icon = self.houseIconButtonPath,
          bottomPadding = bottomPadding,
          callbackTable = self,
          callback = function(self)
            self:RequestFastTravel(self.houses[i] - 1, false, fastTravelHeader, fastTravelDesc)
          end
        })
      end
    end
  end
end
function SimpleCapitalIcon:OnFactionControlStatusChanged(settlementId, faction, captureStatus, isActive)
  if settlementId == self.territoryId then
    self.isContested = captureStatus == eFactionControlCaptureStatus_Contested
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointLockIcon, not isActive)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutLockIcon, not isActive)
    self:UpdateFactionOwnership(faction, captureStatus)
    self:UpdateContestIconZoom()
  end
end
function SimpleCapitalIcon:UpdateContestIconZoom()
  if self.capitalType ~= self.CAPITAL_TYPE_FORTRESS then
    return
  end
  if self.currentZoom > self.ZOOM_BARRIER then
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutControlPointContainer, self.isContested)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlPointContainer, self.isContested)
    UiElementBus.Event.SetIsEnabled(self.Properties.ZoomedOutControlPointContainer, false)
  end
end
function SimpleCapitalIcon:MakeObjectivesFlyout(rows)
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  local numAvailableObjectives = self.numAvailableQuests
  local numObjectivesReadyToTurnIn = self.completableObjectives
  if 0 < numAvailableObjectives + numObjectivesReadyToTurnIn and (0 < numAvailableObjectives or 0 < numObjectivesReadyToTurnIn) then
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_Objective,
      questAvailableCount = numAvailableObjectives,
      questTurnInCount = numObjectivesReadyToTurnIn
    })
  end
end
function SimpleCapitalIcon:GetLandmarkType(forInn)
  local landmarkType = forInn and eTerritoryLandmarkType_InnRespawn or self.capitalType == self.CAPITAL_TYPE_TOWNSHIP and eTerritoryLandmarkType_Settlement or self.capitalType == self.CAPITAL_TYPE_OUTPOST and eTerritoryLandmarkType_Outpost or eTerritoryLandmarkType_Fort
  return landmarkType
end
function SimpleCapitalIcon:MakeFastTravelFlyout(rows, forInn, isZoomedIn)
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if isZoomedIn then
    local headerText = forInn and "@ui_inn" or "@ui_settlement_fast_travel"
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_House,
      text = headerText,
      image = "LyShineUI/Images/map/tooltipimages/mapTooltip_inn_default.dds"
    })
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_Separator,
      paddingTop = 0
    })
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_Label,
      text = "@ui_your_inn",
      textColor = self.UIStyle.COLOR_TAN,
      bottomPadding = 22
    })
  elseif forInn then
    local headerText = "@ui_fast_travel"
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_Subheader,
      header = headerText,
      textSize = 18
    })
  end
  local buttonText = forInn and "@ui_inn_fast_travel" or "@ui_fast_travel"
  local timerText, timerIcon, costText, totalText, buttonTextTertiary, buttonIcon, refreshTimer, cooldownEndCallback, cooldownTimeWallClock, timerLocTag
  local showQuestionMark = false
  local tooltipInfo
  if forInn then
    if self.innAtThisSettlementIsActive then
      buttonIcon = self.activeInnIconButtonPath
    else
      buttonIcon = self.inactiveInnIconButtonPath
    end
  else
    buttonIcon = "LyShineUI/Images/map/icon/icon_fastTravel_button.dds"
  end
  local landmarkType = self:GetLandmarkType(forInn)
  local fastTravelResult = PlayerHousingClientRequestBus.Broadcast.CanFastTravelToTerritoryLandmarkPosition(self.territoryId, landmarkType, self.worldPositionVec3)
  local canFastTravel = fastTravelResult == eCanFastTravelToSettlementResults_Success
  if forInn then
    canFastTravel = fastTravelResult == eCanFastTravelToSettlementResults_Success and self.innAtThisSettlementIsActive
  else
    local azothAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount") or 0
    local fastTravelCost = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryLandmarkPositionCost(self.territoryId, landmarkType, self.worldPositionVec3)
    local hasEnoughCurrency = azothAmount >= fastTravelCost
    local color = hasEnoughCurrency and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_RED
    costText = fastTravelCost
    totalText = "<font color=" .. ColorRgbaToHexString(color) .. ">" .. azothAmount .. "</font>" .. " /"
    buttonText = "@ui_fast_travel"
    timerIcon = "lyshineui/images/icon_azoth.dds"
  end
  if canFastTravel then
    if forInn then
      buttonText = "@ui_inn_fast_travel"
    end
  else
    local fastTravelErrorText = self.fastTravelErrorToText[fastTravelResult]
    if fastTravelResult == eCanFastTravelToSettlementResults_InCooldown and (self.innAtThisSettlementIsActive or not forInn) then
      local cooldownTime = fastTravelCommon:GetCurrentlySetInnCooldownTime()
      local timeBeforeRecall = timeHelpers:ConvertSecondsToHrsMinSecString(cooldownTime)
      fastTravelErrorText = GetLocalizedReplacementText("@ui_fast_travel_error_inCooldown", {time = timeBeforeRecall})
      timerText = fastTravelErrorText
      timerIcon = self.hourglassIcon
      refreshTimer = true
      cooldownEndCallback = forInn and self.OnInnCooldownTimerEnd or self.OnHouseCooldownTimerEnd
      cooldownTimeWallClock = fastTravelCommon:GetCurrentlySetInnCooldownTime(true)
      timerLocTag = "@ui_fast_travel_error_inCooldown"
    elseif fastTravelResult == eCanFastTravelToSettlementResults_InvalidDestinationTerritoryId or fastTravelResult == eCanFastTravelToSettlementResults_InvalidStartingTerritoryId then
      buttonTextTertiary = fastTravelErrorText
    end
    if forInn then
      if not self.innAtThisSettlementIsActive then
        if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP then
          tooltipInfo = "@ui_not_checked_in"
        elseif self.capitalType == self.CAPITAL_TYPE_OUTPOST then
          tooltipInfo = "@ui_not_checked_in_outpost"
        end
        showQuestionMark = true
      end
      if fastTravelResult ~= eCanFastTravelToSettlementResults_InCooldown then
        table.insert(rows, {
          type = flyoutMenu.ROW_TYPE_Label,
          text = fastTravelErrorText,
          topPadding = 0,
          bottomPadding = 16,
          textColor = self.UIStyle.COLOR_RED
        })
      end
    end
  end
  local fastTravelPopupHeader = forInn and "@ui_inn_fast_travel" or "@ui_fast_travel"
  local fastTravelPopupDesc = forInn and "@ui_inn_recall_popup_confirm" or "@ui_fast_travel_popup_confirm"
  local bottomPadding = forInn and 0 or 5
  if isZoomedIn then
    bottomPadding = 28
  end
  if not forInn then
    local costs = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryLandmarkPositionCosts(self.territoryId, landmarkType, self.worldPositionVec3)
    local distanceCost = math.floor(costs.distanceCost)
    local encumbranceCost = math.floor(costs.encumbranceCost)
    local baseCost = math.floor(costs.baseCost)
    local factionDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryFactionDiscountPct()
    local companyDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryCompanyDiscountPct()
    local attributeDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryAttributeDiscountPct()
    local governanceData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceData(self.territoryId)
    local overdueUpkeep = governanceData.failedToPayUpkeep
    local factionType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local myGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.territoryId)
    local hasFactionDiscount = factionType == ownerData.faction and factionType ~= nil and factionType ~= eFactionType_None and not overdueUpkeep
    local hasCompanyDiscount = ownerData.guildId ~= nil and myGuildId == ownerData.guildId and not overdueUpkeep
    local hasAttributeDiscount = attributeDiscountPct ~= 0
    local totalCost = baseCost + distanceCost + encumbranceCost
    local totalDiscount = totalCost - costText
    local totalFCPDiscount = costs.baseCostDiscount + costs.distanceCostDiscount + costs.encumbranceCostDiscount
    tooltipInfo = {
      isDiscount = true,
      name = "@ui_tooltip_fasttravel_cost",
      totalDiscounts = totalDiscount,
      costEntries = {
        {
          name = "@ui_tooltip_base_cost",
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = baseCost + costs.baseCostDiscount
        },
        {
          name = "@ui_tooltip_distance_cost",
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = distanceCost + costs.distanceCostDiscount
        },
        {
          name = "@ui_tooltip_encumbrance_cost",
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = encumbranceCost + costs.encumbranceCostDiscount
        }
      },
      costEntriesDiscounts = {
        {
          name = "@ui_fcp_fast_travel_discounts_title",
          type = TooltipCommon.DiscountEntryTypes.CostDiscounts,
          discount = totalFCPDiscount
        }
      },
      discountEntries = {
        {
          name = "@ui_tooltip_faction_discount",
          type = TooltipCommon.DiscountEntryTypes.Faction,
          discountPct = factionDiscountPct,
          hasDiscount = hasFactionDiscount,
          roundValue = true
        },
        {
          name = "@ui_tooltip_company_discount",
          type = TooltipCommon.DiscountEntryTypes.Company,
          discountPct = companyDiscountPct,
          hasDiscount = hasCompanyDiscount,
          roundValue = true,
          useRemainingValue = not hasAttributeDiscount
        }
      }
    }
    if hasAttributeDiscount then
      table.insert(tooltipInfo.discountEntries, {
        name = "@ui_tooltip_attribute_discount",
        type = TooltipCommon.DiscountEntryTypes.Attribute,
        discountPct = attributeDiscountPct,
        hasDiscount = true,
        roundValue = true,
        useRemainingValue = true
      })
    end
  end
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_Button,
    buttonText = buttonText,
    isEnabled = canFastTravel,
    forceUpdate = true,
    icon = buttonIcon,
    buttonTextTertiary = buttonTextTertiary,
    timer = timerText,
    cost = costText,
    total = totalText,
    timerIcon = timerIcon,
    bottomPadding = bottomPadding,
    refreshTimer = refreshTimer,
    timeWallClock = cooldownTimeWallClock,
    timerEndCallback = cooldownEndCallback,
    timerLocTag = timerLocTag,
    showQuestionMark = showQuestionMark,
    tooltipInfo = tooltipInfo,
    callbackTable = self,
    callback = function(self)
      if canFastTravel then
        self:RequestFastTravel(nil, forInn, fastTravelPopupHeader, fastTravelPopupDesc)
      end
    end
  })
end
function SimpleCapitalIcon:OnInnCooldownTimerEnd(button)
  self:OnCooldownTimerEnd(button, true)
end
function SimpleCapitalIcon:OnHouseCooldownTimerEnd(button)
  self:OnCooldownTimerEnd(button, false)
end
function SimpleCapitalIcon:OnCooldownTimerEnd(button, forInn)
  local landmarkType = self:GetLandmarkType(forInn)
  local fastTravelResult = PlayerHousingClientRequestBus.Broadcast.CanFastTravelToTerritoryLandmarkPosition(self.territoryId, landmarkType, self.worldPositionVec3)
  local canFastTravel = fastTravelResult == eCanFastTravelToSettlementResults_Success
  local timerIcon, buttonTextTertiary
  if forInn then
    canFastTravel = fastTravelResult == eCanFastTravelToSettlementResults_Success and self.innAtThisSettlementIsActive
  else
    timerIcon = "lyshineui/images/icon_azoth.dds"
  end
  if not canFastTravel then
    buttonTextTertiary = self.fastTravelErrorToText[fastTravelResult]
  end
  local fastTravelPopupHeader = forInn and "@ui_inn_fast_travel" or "@ui_fast_travel"
  local fastTravelPopupDesc = forInn and "@ui_inn_recall_popup_confirm" or "@ui_fast_travel_popup_confirm"
  local updateData = {
    isEnabled = canFastTravel,
    timerIcon = timerIcon,
    buttonTextTertiary = buttonTextTertiary,
    callbackTable = self,
    callback = function(self)
      if canFastTravel then
        self:RequestFastTravel(nil, forInn, fastTravelPopupHeader, fastTravelPopupDesc)
      end
    end
  }
  button:UpdateDataForTimerEnd(updateData)
end
function SimpleCapitalIcon:RequestFastTravel(houseIndex, forInn, fastTravelText, fastTravelDesc)
  popupWrapper:RequestPopup(ePopupButtons_YesNo, fastTravelText, fastTravelDesc, self.fastTravelPopupId, self, function(self, result, eventId)
    if eventId == self.fastTravelPopupId and result == ePopupResult_Yes then
      local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      local numMissionsAbandonedOnFastTravel = ObjectivesComponentRequestBus.Event.GetNumObjectivesCannotFastTravel(playerEntityId)
      local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
      if interactorEntity then
        UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
      end
      if numMissionsAbandonedOnFastTravel == 0 then
        if houseIndex then
          self:RequestHouseFastTravel(houseIndex)
        else
          self:RequestSettlementFastTravel(forInn)
        end
      else
        do
          local confirmAbandonText = GetLocalizedReplacementText("@ui_fast_travel_mission_abandon_confirm", {count = numMissionsAbandonedOnFastTravel})
          local abandonMissionsId = "HousingFastTravelAbandon"
          popupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_action_abandon", confirmAbandonText, abandonMissionsId, self, function(self, result, eventId)
            if eventId == abandonMissionsId and result == ePopupResult_Yes then
              if houseIndex then
                self:RequestHouseFastTravel(houseIndex)
              else
                self:RequestSettlementFastTravel(forInn)
              end
            end
          end)
        end
      end
    end
  end)
end
function SimpleCapitalIcon:RequestHouseFastTravel(houseIndex)
  PlayerHousingClientRequestBus.Broadcast.RequestFastTravelToHome(houseIndex)
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function SimpleCapitalIcon:RequestSettlementFastTravel(forInn)
  local landmarkType = self:GetLandmarkType(forInn)
  PlayerHousingClientRequestBus.Broadcast.RequestFastTravelToTerritoryLandmarkPosition(self.territoryId, landmarkType, self.worldPositionVec3)
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function SimpleCapitalIcon:OnClick()
  self:OnClickViewInfoPanel()
end
function SimpleCapitalIcon:OpenFlyout(entityId)
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu.openingContext == self.houseIconButtonFlyoutContext and flyoutMenu:ExitHover() then
    return
  end
  local vitalsId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.VitalsEntityId")
  local isInDeathsDoor = VitalsComponentRequestBus.Event.IsDeathsDoor(vitalsId)
  local isDead = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.IsDead")
  local rows = {}
  local enableCompanySection = true
  local factionControlEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled")
  if factionControlEnabled and self.capitalType == self.CAPITAL_TYPE_FORTRESS then
    enableCompanySection = false
  end
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_CapitalInfo,
    capitalType = self.capitalType,
    id = self.territoryId,
    territoryName = self.name,
    enableCompany = enableCompanySection
  })
  if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP then
    self:MakeObjectivesFlyout(rows)
    self:MakeFastTravelFlyout(rows, true)
    self:MakeHomeFlyout(rows)
    self:MakeFastTravelFlyout(rows, false)
    if not isDead and not isInDeathsDoor then
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Subheader,
        header = "@ui_more",
        textSize = 18
      })
    end
  elseif self.capitalType == self.CAPITAL_TYPE_OUTPOST then
    self:MakeObjectivesFlyout(rows)
    self:MakeFastTravelFlyout(rows, true)
    self:MakeFastTravelFlyout(rows, false)
    if not isDead and not isInDeathsDoor then
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Subheader,
        header = "@ui_more",
        textSize = 18
      })
    end
  end
  local buttonText = "@ui_more_info"
  local icon = self.leftMouseIcon
  if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP then
    buttonText = "@ui_view_taxinfo"
    icon = self.viewTaxIcon
  elseif self.capitalType == self.CAPITAL_TYPE_FORTRESS then
    buttonText = "@ui_view_warinfo"
    icon = self.viewWarIcon
  end
  local bottomPadding = 28
  if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP then
    bottomPadding = 0
  end
  if not isDead and not isInDeathsDoor then
    if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP or self.capitalType == self.CAPITAL_TYPE_OUTPOST then
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Button,
        buttonText = "@ui_view_personalstorage",
        isEnabled = true,
        buttonStyle = "DEFAULT",
        bottomPadding = bottomPadding,
        icon = self.storageIcon,
        callbackTable = self,
        callback = function(self)
          self:OnClickViewPersonalStorage()
        end
      })
    end
    if self.capitalType ~= self.CAPITAL_TYPE_OUTPOST then
      if factionControlEnabled and self.capitalType == self.CAPITAL_TYPE_FORTRESS then
        table.insert(rows, {
          type = flyoutMenu.ROW_TYPE_ControlPointStatus,
          capitalType = self.capitalType,
          id = self.territoryId,
          territoryName = self.name
        })
      end
      table.insert(rows, {
        type = flyoutMenu.ROW_TYPE_Button,
        buttonText = buttonText,
        isEnabled = true,
        buttonStyle = "DEFAULT",
        icon = icon,
        bottomPadding = 28,
        callbackTable = self,
        callback = function(self)
          self:OnClickViewInfoPanel()
        end
      })
    end
  end
  if self.flyoutTimingDelay then
    timingUtils:StopDelay(self)
    self.flyoutTimingDelay = nil
  end
  self.flyoutTimingDelay = timingUtils:Delay(0.4, self, function()
    if IsCursorOverUiEntity(entityId, 5) then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
      flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
      flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
      flyoutMenu:SetOpenLocation(entityId)
      flyoutMenu:EnableFlyoutDelay(false)
      flyoutMenu:SetFadeInTime(0.05)
      flyoutMenu:SetFadeOutTime(0.05)
      flyoutMenu:SetSourceHoverOnly(false)
      if self.capitalType == self.CAPITAL_TYPE_TOWNSHIP or self.capitalType == self.CAPITAL_TYPE_OUTPOST then
        flyoutMenu.openingContext = self.houseIconButtonFlyoutContext
      end
      flyoutMenu:SetRowData(rows)
    end
    self.flyoutTimingDelay = nil
  end)
end
return SimpleCapitalIcon
