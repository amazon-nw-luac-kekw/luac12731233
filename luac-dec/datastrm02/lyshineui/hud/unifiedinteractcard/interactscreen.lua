local InteractScreen = {
  Properties = {
    InteractOptionsElement = {
      default = EntityId()
    },
    OptionsElement = {
      default = EntityId()
    }
  },
  boundOwnershipEntityId = nil,
  playerHasPermission = false,
  screenHasFocus = false,
  screenName = "InteractScreen",
  moreOptionsThreshold = 3
}
local InteractCommon = require("LyShineUI.HUD.UnifiedInteractCard.InteractCommon")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(InteractScreen)
function InteractScreen:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterOpenEvent(self.screenName, self.canvasId)
  self.boundOwnershipEntityId = EntityId()
  self.playerHasPermission = false
  self.screenHasFocus = false
  local interactorEntityId = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntityId and interactorEntityId:GetData() then
    self.uiInteractorComponentNotificationsHandler = UiInteractorComponentNotificationsBus.Connect(self, interactorEntityId:GetData())
  else
    self.dataLayer:RegisterObserver(self, "Hud.LocalPlayer.HudComponent.InteractorEntityId", function(self, dataNode)
      if self.uiInteractorComponentNotificationsHandler then
        self.uiInteractorComponentNotificationsHandler:Disconnect()
        self.uiInteractorComponentNotificationsHandler = nil
      else
        self.uiInteractorComponentNotificationsHandler = UiInteractorComponentNotificationsBus.Connect(self, dataNode:GetData())
      end
    end)
  end
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.UnifiedInteract.ExecutedInteractionButtonEntity", function(self, dataNode)
    if dataNode and dataNode:GetData() then
      local executeButton = dataNode:GetData()
      if executeButton then
        local directParent = UiElementBus.Event.GetParent(executeButton)
        if directParent then
          self.interactParentContainer = UiElementBus.Event.GetParent(directParent)
          local firstButton = UiElementBus.Event.GetChild(directParent, 0)
          if firstButton and firstButton:IsValid() then
            self.entityToDockTo = firstButton
          end
        end
      end
      self:UpdatePosition()
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.OptionsElement, false)
  UiElementBus.Event.SetIsEnabled(self.InteractOptionsElement, false)
end
function InteractScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.uiInteractorComponentNotificationsHandler then
    self.uiInteractorComponentNotificationsHandler:Disconnect()
    self.uiInteractorComponentNotificationsHandler = nil
  end
end
function InteractScreen:UpdatePosition()
  if self.entityToDockTo then
    local viewportPos = UiTransformBus.Event.GetViewportPosition(self.entityToDockTo)
    if viewportPos then
      viewportPos.y = viewportPos.y + 9
      viewportPos.x = viewportPos.x + 4
      UiTransformBus.Event.SetViewportPosition(self.Properties.InteractOptionsElement, viewportPos)
    end
  end
end
function InteractScreen:OnInteractFocus(onFocus)
  if #onFocus.unifiedInteractOptions < self.moreOptionsThreshold then
    return
  end
  self.screenHasFocus = true
  self.boundOwnershipEntityId = onFocus:GetOwnershipBind().ownershipBindEntityId
  self.interactableEntityId = onFocus.interactableEntityId
end
function InteractScreen:OnInteractUnfocus(onUnfocus)
  if not self.screenHasFocus then
    return
  end
  self.screenHasFocus = false
  self:RestoreCardOptions()
  UnifiedInteractOptionsComponentRequestsBus.Event.RemoveAllInteractOptions(self.Properties.InteractOptionsElement)
  if self.ownershipNotificationsHandler then
    self:BusDisconnect(self.ownershipNotificationsHandler)
    self.ownershipNotificationsHandler = nil
  end
  self.playerHasPermission = false
  if LyShineManagerBus.Broadcast.IsInState(3592356463) then
    LyShineManagerBus.Broadcast.ExitState(3592356463)
  end
end
function InteractScreen:OnInteractExecute(onExecute)
  InteractCommon:OnInteractExecute(onExecute, self.Properties.InteractOptionsElement)
end
function InteractScreen:OnOwnershipChanged(ownership)
  local playerComponentData = InteractCommon:GetLocalPlayerComponentData()
  local playerHasPermission = InteractCommon:OnOwnershipChanged({
    ownership = ownership,
    playerComponentData = playerComponentData,
    boundOwnershipEntityId = self.boundOwnershipEntityId
  })
  self:SetPlayerHasPermission(playerHasPermission)
end
function InteractScreen:SetPlayerHasPermission(playerHasPermission, unifiedInteractOptions)
  local playerComponentData = InteractCommon:GetLocalPlayerComponentData()
  InteractCommon:SetPlayerHasPermission({
    unifiedInteractOptions = unifiedInteractOptions,
    lastPlayerHasPermissionState = self.playerHasPermission,
    interactOptionsElement = self.Properties.InteractOptionsElement,
    playerComponentData = playerComponentData,
    playerHasPermission = playerHasPermission
  })
  self.playerHasPermission = playerHasPermission
end
function InteractScreen:OnRelease(entityId)
  local interactMenuButton = self.registrar:GetEntityTable(entityId)
  if interactMenuButton and not interactMenuButton.mIsEnabled then
    return
  end
  LyShineManagerBus.Broadcast.ExitState(3592356463)
end
function InteractScreen:OnTransitionIn()
  self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  local playerComponentData = InteractCommon:GetLocalPlayerComponentData()
  self.playerHasPermission = true
  if self.boundOwnershipEntityId:IsValid() then
    local playerHasPermission = true
    local guildId = GuildsComponentBus.Broadcast.GetGuildId()
    local ownershipGuildId = OwnershipRequestBus.Event.GetGuildId(self.boundOwnershipEntityId)
    playerHasPermission = OwnershipRequestBus.Event.PlayerHasPermissions(self.boundOwnershipEntityId, playerComponentData.playerEntityId, guildId)
    local hasOwnershipComponent = playerHasPermission ~= nil
    if hasOwnershipComponent then
      self.ownershipNotificationsHandler = self:BusConnect(UiOwnershipNotificationsBus, self.boundOwnershipEntityId)
    else
      local ownershipGuildValid = ownershipGuildId and ownershipGuildId:IsValid()
      if not ownershipGuildValid or guildId == ownershipGuildId then
        playerHasPermission = true
      end
    end
    self.playerHasPermission = playerHasPermission
  end
  local unifiedInteractOptions = UiInteractRequestsBus.Event.GetInteractOptions(self.interactableEntityId)
  self:SetPlayerHasPermission(self.playerHasPermission, unifiedInteractOptions)
  local animTriggered = false
  if self.interactParentContainer then
    self:RestoreCardOptions()
    UiElementBus.Event.SetIsEnabled(self.interactParentContainer, true)
    UiElementBus.Event.SetIsEnabled(self.OptionsElement, false)
    UiElementBus.Event.SetIsEnabled(self.InteractOptionsElement, false)
    local interactOptionsGroup = UiElementBus.Event.GetChildren(self.interactParentContainer)
    if 1 <= #interactOptionsGroup then
      local interactChildElements = UiElementBus.Event.GetChildren(interactOptionsGroup[1])
      if 2 <= #interactChildElements then
        local firstOption = interactChildElements[1]
        self.moreOption = interactChildElements[2]
        self.additionalInfo = UiElementBus.Event.FindDescendantByName(firstOption, "AdditionalInfoRoot")
        self.firstOptionText = UiElementBus.Event.FindDescendantByName(firstOption, "Text_Name")
        UiElementBus.Event.SetIsEnabled(self.additionalInfo, false)
        UiElementBus.Event.SetIsEnabled(self.firstOptionText, false)
        local moreOptionChildElements = UiElementBus.Event.GetChildren(self.moreOption)
        if 1 <= #moreOptionChildElements then
          animTriggered = true
          local offsetParent = moreOptionChildElements[1]
          self.ScriptedEntityTweener:Play(offsetParent, 0.3, {y = 55}, {y = 100, ease = "QuadOut"})
          self.ScriptedEntityTweener:Play(self.moreOption, 0.2, {opacity = 1}, {
            opacity = 0,
            ease = "QuadOut",
            onComplete = function()
              UiElementBus.Event.SetIsEnabled(self.OptionsElement, true)
              UiElementBus.Event.SetIsEnabled(self.InteractOptionsElement, true)
              local childElements = UiElementBus.Event.GetChildren(self.Properties.OptionsElement)
              for i = 1, #childElements do
                local button = childElements[i]
                local startDelay = 0.06
                self.ScriptedEntityTweener:Play(button, 0.1, {opacity = 0}, {
                  opacity = 1,
                  delay = startDelay * i
                })
              end
            end
          })
        end
      end
    end
  end
  if not animTriggered then
    UiElementBus.Event.SetIsEnabled(self.OptionsElement, true)
    UiElementBus.Event.SetIsEnabled(self.InteractOptionsElement, true)
  end
  local viewportPosition = UiTransformBus.Event.GetViewportPosition(self.entityId)
  CursorBus.Broadcast.SetCursorPosition(viewportPosition)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
end
function InteractScreen:RestoreCardOptions()
  if self.additionalInfo then
    UiElementBus.Event.SetIsEnabled(self.additionalInfo, true)
    UiElementBus.Event.SetIsEnabled(self.firstOptionText, true)
    if self.moreOption and self.moreOption:IsValid() then
      self.ScriptedEntityTweener:Play(self.moreOption, 0.15, {opacity = 0}, {opacity = 1})
      local offsetParent = UiElementBus.Event.GetChild(self.moreOption, 0)
      if offsetParent and offsetParent:IsValid() then
        self.ScriptedEntityTweener:Set(offsetParent, {y = 55})
      end
    end
  end
  self.additionalInfo = nil
end
function InteractScreen:OnTransitionOut()
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  if self.interactParentContainer and self.screenHasFocus then
    UiElementBus.Event.SetIsEnabled(self.interactParentContainer, true)
    self:RestoreCardOptions()
  end
  UiElementBus.Event.SetIsEnabled(self.OptionsElement, false)
  UiElementBus.Event.SetIsEnabled(self.InteractOptionsElement, false)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function InteractScreen:OnTick(deltaTime, timePoint)
  self:UpdatePosition()
  UiElementBus.Event.SetIsEnabled(self.OptionsElement, true)
end
return InteractScreen
