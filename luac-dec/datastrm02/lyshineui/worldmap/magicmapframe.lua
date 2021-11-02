local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local MagicMapFrame = {
  Properties = {
    ActionMapActivators = {
      default = {
        "toggleMapComponent"
      }
    },
    UseActionMapActivators = {default = true},
    MagicMap = {
      default = EntityId()
    },
    MarkersLayer = {
      default = EntityId()
    },
    BackgroundElement = {
      default = EntityId()
    },
    HintExit = {
      default = EntityId()
    },
    HintWaypoint = {
      default = EntityId()
    },
    CenterPlayer = {
      default = EntityId()
    },
    ZoomOutButton = {
      default = EntityId()
    },
    ZoomInButton = {
      default = EntityId()
    },
    HintWaypointText = {
      default = EntityId()
    },
    HintExitText = {
      default = EntityId()
    },
    Black = {
      default = EntityId()
    },
    MapMenuContainer = {
      default = EntityId()
    },
    RedeemAnimation = {
      default = EntityId()
    },
    Message = {
      default = EntityId()
    },
    MessageText = {
      default = EntityId()
    },
    TerritoryStandingIcon = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    }
  },
  filterOptionsOpen = false,
  worldMapName = "MagicMap",
  notificationHandlers = {},
  teleportPlayerKeybinding = "teleport_player"
}
BaseScreen:CreateNewScreen(MagicMapFrame)
function MagicMapFrame:OnInit()
  BaseScreen.OnInit(self)
  AdjustElementToCanvasSize(self.Properties.MapMenuContainer, self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.MapMenuContainer:SetMarkersLayer(self.MarkersLayer)
  self.HintExit:SetKeybindMapping("toggleMapComponent")
  UiTextBus.Event.SetFont(self.Properties.HintWaypointText, self.UIStyle.FONT_FAMILY_PICA_ITALIC)
  UiTextBus.Event.SetFont(self.Properties.HintExitText, self.UIStyle.FONT_FAMILY_PICA_ITALIC)
  self.HintExit:SetCallback(function()
    LyShineManagerBus.Broadcast.ExitState(2477632187)
  end, self)
  self.CenterPlayer:SetCallback("OnCenterPlayer", self)
  self.CenterPlayer:SetText("")
  self.CenterPlayer:SetIconPath("lyshineui/images/icons/worldmap/worldmap_iconCenterPlayer.png")
  self.CenterPlayer:SetIconPositionX(1)
  self.ZoomOutButton:SetCallback("OnZoomOut", self)
  self.ZoomInButton:SetCallback("OnZoomIn", self)
  self.ZoomOutButton:SetIconPath("lyshineui/images/icons/worldmap/worldmap_iconZoomOut.png")
  self.ZoomInButton:SetIconPath("lyshineui/images/icons/worldmap/worldmap_iconZoomIn.png")
  self.ZoomOutButton:SetText("")
  self.ZoomInButton:SetText("")
  self.ZoomOutButton:SetIconPositionX(1)
  self.ZoomInButton:SetIconPositionX(1)
  local popupBonusMessageStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = self.UIStyle.FONT_SIZE_STANDING_BONUS_MESSAGE,
    fontColor = self.UIStyle.COLOR_TAN_STANDING_BONUS_MESSAGE,
    fontEffect = self.UIStyle.FONT_EFFECT_DROPSHADOW,
    characterSpacing = self.UIStyle.FONT_SPACING_TITLE_GENERIC,
    textCasing = self.UIStyle.TEXT_CASING_UPPER
  }
  SetTextStyle(self.Properties.MessageText, popupBonusMessageStyle)
  self:BusConnect(DynamicBus.UITickBus)
  self:BusConnect(UiScrollBoxNotificationBus, self.Properties.MagicMap)
  for k, v in pairs(self.Properties.ActionMapActivators) do
    self:BusConnect(CryActionNotificationsBus, v)
  end
  self:BusConnect(CryActionNotificationsBus, self.teleportPlayerKeybinding)
  self.dataLayer:RegisterOpenEvent(self.worldMapName, self.canvasId)
  self.enableWorldMapTeleport = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableWorldMapTeleport")
  UiElementBus.Event.SetIsEnabled(self.Properties.Black, false)
end
function MagicMapFrame:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  self.territoryBonusPopupCallbacksSet = false
end
function MagicMapFrame:OnCryAction(actionName)
  if actionName == self.teleportPlayerKeybinding then
    local isEnabled = self.canvasId and UiCanvasBus.Event.GetEnabled(self.canvasId)
    if isEnabled and self.enableWorldMapTeleport and LyShineScriptBindRequestBus.Broadcast.GetCVar("sys_DeactivateConsole") == 0 then
      self.MagicMap:TeleportPlayer()
    end
  elseif DynamicBus.MagicMap.Broadcast.IsShowingObjectiveData() then
    LyShineManagerBus.Broadcast.SetState(2609973752)
  else
    LyShineManagerBus.Broadcast.ToggleState(2477632187)
  end
end
function MagicMapFrame:OnAction(entityId, actionName)
  if not BaseScreen.OnAction(self, entityId, actionName) and type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function MagicMapFrame:OnZoomIn(entityId, actionName)
  self.MagicMap:ZoomIn(false)
end
function MagicMapFrame:OnZoomOut(entityId, actionName)
  self.MagicMap:ZoomOut(false)
end
function MagicMapFrame:OnCenterPlayer()
  self.MagicMap:CenterToPlayer(false)
end
function MagicMapFrame:OnTopLevelEntitiesSpawned(ticket, entities)
end
function MagicMapFrame:OnEscapeKeyPressed()
  if DynamicBus.TerritoryBonusPopupBus.Broadcast.IsTerritoryBonusPopupVisible() then
    DynamicBus.TerritoryBonusPopupBus.Broadcast.OnEscapeKeyPressed()
    return
  end
  self:OnClose()
end
function MagicMapFrame:OnClose()
  LyShineManagerBus.Broadcast.ExitState(2477632187)
end
function MagicMapFrame:CenterOnLocationOnce()
  local mapLocation = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OpenMapPosition")
  if mapLocation ~= nil then
    self.MagicMap:CenterToPosition(mapLocation, false)
    LyShineDataLayerBus.Broadcast.Delete("Hud.LocalPlayer.OpenMapPosition")
  end
  local missionId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OpenMapMission")
  self.highlightId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OpenMapHighlightId")
  self.MapMenuContainer.ObjectiveContainer:SetVisibility(missionId ~= nil)
  if missionId ~= nil then
    self.MapMenuContainer.ObjectiveContainer:SetMissionId(missionId)
    self.ScriptedEntityTweener:Play(self.Properties.MapMenuContainer.Properties.ObjectiveContainer, 0.1, {opacity = 0}, {
      opacity = 1,
      ease = "QuadIn",
      onComplete = function()
        if self.highlightId ~= nil then
          self.MarkersLayer:HighlightPOI(self.highlightId, true)
        end
      end
    })
  end
end
function MagicMapFrame:OnTransitionIn(stateName, levelName)
  if not self.territoryBonusPopupCallbacksSet then
    DynamicBus.TerritoryBonusPopupBus.Broadcast.SetMapCallbacks(self.ShowTerritoryBonusPopupScrim, self.HideTerritoryBonusPopupScrim, self.PlayRedeemAnimation, self)
    self.territoryBonusPopupCallbacksSet = true
  end
  self.audioHelper:PlaySound(self.audioHelper.PlayMapOpen)
  self.MagicMap:SetIsVisible(true)
  local centerOnPlayer = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.SetOpenMapCenteredOnPlayer")
  if centerOnPlayer == nil or centerOnPlayer == true then
    self.MagicMap:CenterToPlayer(true, true)
  end
  LyShineDataLayerBus.Broadcast.Delete("Hud.LocalPlayer.SetOpenMapCenteredOnPlayer")
  self:CenterOnLocationOnce()
  self.MarkersLayer:SetRespondingToDataUpdates(true)
  self.MarkersLayer:SetIsVisible(true)
  self.MarkersLayer:PulseAllNewPOIs()
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  self.ScriptedEntityTweener:Set(self.Properties.ButtonContainer, {opacity = 1})
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Map.ScreenChecked", true)
end
function MagicMapFrame:OnTransitionOut(stateName, levelName)
  self.audioHelper:PlaySound(self.audioHelper.PlayMapClose)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.MagicMap:SetIsVisible(false)
  self.MarkersLayer:SetRespondingToDataUpdates(false)
  self.MarkersLayer:SetIsVisible(false)
  if self.highlightId ~= nil then
    self.MarkersLayer:ClearHighlightPOI(self.highlightId)
    self.highlightId = nil
    LyShineDataLayerBus.Broadcast.Delete("Hud.LocalPlayer.OpenMapHighlightId")
  end
  self.MarkersLayer:ClearAllNewPOIs()
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
end
function MagicMapFrame:ShowTerritoryBonusPopupScrim()
  UiElementBus.Event.SetIsEnabled(self.Properties.Black, true)
  self.ScriptedEntityTweener:Play(self.Properties.Black, 0.4, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
end
function MagicMapFrame:HideTerritoryBonusPopupScrim()
  self.ScriptedEntityTweener:Play(self.Properties.Black, 0.2, {opacity = 0.8}, {
    opacity = 0,
    ease = "QuadIn",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.Black, false)
    end
  })
end
function MagicMapFrame:PlayRedeemAnimation(updateText)
  UiElementBus.Event.SetIsEnabled(self.Properties.RedeemAnimation, true)
  UiFlipbookAnimationBus.Event.Start(self.Properties.RedeemAnimation)
  if updateText then
    local territoryId = DynamicBus.TerritoryBonusPopupBus.Broadcast.GetTerritoryId()
    local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(territoryId)
    local text = GetLocalizedReplacementText("@ui_territory_bonus_redeemed", {
      territory = posData.territoryName
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.MessageText, text, eUiTextSet_SetAsIs)
  end
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Inventory_Add)
  self.ScriptedEntityTweener:Play(self.Properties.RedeemAnimation, 0.4, {
    scaleX = 1,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.Message, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryStandingIcon, true)
      self.ScriptedEntityTweener:Stop(self.Properties.Message)
      self.ScriptedEntityTweener:Stop(self.Properties.TerritoryStandingIcon)
      self.ScriptedEntityTweener:Play(self.Properties.Message, 0.3, {opacity = 0, x = -34}, {
        opacity = 1,
        x = -86,
        ease = "QuadOut",
        onComplete = function()
          self.ScriptedEntityTweener:Play(self.Properties.Message, 0.4, {opacity = 1}, {
            opacity = 0,
            ease = "QuadOut",
            delay = 0.8
          })
        end
      })
      self.ScriptedEntityTweener:Play(self.Properties.TerritoryStandingIcon, 0.2, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        onComplete = function()
          self.ScriptedEntityTweener:Play(self.Properties.TerritoryStandingIcon, 0.4, {opacity = 1}, {
            opacity = 0,
            ease = "QuadOut",
            delay = 0.8,
            onComplete = function()
              UiElementBus.Event.SetIsEnabled(self.Properties.Message, false)
              UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryStandingIcon, false)
            end
          })
        end
      })
    end
  })
end
function MagicMapFrame:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.Properties.MapMenuContainer, self.canvasId)
  end
end
return MagicMapFrame
