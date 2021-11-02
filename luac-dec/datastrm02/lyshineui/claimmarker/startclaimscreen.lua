local StartClaimScreen = {
  Properties = {
    WindowContainer = {
      default = EntityId()
    },
    ScreenHeader = {
      default = EntityId()
    },
    TextTerritoryName = {
      default = EntityId()
    },
    StartClaimingButton = {
      default = EntityId()
    },
    StartClaimingButtonContainer = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    TaxesAndFeesContainer = {
      default = EntityId()
    },
    WalletAmountText = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    }
  },
  mFirstTimeOpen = true,
  requiredResources = {},
  claimKey = nil
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(StartClaimScreen)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(StartClaimScreen)
function StartClaimScreen:OnInit()
  BaseScreen.OnInit(self)
  self.claimCost = ConfigProviderEventBus.Broadcast.GetInt("javelin.territory-claim-cost")
  self.StartClaimingButton:SetButtonStyle(self.StartClaimingButton.BUTTON_STYLE_CTA)
  self.StartClaimingButton:SetCallback(self.OnStartClaimingButtonClicked, self)
  self.exitingFromStartClaimPressed = false
  self.ScreenHeader:SetText("@ui_claimmarker_claimterritory.")
  self.ScreenHeader:SetHintCallback(self.Close, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.BuilderEntityId", function(self, data)
    self.builderId = data
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
    if claimKey and claimKey ~= 0 then
      self.claimKey = claimKey
    end
  end)
  if self.spawnHandler then
    self:BusDisconnect(self.spawnHandler)
    self.spawnHandler = nil
  end
  self.ScriptedEntityTweener:Set(self.Properties.DOFTweenDummyElement, {opacity = 0})
end
function StartClaimScreen:OnShutdown()
end
function StartClaimScreen:OnDeactivate()
  if LyShineManagerBus.Broadcast.IsInState(2025666924) then
    self:OnTransitionOut()
  end
end
function StartClaimScreen:Open()
  LyShineManagerBus.Broadcast.QueueState(2025666924)
end
function StartClaimScreen:Close()
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function StartClaimScreen:OnTransitionIn(stateName, level)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  if playerPosition then
    local pos = Vector2(playerPosition.x, playerPosition.y)
    local tractName = MapComponentBus.Broadcast.GetTractAtPosition(pos)
    UiTextBus.Event.SetText(self.Properties.TextTerritoryName, "")
    if self.claimKey then
      local claimPosData = LandClaimRequestBus.Broadcast.GetClaimPosData(self.claimKey)
      if claimPosData and claimPosData.territoryName then
        UiTextBus.Event.SetTextWithFlags(self.TextTerritoryName, claimPosData.territoryName, eUiTextSet_SetLocalized)
      end
    end
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", function(self, currencyAmount)
    self.currencyAmount = currencyAmount or 0
    UiTextBus.Event.SetText(self.Properties.WalletAmountText, GetLocalizedCurrency(self.currencyAmount))
    self:UpdateClaimButtonState()
  end)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("StartClaim", 0.5)
  self:SetScreenVisible(true)
  self.audioHelper:PlaySound(self.audioHelper.Screen_TerritoryClaimOpen)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 16
  self.targetDOFBlur = 0.3
  self.ScriptedEntityTweener:Play(self.Properties.DOFTweenDummyElement, 0.5, {
    opacity = 1,
    ease = "QuadIn",
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
end
function StartClaimScreen:OnTransitionOut(stateName, level)
  if not self.exitingFromStartClaimPressed then
    local interactorEntityNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    if interactorEntityNode then
      local interactorEntity = interactorEntityNode:GetData()
      UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
    end
  end
  self.exitingFromStartClaimPressed = false
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
  local durationOut = 0.2
  self.ScriptedEntityTweener:Play(self.entityId, durationOut, {
    opacity = 0,
    onComplete = function()
      JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
      UiCanvasBus.Event.SetEnabled(self.canvasId, false)
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
      LyShineManagerBus.Broadcast.TransitionOutComplete()
      LyShineManagerBus.Broadcast.ExitState(2478623298)
      self:SetScreenVisible(false)
    end
  })
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("StartClaim", 0.5)
  self.StartClaimingButton:StartStopImageSequence(false)
  self.audioHelper:PlaySound(self.audioHelper.Screen_TerritoryClaimClose)
end
function StartClaimScreen:SetScreenVisible(isVisible)
  if isVisible then
    self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  end
end
function StartClaimScreen:OnRequiredResourceSpawned(entity, itemDescriptor)
  entity:SetData(itemDescriptor)
  table.insert(self.requiredResources, entity)
  self:UpdateClaimButtonState()
end
function StartClaimScreen:UpdateClaimButtonState()
  local hasEnoughCoin = true
  hasEnoughCoin = self.currencyAmount >= self.claimCost
  local factionType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  local myGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local canClaim = false
  local buttonText
  if factionType == eFactionType_None then
    self.StartClaimingButton:SetButtonStyle(self.StartClaimingButton.BUTTON_STYLE_CTA)
    self.StartClaimingButton:StartStopImageSequence(false)
    buttonText = "@ui_claimmarker_join_faction"
  elseif not myGuildId or not myGuildId:IsValid() then
    self.StartClaimingButton:SetButtonStyle(self.StartClaimingButton.BUTTON_STYLE_CTA)
    self.StartClaimingButton:StartStopImageSequence(false)
    buttonText = "@ui_claimmarker_join_guild"
  else
    self.StartClaimingButton:SetButtonStyle(self.StartClaimingButton.BUTTON_STYLE_HERO)
    self.StartClaimingButton:StartStopImageSequence(true)
    buttonText = GetLocalizedReplacementText("@ui_claimmarker_claim_button_coin", {
      colorHex = ColorRgbaToHexString(hasEnoughCoin and self.UIStyle.COLOR_YELLOW_GOLD or self.UIStyle.COLOR_RED_DARK),
      cost = GetLocalizedCurrency(self.claimCost)
    })
    canClaim = true
  end
  self.StartClaimingButton:SetText(buttonText)
  if not canClaim then
    self.StartClaimingButton:SetEnabled(true)
    self.StartClaimingButton:SetCallback(self.RequestGuildMenu, self)
  elseif hasEnoughCoin then
    self.StartClaimingButton:SetEnabled(true)
    self.StartClaimingButton:SetCallback(self.OnStartClaimingButtonClicked, self)
  else
    self.StartClaimingButton:SetEnabled(false)
  end
end
function StartClaimScreen:OnStartClaimingButtonClicked()
  LocalPlayerUIRequestsBus.Broadcast.PurchaseClaim()
  self.exitingFromStartClaimPressed = true
  self:Close()
end
function StartClaimScreen:RequestGuildMenu()
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  self:Close()
  LyShineManagerBus.Broadcast.QueueState(1967160747)
end
function StartClaimScreen:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
return StartClaimScreen
