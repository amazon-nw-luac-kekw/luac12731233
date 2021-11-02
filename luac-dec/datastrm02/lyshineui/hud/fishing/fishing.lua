local FishingHUD = {
  Properties = {
    PromptsContainer = {
      default = EntityId()
    },
    CastContainer = {
      default = EntityId()
    },
    CastHint = {
      default = EntityId()
    },
    CastActionText = {
      default = EntityId()
    },
    NoToolEquippedText = {
      default = EntityId()
    },
    CastBg = {
      default = EntityId()
    },
    BaitContainer = {
      default = EntityId()
    },
    BaitHint = {
      default = EntityId()
    },
    BaitSelected = {
      default = EntityId()
    },
    BaitActionText = {
      default = EntityId()
    },
    BaitBg = {
      default = EntityId()
    },
    NoBaitIcon = {
      default = EntityId()
    },
    ExitContainer = {
      default = EntityId()
    },
    ExitActionText = {
      default = EntityId()
    },
    ExitHint = {
      default = EntityId()
    },
    ExitBg = {
      default = EntityId()
    },
    CastBarContainer = {
      default = EntityId()
    },
    CastBar = {
      default = EntityId()
    },
    PowerIndicator = {
      default = EntityId()
    },
    PowerNode = {
      default = EntityId()
    },
    PowerNodeHighlight = {
      default = EntityId()
    },
    IndicatorText = {
      default = EntityId()
    },
    CastingProgress = {
      default = EntityId()
    },
    ReleaseEffectSmall = {
      default = EntityId()
    },
    ReleaseEffectBigHorizontal = {
      default = EntityId()
    },
    ReleaseEffectBigVertical = {
      default = EntityId()
    },
    ReleaseEffectBigCenter = {
      default = EntityId()
    },
    SequenceHorizontal = {
      default = EntityId()
    },
    SequenceVertical = {
      default = EntityId()
    },
    BobberContainer = {
      default = EntityId()
    },
    BobberBg = {
      default = EntityId()
    },
    InnerBobberContainer = {
      default = EntityId()
    },
    BobberIcon = {
      default = EntityId()
    },
    BobberFill = {
      default = EntityId()
    },
    HookIcon = {
      default = EntityId()
    },
    HookText = {
      default = EntityId()
    },
    HookTextBg = {
      default = EntityId()
    },
    BobberHint = {
      default = EntityId()
    },
    BobberDistanceText = {
      default = EntityId()
    },
    DepthText = {
      default = EntityId()
    },
    GetReadyText = {
      default = EntityId()
    },
    Pulse1 = {
      default = EntityId()
    },
    RedPulse = {
      default = EntityId()
    },
    TensionContainer = {
      default = EntityId()
    },
    TensionDistance = {
      default = EntityId()
    },
    TensionIndicator = {
      default = EntityId()
    },
    TensionText = {
      default = EntityId()
    },
    TensionTextBg = {
      default = EntityId()
    },
    DistanceMeter = {
      default = EntityId()
    },
    BaitSelectionContainer = {
      default = EntityId()
    },
    BaitSelectionBg = {
      default = EntityId()
    },
    BaitSelectionExitHint = {
      default = EntityId()
    },
    BaitHighlight = {
      default = EntityId()
    },
    CurrentBaitIndicator = {
      default = EntityId()
    },
    NoBaitButton = {
      default = EntityId()
    },
    NoBaitButtonHover = {
      default = EntityId()
    },
    NoBaitTooltip = {
      default = EntityId()
    },
    NoBaitSelected = {
      default = EntityId()
    },
    FreshWaterBaitHeader = {
      default = EntityId()
    },
    FreshWaterBaitGrid = {
      default = EntityId()
    },
    SaltWaterBaitHeader = {
      default = EntityId()
    },
    SaltWaterBaitGrid = {
      default = EntityId()
    },
    SelectedBaitHeader = {
      default = EntityId()
    },
    SelectedIcon = {
      default = EntityId()
    },
    SelectedIconBg = {
      default = EntityId()
    },
    BaitName = {
      default = EntityId()
    },
    BaitBenefit = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    AttachBaitButton = {
      default = EntityId()
    },
    ItemPrototype = {
      default = EntityId()
    },
    SuccessContainer = {
      default = EntityId()
    },
    SequenceLight = {
      default = EntityId()
    },
    SuccessEffect = {
      default = EntityId()
    },
    SuccessText = {
      default = EntityId()
    }
  },
  tickHandler = nil,
  offsetFromBobber = 25,
  jitterAmount = 2.5,
  selectedBait = nil,
  isShowingBaitSelection = false,
  toggleFishingBaitWindowAction = "toggleFishingBaitWindow",
  exitBaitWindowAction = "toggleMenuComponent",
  baitIconPadding = 20,
  cameraOverriden = false,
  cryActionHandlers = {},
  previousValue = 0,
  currentValue = 0,
  castingBarHeight = 210,
  defaultYPosition = 0,
  yOffset = 138,
  spacingBetweenHeader = 24,
  bobberClamp = 0,
  resolution = Vector2(1920, 1080),
  bobberBgPath = "lyshineui/images/hud/fishing/fishing_bobberBg.dds",
  tensionMeterBgPath = "lyshineui/images/hud/fishing/fishing_tensionMeterBg.dds",
  checkmarkImagePath = "lyshineui/images/hud/fishing/fishing_checkmark.dds",
  hookIconImagePath = "lyshineui/images/hud/fishing/fishing_hookIcon.dds",
  sequenceImagePath = "lyshineui/images/hud/fishing/tensionImageSequence/tension",
  selectedIconBgPath = "lyshineui/images/crafting/crafting_itemRarityBg0.dds",
  noBaitIconBgPath = "lyshineui/images/hud/fishing/fishing_noBait.dds",
  actionMapDisabled = false,
  actionMapToDisable = "ui"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(FishingHUD)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function FishingHUD:OnInit()
  BaseScreen.OnInit(self)
  self.screenStatesToDisable = {
    [3901667439] = true,
    [1967160747] = true,
    [3576764016] = true,
    [2477632187] = true,
    [2815678723] = true,
    [3175660710] = true,
    [849925872] = true,
    [663562859] = true,
    [1634988588] = true,
    [3766762380] = true,
    [1823500652] = true,
    [3406343509] = true
  }
  self.bobberTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.bobberTimeline:Add(self.Properties.InnerBobberContainer, 0.1, {
    y = self.jitterAmount
  })
  self.bobberTimeline:Add(self.Properties.InnerBobberContainer, 0.1, {
    y = -self.jitterAmount,
    onComplete = function()
      self.bobberTimeline:Play()
    end
  })
  self.pulseTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.pulseTimeline:Add(self.Properties.RedPulse, 0.05, {
    scaleX = 0,
    scaleY = 0,
    opacity = 1
  })
  self.pulseTimeline:Add(self.Properties.RedPulse, 0.3, {
    scaleX = 0.9,
    scaleY = 0.9,
    opacity = 0.8,
    ease = "QuadInOut"
  })
  self.pulseTimeline:Add(self.Properties.RedPulse, 0.2, {
    scaleX = 1,
    scaleY = 1,
    opacity = 0
  })
  self.pulseTimeline:Add(self.Properties.RedPulse, 0.01, {
    scaleX = 0,
    scaleY = 0,
    opacity = 0,
    onComplete = function()
      self.pulseTimeline:Play()
    end
  })
  self.bobberClamp = UiTransform2dBus.Event.GetLocalWidth(self.Properties.BobberContainer)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, vitalsId)
    if vitalsId then
      self.vitalsId = vitalsId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.fishing.distance", function(self, distance)
        if distance and self.maxDistance then
          UiTextBus.Event.SetText(self.Properties.TensionDistance, string.format("%.1fm", distance))
          local perc = (self.maxDistance - distance) / self.maxDistance
          UiImageBus.Event.SetFillAmount(self.Properties.DistanceMeter, perc)
          local safeZone = self.maxDistance - self.maxDistance * 0.1
          if distance < safeZone then
            if not self.bobberHintFadedOut then
              self.ScriptedEntityTweener:PlayC(self.Properties.BobberHint, 0.3, tweenerCommon.fadeOutQuadOut, 0.5)
              self.bobberHintFadedOut = true
            end
          elseif self.bobberHintFadedOut then
            self.ScriptedEntityTweener:PlayC(self.Properties.BobberHint, 0.1, tweenerCommon.fadeInQuadOut)
            self.bobberHintFadedOut = false
          end
        end
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.fishing.tension", function(self, tension)
        if tension then
          local percentage = tension / FishingRequestsBus.Event.GetMaxTension(self.playerEntityId)
          local numberOfImages = 90
          local fileName = math.floor(percentage * numberOfImages)
          local sequenceImagePath = self.sequenceImagePath .. fileName .. ".dds"
          UiImageBus.Event.SetSpritePathname(self.Properties.TensionIndicator, sequenceImagePath)
          tension_rtpc = percentage * 100
          AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.playerEntityId, "Fishing_Tension", tension_rtpc)
          if 0.6 < percentage then
            if not self.pulseStarted then
              UiElementBus.Event.SetIsEnabled(self.Properties.RedPulse, true)
              self.pulseTimeline:Play()
              self.pulseStarted = true
            end
          elseif self.pulseStarted then
            UiElementBus.Event.SetIsEnabled(self.Properties.RedPulse, false)
            self.pulseTimeline:Stop()
            self.ScriptedEntityTweener:PlayC(self.Properties.RedPulse, 0, tweenerCommon.scaleTo0)
            self.pulseStarted = false
          end
        end
      end)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.fishing.state", function(self, state)
    self:SetState(state)
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.fishing.castBarDistance", function(self, distance)
    if distance then
      local maxDistance = FishingRequestsBus.Event.GetMaxBarSize(self.playerEntityId)
      local height = self.castingBarHeight
      local perc = distance / maxDistance
      local newYPos = perc * height
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PowerIndicator, -newYPos)
      UiImageBus.Event.SetFillAmount(self.Properties.CastingProgress, perc)
      self.distance = distance
      self.previousValue = self.currentValue
      self.currentValue = distance
      self.meterUp = self.currentValue > self.previousValue
      casting_rtpc = perc * 100
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.playerEntityId, "Fishing_Casting", casting_rtpc)
    end
  end)
  self.dataLayer:RegisterAndExecuteObserver(self, "Hud.LocalPlayer.Options.Video.Resolution", function(self, resolution)
    if resolution then
      self.resolution = Vector2(resolution.Width:GetData(), resolution.Height:GetData())
      self.scale = Vector2(1920 / self.resolution.x, 1080 / self.resolution.y)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.fishing.bobberPosition", function(self, position)
    if position then
      self.bobberPosition = position
      self:UpdateBobberPosition()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerHeading", function(self, heading)
    self:UpdateBobberPosition()
  end)
  self.CancelButton:SetText("@ui_cancel", false)
  self.CancelButton:SetCallback(self.OnCancelPressed, self)
  self.AttachBaitButton:SetText("@ui_fishing_attach_bait", false)
  self.AttachBaitButton:SetCallback(self.OnApplyBaitPressed, self)
  self.AttachBaitButton:SetButtonStyle(self.AttachBaitButton.BUTTON_STYLE_CTA)
  self.FreshWaterBaitHeader:SetIconVisible(false)
  self.FreshWaterBaitHeader:SetText("@ui_fishing_fresh_water_bait")
  self.FreshWaterBaitHeader:SetLineVisible(true)
  self.FreshWaterBaitHeader:SetFontSize(24)
  self.FreshWaterBaitHeader:SetCharacterSpacing(150)
  self.SaltWaterBaitHeader:SetIconVisible(false)
  self.SaltWaterBaitHeader:SetText("@ui_fishing_salt_water_bait")
  self.SaltWaterBaitHeader:SetLineVisible(true)
  self.SaltWaterBaitHeader:SetFontSize(24)
  self.SaltWaterBaitHeader:SetCharacterSpacing(150)
  self.SelectedBaitHeader:SetIconVisible(false)
  self.SelectedBaitHeader:SetText("@ui_fishing_selected_bait")
  self.SelectedBaitHeader:SetLineVisible(true)
  self.SelectedBaitHeader:SetFontSize(24)
  self.SelectedBaitHeader:SetCharacterSpacing(150)
  self.NoBaitTooltip:SetSimpleTooltip("@ui_fishing_nobait_tooltip")
  local castTextSize = UiTextBus.Event.GetTextSize(self.Properties.CastActionText).x
  local castTextWidth = castTextSize + 100
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.CastBg, castTextWidth)
  local exitTextSize = UiTextBus.Event.GetTextSize(self.Properties.ExitActionText).x
  local exitTextWidth = exitTextSize + 100
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.ExitBg, exitTextWidth)
  self.BaitSelectionBg:SetFillAlpha(1)
  self.BaitSelectionExitHint:SetActionMap("ui")
  self.BaitSelectionExitHint:SetKeybindMapping("toggleMenuComponent")
  self.BaitSelectionExitHint:SetCallback(self.OnEscapePressed, self)
  self.FreshWaterBaitGrid:Initialize(self.ItemPrototype, nil)
  self.SaltWaterBaitGrid:Initialize(self.ItemPrototype, nil)
  self.defaultYPosition = UiTransformBus.Event.GetLocalPositionY(self.Properties.FreshWaterBaitHeader)
  self:SetVisualElements()
  self.fishingModeActionHandler = self:BusConnect(CryActionNotificationsBus, "fishing_activate")
end
function FishingHUD:OnCryAction(actionname, value)
  if actionname == "cam_zoom_in" or actionname == "cam_zoom_out" then
    self:UpdateBobberPosition()
  elseif actionname == self.toggleFishingBaitWindowAction then
    if self.isShowingBaitSelection and self.state == eFishingState_ApplyingBait then
      self:ToggleBaitWindow()
    elseif not self.isShowingBaitSelection and self.state == eFishingState_Equipped then
      FishingRequestsBus.Event.RequestOpenBaitBox(self.playerEntityId)
    end
  elseif self.isShowingBaitSelection and actionname == self.exitBaitWindowAction then
    self:ToggleBaitWindow()
  elseif actionname == "fishing_activate" then
    local gatheringEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GatheringEntityId")
    local tool = UiGatheringComponentRequestsBus.Event.GetValidGatheringToolList(gatheringEntityId, "Fishing")
    if not tool or not tool:IsValid() then
      local isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
      if not isFtue then
        local toolText = "@ui_no_pole_instruction"
        local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
        local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, ePaperDollSlotTypes_Fishing)
        if slot and slot:IsBroken() then
          toolText = "@ui_pole_broken"
        end
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = toolText
        notificationData.allowDuplicates = false
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    end
  end
end
function FishingHUD:SetCameraOverride()
  JavCameraControllerRequestBus.Broadcast.SetCameraLookAt(self.lookAtPos, true)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_FishCaught", 0.3)
  self.cameraOverriden = true
end
function FishingHUD:ClearCameraOverride()
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
  JavCameraControllerRequestBus.Broadcast.ClearCameraLookAt()
  self.cameraOverriden = false
end
function FishingHUD:ToggleBaitWindow()
  self.isShowingBaitSelection = not self.isShowingBaitSelection
  if self.isShowingBaitSelection then
    self.vitalsNotificationHandler = self:BusConnect(VitalsComponentNotificationBus, self.vitalsId)
    self.actionHandler2 = self:BusConnect(CryActionNotificationsBus, self.exitBaitWindowAction)
    UiElementBus.Event.SetIsEnabled(self.Properties.BaitSelectionContainer, true)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.BaitSelectionContainer, 0.3, {opacity = 0, y = -10}, tweenerCommon.baitWindowShow)
    self.ScriptedEntityTweener:PlayC(self.Properties.PromptsContainer, 0.3, tweenerCommon.fadeOutQuadOut)
  else
    self:BusDisconnect(self.vitalsNotificationHandler)
    self:BusDisconnect(self.actionHandler2)
    self.actionHandler2 = nil
    self.ScriptedEntityTweener:PlayFromC(self.Properties.BaitSelectionContainer, 0.1, {opacity = 1, y = 0}, tweenerCommon.baitWindowHide, 0, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.BaitSelectionContainer, false)
    end)
    self.ScriptedEntityTweener:PlayC(self.Properties.PromptsContainer, 0.1, tweenerCommon.fadeInQuadOut, 0.3)
  end
  if self.isShowingBaitSelection then
    self.inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    if not self.inventoryId then
      return
    end
    local baitId = FishingRequestsBus.Event.GetCurrentBait(self.playerEntityId)
    local numSlots = ContainerRequestBus.Event.GetNumSlots(self.inventoryId) or 0
    if baitId == 0 then
      UiElementBus.Event.SetIsEnabled(self.Properties.SelectedIcon, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.NoBaitSelected, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.BaitHighlight, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.BaitName, "@ui_fishing_nobait", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.BaitBenefit, "@ui_fishing_nobait_description", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetColor(self.Properties.BaitBenefit, self.UIStyle.COLOR_TAN)
      UiImageBus.Event.SetSpritePathname(self.Properties.SelectedIconBg, self.noBaitIconBgPath)
      self.selectedBait = nil
    end
    local freshWaterListData = {}
    local saltWaterListData = {}
    for i = 1, numSlots do
      local slotId = i - 1
      local slot = ContainerRequestBus.Event.GetSlotRef(self.inventoryId, slotId)
      if slot and slot:IsValid() and slot:HasItemClass(eItemClass_Bait) then
        local itemDescriptor = slot:GetItemDescriptor()
        local baitData = FishingRequestsBus.Event.GetBaitData(self.playerEntityId, itemDescriptor.itemId)
        local tableToInsert = freshWaterListData
        if baitData.requiredWaterTag == 2415649015 then
          tableToInsert = saltWaterListData
        end
        table.insert(tableToInsert, {
          callbackSelf = self,
          callbackFunction = self.OnBaitPressed,
          itemDescriptor = itemDescriptor
        })
        if itemDescriptor.itemId == baitId then
          local itemdata = StaticItemDataManager:GetItem(baitId)
          local itemDescription = itemdata.description
          UiElementBus.Event.SetIsEnabled(self.Properties.NoBaitSelected, false)
          UiImageBus.Event.SetSpritePathname(self.Properties.SelectedIcon, self.ItemPrototype.item.mIconPathRoot .. itemdata.itemType .. "/" .. itemdata.icon .. ".dds")
          UiTextBus.Event.SetTextWithFlags(self.Properties.BaitName, itemDescriptor:GetDisplayName(), eUiTextSet_SetLocalized)
          UiTextBus.Event.SetTextWithFlags(self.Properties.BaitBenefit, itemDescription, eUiTextSet_SetLocalized)
          UiTextBus.Event.SetColor(self.Properties.BaitBenefit, self.UIStyle.COLOR_TEAL)
          UiImageBus.Event.SetSpritePathname(self.Properties.SelectedIconBg, self.selectedIconBgPath)
        end
      end
    end
    self.FreshWaterBaitGrid:OnListDataSet(freshWaterListData)
    self.SaltWaterBaitGrid:OnListDataSet(saltWaterListData)
    UiElementBus.Event.SetIsEnabled(self.Properties.FreshWaterBaitHeader, 0 < #freshWaterListData)
    UiElementBus.Event.SetIsEnabled(self.Properties.SaltWaterBaitHeader, 0 < #saltWaterListData)
    if 0 < #freshWaterListData then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.FreshWaterBaitHeader, self.defaultYPosition)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.FreshWaterBaitGrid, self.defaultYPosition + self.spacingBetweenHeader)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.SaltWaterBaitHeader, self.defaultYPosition + self.yOffset)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.SaltWaterBaitGrid, self.defaultYPosition + self.yOffset + self.spacingBetweenHeader)
    else
      UiTransformBus.Event.SetLocalPositionY(self.Properties.FreshWaterBaitHeader, self.defaultYPosition + self.yOffset)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.FreshWaterBaitGrid, self.defaultYPosition + self.yOffset + self.spacingBetweenHeader)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.SaltWaterBaitHeader, self.defaultYPosition)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.SaltWaterBaitGrid, self.defaultYPosition + self.spacingBetweenHeader)
    end
    LyShineManagerBus.Broadcast.AddMouseOwner(self.canvasId)
  else
    FishingRequestsBus.Event.RequestCloseBaitBox(self.playerEntityId)
    LyShineManagerBus.Broadcast.RemoveMouseOwner(self.canvasId)
  end
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(not self.isShowingBaitSelection)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("default", not self.isShowingBaitSelection)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("player", not self.isShowingBaitSelection)
  UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", self.isShowingBaitSelection)
end
function FishingHUD:OnDamage(attackerEntityId, healthPercentageLost, positionOfAttack, damageAngle, isSelfDamage, damageByType, isFromStatusEffect, cancelTargetHoming)
  if healthPercentageLost < GetEpsilon() then
    return
  end
  if positionOfAttack ~= nil then
    self:OnEscapePressed()
  end
end
function FishingHUD:OnEscapePressed()
  if self.state == eFishingState_ApplyingBait or self.isShowingBaitSelection then
    self:ToggleBaitWindow()
  end
end
function FishingHUD:OnCancelPressed()
  self:ToggleBaitWindow()
end
function FishingHUD:OnNoBaitPressed()
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedIcon, false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BaitName, "@ui_fishing_nobait", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BaitBenefit, "@ui_fishing_nobait_description", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.BaitBenefit, self.UIStyle.COLOR_TAN)
  UiImageBus.Event.SetSpritePathname(self.Properties.SelectedIconBg, self.noBaitIconBgPath)
  UiElementBus.Event.SetIsEnabled(self.Properties.NoBaitSelected, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.BaitHighlight, false)
  self.selectedBait = nil
end
function FishingHUD:OnBaitPressed(entity)
  if entity and entity ~= self.selectedBait then
    self.selectedBait = entity
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedIcon, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.BaitName, entity.mItemData_itemDescriptor:GetDisplayName(), eUiTextSet_SetLocalized)
    local staticItemData = StaticItemDataManager:GetItem(entity.mItemData_itemDescriptor.itemId)
    local itemDescription = staticItemData.description
    UiTextBus.Event.SetTextWithFlags(self.Properties.BaitBenefit, itemDescription, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.BaitBenefit, self.UIStyle.COLOR_TEAL)
    UiImageBus.Event.SetSpritePathname(self.Properties.SelectedIcon, entity.mIconPathRoot .. entity.mItemData_itemType .. "/" .. entity.mItemData_iconPath .. ".dds")
    UiImageBus.Event.SetSpritePathname(self.Properties.SelectedIconBg, self.noBaitIconBgPath)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoBaitSelected, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.BaitHighlight, true)
    UiElementBus.Event.Reparent(self.Properties.BaitHighlight, entity.entityId, EntityId())
  end
end
function FishingHUD:OnApplyBaitPressed()
  local id = 0
  if self.selectedBait then
    id = self.selectedBait.itemId
  end
  FishingRequestsBus.Event.RequestApplyBait(self.playerEntityId, id)
  self:UpdateBait(id)
  self:ToggleBaitWindow()
end
function FishingHUD:UpdateBobberPosition()
  if not self.bobberPosition then
    return
  end
  local screenPos = LyShineManagerBus.Broadcast.ProjectToScreen(self.bobberPosition, false, false)
  local clampValueX = self.bobberClamp * 0.5
  screenPos.x = Clamp(screenPos.x, clampValueX, self.resolution.x - clampValueX)
  screenPos.y = Clamp(screenPos.y, self.bobberClamp, self.resolution.y)
  screenPos.x = screenPos.x * self.scale.x
  screenPos.y = screenPos.y * self.scale.y - self.offsetFromBobber
  UiTransformBus.Event.SetLocalPositionX(self.Properties.BobberContainer, screenPos.x)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.BobberContainer, screenPos.y)
end
function FishingHUD:SetState(state)
  if self.state == state then
    return
  end
  if self.state == nil and state > eFishingState_FishNibbleWindowOpen and state < eFishingState_Succeeded_FishCaught then
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberContainer, 0.3, tweenerCommon.fadeInQuadOut)
    if state > eFishingState_HookHit then
      self.ScriptedEntityTweener:PlayC(self.Properties.TensionContainer, 0.2, tweenerCommon.fadeInQuadOut)
    end
  end
  self.state = state
  if self.cameraOverriden then
    self:ClearCameraOverride()
  end
  if state == eFishingState_Unequipped then
    self:OnTransitionOut()
  elseif state == eFishingState_Equipped then
    self.CastHint:SetActionMap("player")
    self.CastHint:SetKeybindMapping("fishing_primary")
    self.BobberHint:SetActionMap("player")
    self.BobberHint:SetKeybindMapping("fishing_primary")
    self.BaitHint:SetActionMap("ui")
    self.BaitHint:SetKeybindMapping(self.toggleFishingBaitWindowAction)
    self.ExitHint:SetActionMap("player")
    self.ExitHint:SetKeybindMapping("fishing_activate")
    local gatheringEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GatheringEntityId")
    local tool = UiGatheringComponentRequestsBus.Event.GetValidGatheringToolList(gatheringEntityId, "Fishing")
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    local isAtItemCapacity = ContainerRequestBus.Event.IsAtItemCapacity(inventoryId)
    local hasItem = tool and tool:IsValid()
    local canGather = hasItem and not isAtItemCapacity
    UiElementBus.Event.SetIsEnabled(self.Properties.CastHint, canGather)
    UiElementBus.Event.SetIsEnabled(self.Properties.CastActionText, canGather)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoToolEquippedText, not canGather)
    self.ScriptedEntityTweener:PlayC(self.Properties.CastContainer, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BaitContainer, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.ExitContainer, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.CastBarContainer, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberContainer, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.TensionContainer, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.PromptsContainer, 0.3, tweenerCommon.fadeInQuadOut)
    self.bobberTimeline:Stop()
    if self.actionHandler1 == nil then
      self.actionHandler1 = self:BusConnect(CryActionNotificationsBus, self.toggleFishingBaitWindowAction)
    end
    if #self.cryActionHandlers == 0 then
      self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "cam_zoom_in")
      self.cryActionHandlers[#self.cryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, "cam_zoom_out")
    end
    UiTextBus.Event.SetText(self.Properties.IndicatorText, "")
    self:UpdateBait(FishingRequestsBus.Event.GetCurrentBait(self.playerEntityId))
    self.ScriptedEntityTweener:PlayC(self.Properties.RedPulse, 0, tweenerCommon.scaleTo0)
  elseif state == eFishingState_ApplyingBait then
    if not self.isShowingBaitSelection then
      self:ToggleBaitWindow()
    end
  elseif state == eFishingState_CastStart then
    self:BusDisconnect(self.actionHandler1)
    self.actionHandler1 = nil
    self.ScriptedEntityTweener:PlayC(self.Properties.PromptsContainer, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BaitContainer, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.CastContainer, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.ExitContainer, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.CastBarContainer, 0.3, tweenerCommon.fadeInQuadOut)
    UiElementBus.Event.SetIsEnabled(self.Properties.BobberIcon, false)
    self.lookAtPos = FishingRequestsBus.Event.GetJointPositionWithOffset(self.playerEntityId, "left_hand_attach", 0.7)
    self.lookAtPos.x = self.lookAtPos.x + 0.1
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ForceHideReticle", true)
  elseif state == eFishingState_CastEnd then
    local playMaxEffect = false
    if self.distance ~= nil then
      if self.distance == 0 then
        UiTextBus.Event.SetTextWithFlags(self.Properties.IndicatorText, "@ui_fishing_short", eUiTextSet_SetLocalized)
        AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Play_UI_Fishg_Cast_Short")
        playMaxEffect = false
      elseif self.distance > 99 then
        UiTextBus.Event.SetTextWithFlags(self.Properties.IndicatorText, "@ui_fishing_max", eUiTextSet_SetLocalized)
        AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Play_UI_Fishg_Cast_Max")
        playMaxEffect = true
        UiTransformBus.Event.SetLocalPositionY(self.Properties.PowerIndicator, -self.castingBarHeight)
      elseif 0 < self.distance and self.distance < 50 then
        UiTextBus.Event.SetTextWithFlags(self.Properties.IndicatorText, "@ui_fishing_short", eUiTextSet_SetLocalized)
        AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Play_UI_Fishg_Cast_Short")
        playMaxEffect = false
      elseif self.distance >= 50 and self.distance <= 99 then
        UiTextBus.Event.SetTextWithFlags(self.Properties.IndicatorText, "@ui_fishing_medium", eUiTextSet_SetLocalized)
        AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.playerEntityId, "Play_UI_Fishg_Cast_Med")
        playMaxEffect = false
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.ReleaseEffectSmall, not playMaxEffect)
    UiElementBus.Event.SetIsEnabled(self.Properties.ReleaseEffectBigVertical, playMaxEffect)
    UiElementBus.Event.SetIsEnabled(self.Properties.ReleaseEffectBigHorizontal, playMaxEffect)
    UiElementBus.Event.SetIsEnabled(self.Properties.ReleaseEffectBigCenter, playMaxEffect)
    if playMaxEffect then
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectBigHorizontal, 0.05, {scaleX = 0, opacity = 0}, tweenerCommon.releaseEffect1, 0)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectBigHorizontal, 0.3, {scaleX = 1}, tweenerCommon.releaseEffect2, 0.1)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectBigHorizontal, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.1)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectBigVertical, 0.05, {scaleX = 0, opacity = 0}, tweenerCommon.releaseEffect1, 0)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectBigVertical, 0.3, {scaleX = 1}, tweenerCommon.releaseEffect2, 0.1)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectBigVertical, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.1)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectBigCenter, 0.05, {opacity = 0}, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectBigCenter, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.3)
      UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceHorizontal, 0)
      UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceHorizontal)
      UiElementBus.Event.SetIsEnabled(self.Properties.SequenceHorizontal, true)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.SequenceHorizontal, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.6)
      UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceVertical, 0)
      UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceVertical)
      UiElementBus.Event.SetIsEnabled(self.Properties.SequenceVertical, true)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.SequenceVertical, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.6)
      UiTextBus.Event.SetColor(self.Properties.IndicatorText, self.UIStyle.COLOR_YELLOW_LIGHT)
      UiTextBus.Event.SetFontSize(self.Properties.IndicatorText, 32)
    else
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectSmall, 0.05, {scaleX = 0, opacity = 0}, tweenerCommon.releaseEffect1, 0)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectSmall, 0.2, {scaleX = 1}, tweenerCommon.releaseEffect2, 0.1)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReleaseEffectSmall, 0.2, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.1)
      UiTextBus.Event.SetColor(self.Properties.IndicatorText, self.UIStyle.COLOR_WHITE)
      UiTextBus.Event.SetFontSize(self.Properties.IndicatorText, 24)
    end
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PowerNode, 0.05, {scaleX = 1, scaleY = 1}, tweenerCommon.powerNode1, 0)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PowerNode, 0.1, {scaleX = 0.9, scaleY = 0.9}, tweenerCommon.powerNode2, 0.05)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PowerNode, 0.1, {
      scaleX = 1.3,
      scaleY = 1.2,
      opacity = 1
    }, tweenerCommon.powerNode3, 0.3)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PowerNodeHighlight, 0.05, {opacity = 0}, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PowerNodeHighlight, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.2)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.IndicatorText, 0.5, {x = -20, opacity = 1}, tweenerCommon.indicatorHide, 0.1)
    self.ScriptedEntityTweener:PlayC(self.Properties.CastBarContainer, 0.3, tweenerCommon.fadeOutQuadOut, 0.4)
  elseif state == eFishingState_FishingStarted then
    self.maxDistance = FishingRequestsBus.Event.GetMaxDistance(self.playerEntityId)
    local depthText = ""
    if FishingRequestsBus.Event.IsBobberInHotspot(self.playerEntityId) then
      depthText = "@ui_landed_hotspot"
      UiTextBus.Event.SetColor(self.Properties.DepthText, self.UIStyle.COLOR_GREEN_LIGHT)
    else
      local depth = FishingRequestsBus.Event.GetBobberWaterType(self.playerEntityId)
      if depth == eFishingWaterType_FreshWater_VeryShallow or depth == eFishingWaterType_SaltWater_VeryShallow then
        depthText = "@ui_fishing_very_shallow"
      elseif depth == eFishingWaterType_FreshWater_Shallow or depth == eFishingWaterType_SaltWater_Shallow then
        depthText = "@ui_fishing_shallow"
      elseif depth == eFishingWaterType_FreshWater_Deep or depth == eFishingWaterType_SaltWater_Deep then
        depthText = "@ui_fishing_deep"
      end
      UiTextBus.Event.SetColor(self.Properties.DepthText, self.UIStyle.COLOR_WHITE)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.DepthText, depthText, eUiTextSet_SetLocalized)
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberContainer, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberFill, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.HookIcon, 0.1, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberHint, 0, tweenerCommon.fadeOutQuadOut)
    UiElementBus.Event.SetIsEnabled(self.Properties.BobberIcon, true)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.InnerBobberContainer, 0.4, {y = 10, opacity = 0}, tweenerCommon.innerBobberShow, 0.5)
    UiImageBus.Event.SetSpritePathname(self.Properties.BobberBg, self.bobberBgPath)
    local bobberDistance = self.maxDistance - 1
    UiTextBus.Event.SetText(self.Properties.BobberDistanceText, string.format("%.1fm", bobberDistance))
    self.ScriptedEntityTweener:PlayFromC(self.Properties.BobberDistanceText, 0.5, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 1.8)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.DepthText, 0.5, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 1.8)
    if not self.actionMapDisabled then
      self.actionMapDisabled = true
      UIInputRequestsBus.Broadcast.EnableInputFilter("LockMenus", true)
      DynamicBus.ChatBus.Broadcast.ForceUseWidget(true)
    end
  elseif state == eFishingState_FishNibbleWindowOpen then
    self.bobberTimeline:Play()
    self.ScriptedEntityTweener:PlayC(self.Properties.GetReadyText, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.GetReadyText, 0.3, tweenerCommon.fadeOutQuadOut, 1.5)
  elseif state == eFishingState_FishBiteWindowOpen then
    self.bobberTimeline:Stop()
    self.ScriptedEntityTweener:PlayC(self.Properties.GetReadyText, 0.1, tweenerCommon.fadeOutQuadOut)
    UiTextBus.Event.SetTextWithFlags(self.Properties.HookText, "@ui_fishing_hook", eUiTextSet_SetLocalized)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.BobberHint, 42)
    local hookTextSize = UiTextBus.Event.GetTextSize(self.Properties.HookText).x
    local hookTextWidth = hookTextSize + 100
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.HookTextBg, hookTextWidth)
    self.ScriptedEntityTweener:PlayC(self.Properties.InnerBobberContainer, 0.1, tweenerCommon.yTo0)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.InnerBobberContainer, 0.05, {scaleX = 1, scaleY = 1}, tweenerCommon.bobberPulse)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.InnerBobberContainer, 0.15, {scaleX = 1.2, scaleY = 1.2}, tweenerCommon.scaleTo1, 0.1)
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberFill, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.HookIcon, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberHint, 0.2, tweenerCommon.fadeInQuadOut)
    UiElementBus.Event.SetIsEnabled(self.Properties.BobberIcon, false)
    UiImageBus.Event.SetSpritePathname(self.Properties.HookIcon, self.hookIconImagePath)
    self.hookTimer = FishingRequestsBus.Event.GetHookDuration(self.playerEntityId)
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  elseif state == eFishingState_HookHit then
    self.ScriptedEntityTweener:PlayC(self.Properties.TensionDistance, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberFill, 0.05, tweenerCommon.fadeOutQuadOut)
    UiTextBus.Event.SetTextWithFlags(self.Properties.HookText, "@ui_fishing_reel", eUiTextSet_SetLocalized)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.BobberHint, 54)
    local hookTextSize = UiTextBus.Event.GetTextSize(self.Properties.HookText).x
    local hookTextWidth = hookTextSize + 100
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.HookTextBg, hookTextWidth)
    UiImageBus.Event.SetSpritePathname(self.Properties.HookIcon, self.checkmarkImagePath)
    self.ScriptedEntityTweener:PlayC(self.Properties.HookIcon, 0.3, tweenerCommon.fadeOutQuadOut, 0.7)
    TimingUtils:Delay(0.7, self, function()
      UiImageBus.Event.SetSpritePathname(self.Properties.BobberBg, self.tensionMeterBgPath)
      self.ScriptedEntityTweener:PlayC(self.Properties.TensionContainer, 0.2, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.TensionText, 0.3, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.TensionTextBg, 0.3, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.TensionText, 0.3, tweenerCommon.fadeOutQuadOut, 1.5)
      self.ScriptedEntityTweener:PlayC(self.Properties.TensionTextBg, 0.3, tweenerCommon.fadeOutQuadOut, 1.5)
    end)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.InnerBobberContainer, 0.05, {scaleX = 1, scaleY = 1}, tweenerCommon.bobberPulse)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.InnerBobberContainer, 0.15, {scaleX = 1.2, scaleY = 1.2}, tweenerCommon.scaleTo1, 0.1)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Pulse1, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.Pulse1)
    UiElementBus.Event.SetIsEnabled(self.Properties.Pulse1, true)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.Pulse1, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.5)
  elseif state == eFishingState_Succeeded_FishCaught then
    self.ScriptedEntityTweener:PlayC(self.Properties.BobberContainer, 0.3, tweenerCommon.fadeOutQuadOut)
    UiElementBus.Event.SetIsEnabled(self.Properties.SuccessContainer, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceLight, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceLight)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceLight, true)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.SequenceLight, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.8)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.SuccessText, 1, {opacity = 0}, tweenerCommon.fadeInQuadOut, 0.4)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.SuccessText, 5, {textCharacterSpace = 150}, tweenerCommon.successText, 0, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.SuccessContainer, false)
    end)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.SuccessText, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 1)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.SuccessEffect, 1, {opacity = 0, scaleX = 0}, tweenerCommon.scaleEffect1)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.SuccessEffect, 1, {scaleX = 1}, tweenerCommon.scaleEffect2)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.SuccessEffect, 0.3, {opacity = 1}, tweenerCommon.fadeOutQuadOut, 0.7)
    self.ScriptedEntityTweener:PlayC(self.Properties.PromptsContainer, 0.3, tweenerCommon.fadeInQuadOut, 1)
    local zoomCameraOnSuccess = FishingRequestsBus.Event.GetZoomCameraOnSuccess(self.playerEntityId)
    if zoomCameraOnSuccess then
      self:SetCameraOverride()
    end
  elseif state == eFishingState_FishingEnded then
    if self.isShowingBaitSelection then
      self:ToggleBaitWindow()
    end
    self.ScriptedEntityTweener:PlayC(self.Properties.GetReadyText, 0.1, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.RedPulse, 0.1, tweenerCommon.fadeOutQuadOut)
    self.bobberHintFadedOut = false
    self.pulseStarted = false
    self.bobberTimeline:Stop()
    if self.actionMapDisabled then
      self.actionMapDisabled = false
      UIInputRequestsBus.Broadcast.EnableInputFilter("LockMenus", false)
      DynamicBus.ChatBus.Broadcast.ForceUseWidget(false)
    end
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ForceHideReticle", false)
  end
end
function FishingHUD:OnTick(deltaTime, timePoint)
  if self.state == eFishingState_FishBiteWindowOpen then
    self.hookTimer = self.hookTimer - deltaTime
    if self.hookTimer < 0 then
      self:BusDisconnect(self.tickHandler)
    end
    local perc = self.hookTimer / FishingRequestsBus.Event.GetHookDuration(self.playerEntityId)
    UiImageBus.Event.SetFillAmount(self.Properties.BobberFill, perc)
    self:UpdateFillColor(perc)
  end
end
function FishingHUD:UpdateBait(baitId)
  if baitId == 0 then
    UiElementBus.Event.SetIsEnabled(self.Properties.BaitSelected, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoBaitIcon, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.BaitActionText, "@ui_fishing_attach_bait", eUiTextSet_SetLocalized)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.BaitSelected, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoBaitIcon, false)
    self.BaitSelected:SetItemByName(baitId)
    UiTextBus.Event.SetTextWithFlags(self.Properties.BaitActionText, "@ui_fishing_change_bait", eUiTextSet_SetLocalized)
  end
  local textSize = UiTextBus.Event.GetTextSize(self.Properties.BaitActionText).x
  local textWidth = textSize + 100
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.BaitBg, textWidth)
end
function FishingHUD:UpdateFillColor(percentage)
  if 0.75 < percentage then
    UiImageBus.Event.SetColor(self.Properties.BobberFill, self.UIStyle.COLOR_GREEN_BRIGHT)
  elseif 0.5 < percentage then
    UiImageBus.Event.SetColor(self.Properties.BobberFill, self.UIStyle.COLOR_YELLOW_GOLD)
  elseif 0.25 < percentage then
    UiImageBus.Event.SetColor(self.Properties.BobberFill, self.UIStyle.COLOR_ORANGE_BRIGHT)
  else
    UiImageBus.Event.SetColor(self.Properties.BobberFill, self.UIStyle.COLOR_RED)
  end
end
function FishingHUD:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    if self.actionHandler1 then
      self:BusDisconnect(self.actionHandler1)
      self.actionHandler1 = nil
    end
    return
  end
  self:SetState(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.fishing.state"))
end
function FishingHUD:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.screenStatesToDisable[fromState] and not self.screenStatesToDisable[toState] then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    if self.state == eFishingState_Equipped then
      self.actionHandler1 = self:BusConnect(CryActionNotificationsBus, self.toggleFishingBaitWindowAction)
    end
    return
  end
  for _, handler in ipairs(self.cryActionHandlers) do
    self:BusDisconnect(handler)
  end
  ClearTable(self.cryActionHandlers)
  self.ScriptedEntityTweener:PlayC(self.Properties.CastContainer, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.BaitContainer, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.ExitContainer, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.CastBarContainer, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.BobberContainer, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.TensionContainer, 0.3, tweenerCommon.fadeOutQuadOut)
  self:BusDisconnect(self.actionHandler1)
  self.actionHandler1 = nil
  self:BusDisconnect(self.actionHandler2)
  self.actionHandler2 = nil
  if self.state == eFishingState_ApplyingBait or self.isShowingBaitSelection then
    self:ToggleBaitWindow()
  end
  if self.cameraOverriden then
    self:ClearCameraOverride()
  end
  FishingRequestsBus.Event.RequestApplyBait(self.playerEntityId, 0)
  self:UpdateBait(0)
  self.selectedBait = nil
  self.state = nil
end
function FishingHUD:NoBaitButtonHoverStart()
  self.ScriptedEntityTweener:PlayC(self.Properties.NoBaitButtonHover, 0.2, tweenerCommon.fadeInQuadOut)
  self.NoBaitTooltip:OnTooltipSetterHoverStart()
end
function FishingHUD:NoBaitButtonHoverEnd()
  self.ScriptedEntityTweener:PlayC(self.Properties.NoBaitButtonHover, 0.2, tweenerCommon.fadeOutQuadOut)
  self.NoBaitTooltip:OnTooltipSetterHoverEnd()
end
function FishingHUD:SetVisualElements()
  SetTextStyle(self.Properties.CastActionText, self.UIStyle.FONT_STYLE_FISHING_ACTION_TEXT)
  SetTextStyle(self.Properties.NoToolEquippedText, self.UIStyle.FONT_STYLE_FISHING_ACTION_TEXT)
  SetTextStyle(self.Properties.BaitActionText, self.UIStyle.FONT_STYLE_FISHING_ACTION_TEXT)
  SetTextStyle(self.Properties.ExitActionText, self.UIStyle.FONT_STYLE_FISHING_ACTION_TEXT)
  SetTextStyle(self.Properties.IndicatorText, self.UIStyle.FONT_STYLE_FISHING_INDICATOR_TEXT)
  SetTextStyle(self.Properties.HookText, self.UIStyle.FONT_STYLE_FISHING_BOBBER_ACTION)
  SetTextStyle(self.Properties.GetReadyText, self.UIStyle.FONT_STYLE_FISHING_BOBBER_ACTION)
  SetTextStyle(self.Properties.BobberDistanceText, self.UIStyle.FONT_STYLE_FISHING_DISTANCE_TEXT)
  SetTextStyle(self.Properties.DepthText, self.UIStyle.FONT_STYLE_FISHING_DEPTH_TEXT)
  SetTextStyle(self.Properties.TensionText, self.UIStyle.FONT_STYLE_FISHING_TENSION)
  SetTextStyle(self.Properties.TensionDistance, self.UIStyle.FONT_STYLE_FISHING_TENSION_DISTANCE)
  SetTextStyle(self.Properties.BaitName, self.UIStyle.FONT_STYLE_FISHING_BAIT_NAME)
  SetTextStyle(self.Properties.BaitBenefit, self.UIStyle.FONT_STYLE_FISHING_BAIT_BENEFIT)
  SetTextStyle(self.Properties.SuccessText, self.UIStyle.FONT_STYLE_FISHING_SUCCESS)
end
function FishingHUD:OnShutdown()
  self.pulseTimeline:Stop()
  self.bobberTimeline:Stop()
end
return FishingHUD
