local InnInteractMenu = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    SetPointButton = {
      default = EntityId()
    },
    NoSetPointButton = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    DescText = {
      default = EntityId()
    },
    CurrentInnText = {
      default = EntityId()
    },
    CurrentInnContainer = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(InnInteractMenu)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local fastTravelCommon = RequireScript("LyShineUI._Common.FastTravelCommon")
function InnInteractMenu:OnInit()
  BaseScreen.OnInit(self)
  self.SetPointButton:SetText("@ui_yes")
  self.SetPointButton:SetCallback(self.SetHomePoint, self)
  self.SetPointButton:SetButtonStyle(self.SetPointButton.BUTTON_STYLE_CTA)
  self.SetPointButton:SetHint("ui_interact", true)
  self.NoSetPointButton:SetCallback(self.OnExit, self)
  self.NoSetPointButton:SetButtonStyle(self.NoSetPointButton.BUTTON_STYLE_DEFAULT)
  self.NoSetPointButton:SetHint("toggleMenuComponent", true)
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
end
function InnInteractMenu:OnShutdown()
end
function InnInteractMenu:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.interactEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.InteractEntityId")
  local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  local homePointInnTerritoryId = fastTravelCommon.GetCurrentlySetInnTerritoryId()
  local hasHomePoint = homePointInnTerritoryId and homePointInnTerritoryId ~= 0
  local currentInnTerritoryId = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryIdByPosition(playerPosition, false)
  local isAtCurrentlySetHomePoint = hasHomePoint and homePointInnTerritoryId == currentInnTerritoryId and PlayerHousingClientRequestBus.Broadcast.IsPlayerInRespawnTerritory(currentInnTerritoryId)
  local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(currentInnTerritoryId)
  local territoryName = territoryDefn.nameLocalizationKey
  local titleText = GetLocalizedReplacementText("@ui_inn_header", {territoryName = territoryName})
  local descText = "@ui_inn_check_in_desc"
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrentInnContainer, false)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonContainer, 76)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.DescText, -110)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.NoSetPointButton, 88)
  if hasHomePoint and isAtCurrentlySetHomePoint then
    descText = "@ui_inn_already_checked_in"
    self.NoSetPointButton:SetText("@ui_back")
    UiElementBus.Event.SetIsEnabled(self.Properties.SetPointButton, false)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.NoSetPointButton, 0)
  elseif hasHomePoint then
    if not self.interactKeyHandler then
      self.interactKeyHandler = CryActionNotificationsBus.Connect(self, "ui_interact")
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.SetPointButton, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CurrentInnContainer, true)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonContainer, 210)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.DescText, -200)
    self.NoSetPointButton:SetText("@ui_no")
    descText = "@ui_inn_replace_desc"
    local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(homePointInnTerritoryId)
    local homePointInnName = territoryDefn.nameLocalizationKey
    local pos = MapComponentBus.Broadcast.GetTerritoryPosition(homePointInnTerritoryId)
    local distance = GetLocalizedDistance(playerPosition, pos)
    local currentInnText = GetLocalizedReplacementText("@ui_current_inn_and_distance", {territoryName = homePointInnName, distance = distance})
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentInnText, currentInnText, eUiTextSet_SetAsIs)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.SetPointButton, true)
    self.NoSetPointButton:SetText("@ui_no")
    if not self.interactKeyHandler then
      self.interactKeyHandler = CryActionNotificationsBus.Connect(self, "ui_interact")
    end
  end
  descText = GetLocalizedReplacementText(descText, {territoryName = territoryName})
  self.ScreenHeader:SetText(titleText)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescText, descText, eUiTextSet_SetLocalized)
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_InnInteractMenu", 0.5)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  if self.interactEntityId then
    local lookAtPos = self:GetNpcLookAtPosition()
    JavCameraControllerRequestBus.Broadcast.SetCameraLookAt(lookAtPos, false)
  end
  self.fromConversationService = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ConversationServiceOpen")
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 7
  self.targetDOFBlur = 0.8
  self.ScriptedEntityTweener:Play(self.DOFTweenDummyElement, 0.25, {
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
end
function InnInteractMenu:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  if self.interactKeyHandler then
    self:BusDisconnect(self.interactKeyHandler)
    self.interactKeyHandler = nil
  end
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntity then
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  if self.fromConversationService then
    self.fromConversationService = nil
    LyShineDataLayerBus.Broadcast.Delete("Hud.LocalPlayer.ConversationServiceOpen")
  end
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
  JavCameraControllerRequestBus.Broadcast.ClearCameraLookAt()
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.DOFTweenDummyElement, 0.3, {
    opacity = 0,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end,
    onComplete = function()
      JavCameraControllerRequestBus.Broadcast.MakeActiveView(4, 2, 5)
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HomePoints.Count")
  DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
end
function InnInteractMenu:OnCryAction(actionName, value)
  local wasKeyPress = 0 < value
  if wasKeyPress and actionName == "ui_interact" then
    self:SetHomePoint()
  end
end
function InnInteractMenu:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function InnInteractMenu:GetNpcLookAtPosition()
  local npcPosition = TransformBus.Event.GetWorldTranslation(self.interactEntityId)
  local rightOffsetDir = Vector3(1, 0, 0)
  local vecFromPlayerToNpc = Vector3(0, 1, 0)
  local upOffset = 1.5
  local rightOffset = 0.25
  local forwardOffset = 1
  local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  if playerPosition then
    local npcPositionWithZMod = Vector3(npcPosition.x, npcPosition.y, npcPosition.z - 1)
    vecFromPlayerToNpc = npcPositionWithZMod - playerPosition
    Vector3.Normalize(vecFromPlayerToNpc)
    rightOffsetDir = Vector3.CrossZAxis(vecFromPlayerToNpc)
    Vector3.Normalize(rightOffsetDir)
  end
  local lookAtPos = npcPosition
  lookAtPos.z = lookAtPos.z + upOffset
  lookAtPos = lookAtPos + rightOffsetDir * rightOffset
  lookAtPos = lookAtPos + vecFromPlayerToNpc * forwardOffset
  return lookAtPos
end
function InnInteractMenu:OnEscapeKeyPressed()
  self:OnExit()
end
function InnInteractMenu:SetHomePoint(entityId, actionName)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.HomePoints.Count", function(self, dataNode)
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HomePoints.Count")
    local currentTerritoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    local currentInnTerritoryId = fastTravelCommon.GetCurrentlySetInnTerritoryId()
    local isAtCurrentlySetHomePoint = PlayerHousingClientRequestBus.Broadcast.IsPlayerInRespawnTerritory(currentInnTerritoryId)
    if isAtCurrentlySetHomePoint then
      self:OnExit()
      local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(currentInnTerritoryId)
      local territoryName = territoryDefn.nameLocalizationKey
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = GetLocalizedReplacementText("@ui_inn_checked_in", {territoryName = territoryName})
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end)
  DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 5, self, function(self)
    self:OnExit()
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_active_home_point_fail"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end)
  LocalPlayerUIRequestsBus.Broadcast.SetInnHomePoint()
end
function InnInteractMenu:OnExit(entityId, actionName)
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
return InnInteractMenu
