local HousingManagement = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    AbandonHomeButton = {
      default = EntityId()
    },
    PayPropertyTaxButton = {
      default = EntityId()
    },
    NoDiscount = {
      Container = {
        default = EntityId()
      },
      TaxDueText = {
        default = EntityId()
      }
    },
    Discount = {
      Container = {
        default = EntityId()
      },
      Normal = {
        default = EntityId()
      },
      Discounted = {
        default = EntityId()
      },
      Percent = {
        default = EntityId()
      }
    },
    TaxDueLabel = {
      default = EntityId()
    },
    TaxBg = {
      default = EntityId()
    },
    TimeRemaining = {
      default = EntityId()
    },
    OverdueDescription = {
      default = EntityId()
    },
    RemainingTimeLabel = {
      default = EntityId()
    },
    TaxDescription = {
      default = EntityId()
    },
    LineLeft = {
      default = EntityId()
    },
    LineRight = {
      default = EntityId()
    },
    LineTop = {
      default = EntityId()
    },
    LineBottom = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    BackgroundContainer = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    DecorateEnabledText = {
      default = EntityId()
    },
    FastTravelEnabledText = {
      default = EntityId()
    },
    TrophyEnabledText = {
      default = EntityId()
    },
    TimeString = {
      default = EntityId()
    }
  },
  abandonPopupId = "abandonHouseFromHousingManagement",
  payTaxPopupId = "payPropertyTaxFromManagement",
  payTaxSuccessPopup = "payTaxSuccessPopup",
  timeBeforeTaxesCanBePaidTotalSec = nil,
  isTimeBeforeDueUpdated = false,
  isTimeDueUpdated = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(HousingManagement)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function HousingManagement:OnInit()
  BaseScreen.OnInit(self)
  self.LineTop:SetLength(965)
  self.LineBottom:SetLength(965)
  self.LineLeft:SetLength(862)
  self.LineRight:SetLength(862)
  self.Divider:SetLength(965)
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.BackgroundContainer, {opacity = 0})
  self.PayPropertyTaxButton:SetButtonStyle(self.PayPropertyTaxButton.BUTTON_STYLE_CTA)
  self.AbandonHomeButton:SetButtonStyle(self.AbandonHomeButton.BUTTON_STYLE_DEFAULT)
  self.PayPropertyTaxButton:SetText("@ui_pay_property_tax")
  self.PayPropertyTaxButton:SetCallback(self.OnRequestPayPropertyTaxPopup, self)
  self.AbandonHomeButton:SetText("@ui_abandon")
  self.AbandonHomeButton:SetCallback(self.OnAbandonHomeButton, self)
  self.ScreenHeader:SetText("@ui_house_menu")
  self.ScreenHeader:SetHintCallback(self.OnHomeBackButton, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  DynamicBus.HousingManagement.Connect(self.entityId, self)
end
function HousingManagement:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.HousingManagement.Disconnect(self.entityId, self)
end
function HousingManagement:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_HousingTaxScreen", 0.5)
  self.ScriptedEntityTweener:PlayC(self.entityId, 0.5, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.BackgroundContainer, 0.5, tweenerCommon.fadeInQuadOut)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 4
  self.targetDOFBlur = 0.5
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 0.5,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  self.LineTop:SetVisible(true, 1.2, {delay = 0.35})
  self.LineLeft:SetVisible(true, 1.2, {delay = 0.35})
  self.LineBottom:SetVisible(true, 1.2, {delay = 0.35})
  self.LineRight:SetVisible(true, 1.2, {delay = 0.35})
  self.Divider:SetVisible(true, 1.2, {delay = 0.35})
  local guildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  local isPartOfOwningGuild = guildId and guildId ~= 0 and territoryId and TerritoryDataHandler:GetGoverningGuildId(territoryId) == guildId
  UiElementBus.Event.SetIsEnabled(self.Properties.NoDiscount.Container, not isPartOfOwningGuild)
  UiElementBus.Event.SetIsEnabled(self.Properties.Discount.Container, isPartOfOwningGuild)
  if isPartOfOwningGuild then
    local baseTaxesDue = PlayerHousingClientRequestBus.Broadcast.GetAdjustedTaxAmountForEnteredPlotOptionalCompanyDiscount(false)
    local baseTaxesDueText = GetLocalizedReplacementText("@ui_coin_icon", {
      coin = GetLocalizedCurrency(baseTaxesDue)
    })
    UiTextBus.Event.SetText(self.Properties.Discount.Normal, baseTaxesDueText)
    local finalTaxesDue = PlayerHousingClientRequestBus.Broadcast.GetAdjustedTaxAmountForEnteredPlot()
    local finalTaxesDueText = GetLocalizedReplacementText("@ui_coin_icon", {
      coin = GetLocalizedCurrency(finalTaxesDue)
    })
    UiTextBus.Event.SetText(self.Properties.Discount.Discounted, finalTaxesDueText)
    local owningGuildTaxCostModifier = LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyTaxModifier()
    local discountedPricePercent = GetLocalizedReplacementText("@ui_company_discount", {
      discountPercent = string.format("%d", math.floor(owningGuildTaxCostModifier * 100 + 0.5))
    })
    UiTextBus.Event.SetText(self.Properties.Discount.Percent, discountedPricePercent)
  else
    local taxesDue = PlayerHousingClientRequestBus.Broadcast.GetAdjustedTaxAmountForEnteredPlot()
    local taxesDueText = GetLocalizedReplacementText("@ui_coin_icon", {
      coin = GetLocalizedCurrency(taxesDue)
    })
    UiTextBus.Event.SetText(self.Properties.NoDiscount.TaxDueText, taxesDueText)
  end
  self.isTimeBeforeDueUpdated = false
  self.isTimeDueUpdated = false
  self:UpdateButtonAndTimer()
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function HousingManagement:UpdateButtonAndTimer()
  self.hasUnpaidTaxes = PlayerHousingClientRequestBus.Broadcast.GetHouseHasUnpaidTaxes()
  local enabledText = "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_GREEN_DARK) .. ">" .. "@ui_housing_enabled" .. "</font>"
  local disabledText = "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_RED_MEDIUM) .. ">" .. "@ui_housing_disabled" .. "</font>"
  local decorateEnabledText = self.hasUnpaidTaxes and disabledText or enabledText
  local fastTravelEnabledText = self.hasUnpaidTaxes and disabledText or enabledText
  local trophyEnabledText = self.hasUnpaidTaxes and disabledText or enabledText
  local taxDueLabel = self.hasUnpaidTaxes and "@ui_house_unpaid_taxes" or "@ui_property_tax_due"
  local taxDueLabelColor = self.hasUnpaidTaxes and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_GRAY_60
  local taxDescription = self.hasUnpaidTaxes and "@ui_house_overdue_desc" or "@ui_property_tax_desc"
  local taxDescriptionColor = self.hasUnpaidTaxes and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_GRAY_60
  local remainingTimeLabel = self.hasUnpaidTaxes and "@ui_house_overdue_label" or "@ui_due_in"
  UiTextBus.Event.SetTextWithFlags(self.Properties.DecorateEnabledText, decorateEnabledText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.FastTravelEnabledText, fastTravelEnabledText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TrophyEnabledText, trophyEnabledText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TaxDueLabel, taxDueLabel, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RemainingTimeLabel, remainingTimeLabel, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TaxDescription, taxDescription, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.TaxDueLabel, taxDueLabelColor)
  UiTextBus.Event.SetColor(self.Properties.TaxDescription, taxDescriptionColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.TimeString, not self.hasUnpaidTaxes)
  UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemaining, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RemainingTimeLabel, not self.hasUnpaidTaxes)
  local canPayTaxes = false
  local replicatedHouseData = PlayerHousingClientRequestBus.Broadcast.GetMyPhasedHousingPlotData()
  if replicatedHouseData then
    local taxesDueInSec = replicatedHouseData.taxesDue:Subtract(timeHelpers:ServerNow()):ToSeconds()
    local timeRemainingSeconds = math.max(taxesDueInSec, 0)
    local timeStringText = timeHelpers:ConvertToTwoLargestTimeEstimate(timeRemainingSeconds)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeString, timeStringText, eUiTextSet_SetLocalized)
    self.TimeRemaining:SetTimeSeconds(timeRemainingSeconds, true)
    self.timeBeforeTaxesCanBePaidTotalSec = PlayerHousingClientRequestBus.Broadcast.GetTimeBeforeTaxesCanBePaidSeconds()
    self.isTimeBeforeDueUpdated = timeRemainingSeconds <= self.timeBeforeTaxesCanBePaidTotalSec
    self.isTimeDueUpdated = taxesDueInSec < 0
    local canPayTaxesInSec = math.max(taxesDueInSec - self.timeBeforeTaxesCanBePaidTotalSec, 0)
    canPayTaxes = PlayerHousingClientRequestBus.Broadcast.IsTimeToPayTaxes()
    self.PayPropertyTaxButton:SetText(canPayTaxes and "@ui_pay_property_tax" or GetLocalizedReplacementText("@ui_cant_pay_property_tax", {
      time = timeHelpers:ConvertToLargestTimeEstimate(canPayTaxesInSec, false)
    }))
  end
  self.PayPropertyTaxButton:SetEnabled(canPayTaxes)
end
function HousingManagement:OnTick()
  local replicatedHouseData = PlayerHousingClientRequestBus.Broadcast.GetMyPhasedHousingPlotData()
  if replicatedHouseData then
    local taxesDueInSec = replicatedHouseData.taxesDue:Subtract(timeHelpers:ServerNow()):ToSeconds()
    local timeRemainingSeconds = math.max(taxesDueInSec, 0)
    if not self.hasUnpaidTaxes and 0 <= timeRemainingSeconds then
      self:UpdateButtonAndTimer()
    end
  end
end
function HousingManagement:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self.ScriptedEntityTweener:PlayC(self.entityId, 0.1, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.BackgroundContainer, 0.1, tweenerCommon.fadeOutQuadOut)
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  self.LineTop:SetVisible(false, 0)
  self.LineBottom:SetVisible(false, 0)
  self.LineLeft:SetVisible(false, 0)
  self.LineRight:SetVisible(false, 0)
  self.Divider:SetVisible(false, 0)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.3)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function HousingManagement:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function HousingManagement:OnHomeBackButton()
  LyShineManagerBus.Broadcast.ExitState(2437603339)
end
function HousingManagement:OnAbandonHomeButton()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_house_abandon_this_popup_title", "@ui_house_abandon_this_popup_desc", self.abandonPopupId, self, self.OnPopupResult)
end
function HousingManagement:OnRequestPayPropertyTaxPopup(taxesDue, taxesDueTime, onPayTaxCbSelf, onPayTaxCbFunc)
  if not taxesDue or type(taxesDue) ~= "number" then
    taxesDue = PlayerHousingClientRequestBus.Broadcast.GetAdjustedTaxAmountForEnteredPlot()
  end
  if not taxesDueTime then
    local replicatedHouseData = PlayerHousingClientRequestBus.Broadcast.GetMyPhasedHousingPlotData()
    if replicatedHouseData then
      taxesDueTime = replicatedHouseData.taxesDue
    end
  end
  self.onPayTaxCbSelf = onPayTaxCbSelf
  self.onPayTaxCbFunc = onPayTaxCbFunc
  if not taxesDue or not taxesDueTime then
    Debug.Log("Error: Failed to show pay property tax popup, either taxesDue or taxesDueTime not defined")
    return
  end
  local taxesDueText = GetLocalizedReplacementText("@ui_coin_icon", {
    coin = GetLocalizedCurrency(taxesDue)
  })
  local firstCycleTime = ConfigProviderEventBus.Broadcast.GetInt("javelin.housing.duration-taxes-due-after-first-purchase")
  local laterCycleTime = ConfigProviderEventBus.Broadcast.GetInt("javelin.housing.duration-taxes-extended-after-paying")
  local taxDescription = GetLocalizedReplacementText("@ui_pay_property_tax_popup_desc", {
    firstCycle = timeHelpers:ConvertToVerboseDurationString(firstCycleTime),
    otherCycle = timeHelpers:ConvertToVerboseDurationString(laterCycleTime)
  })
  local timeRemainingSeconds = math.max(taxesDueTime:Subtract(timeHelpers:ServerNow()):ToSeconds(), 0)
  PopupWrapper:RequestPopupWithParams({
    title = "@ui_pay_property_tax",
    message = taxDescription,
    eventId = self.payTaxPopupId,
    callerSelf = self,
    callback = self.OnPopupResult,
    buttonText = "@ui_pay_property_tax",
    showCurrency = true,
    showCloseButton = true,
    additionalHeight = 30,
    closeWithOnOk = false,
    customData = {
      {
        detailType = "TextLabelAndValue",
        label = "@ui_property_tax_amount_desc",
        value = taxesDueText
      },
      {
        detailType = "RemainingTime",
        value = timeRemainingSeconds
      }
    }
  })
end
function HousingManagement:OnPopupResult(result, eventId)
  if eventId == self.abandonPopupId then
    if result ~= ePopupResult_Yes then
      return
    end
    PlayerHousingClientRequestBus.Broadcast.RequestAbandonHome()
    self:OnHomeBackButton()
    DynamicBus.FullScreenFader.Broadcast.ExecuteFadeInOut(0.3, 0.3, 0.4, self, function()
      PlayerHousingClientRequestBus.Broadcast.RequestExitPlot()
      LyShineManagerBus.Broadcast.SetState(2702338936)
    end)
  elseif eventId == self.payTaxPopupId and result == ePopupResult_OK then
    if self.onPayTaxCbSelf then
      self.onPayTaxCbFunc(self.onPayTaxCbSelf)
      return
    end
    do
      local taxesDue = PlayerHousingClientRequestBus.Broadcast.GetAdjustedTaxAmountForEnteredPlot()
      local playerWallet = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
      if taxesDue > playerWallet then
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_remote_house_payment_need_coin"
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        return
      end
      local taxesDueText = GetLocalizedReplacementText("@ui_coin_icon", {
        coin = GetLocalizedCurrency(taxesDue)
      })
      local success = PlayerHousingClientRequestBus.Broadcast.PayTaxesForEnteredPlot()
      if success then
        self.dataLayer:RegisterDataCallback(self, "Hud.Housing.OnPayTaxResponse", function(self, successResponse)
          if successResponse then
            PopupWrapper:RequestPopupWithParams({
              title = "@ui_payment_successful",
              message = "@ui_property_tax_success_desc",
              eventId = self.payTaxSuccessPopup,
              callerSelf = self,
              callback = self.OnPopupResult,
              buttonText = "@ui_close",
              customData = {
                {
                  detailType = "TextLabelAndValue",
                  label = "@ui_paid",
                  value = taxesDueText
                }
              }
            })
          else
            self:OnPayTaxFail()
          end
          self.dataLayer:UnregisterObserver(self, "Hud.Housing.OnPayTaxResponse")
          TimingUtils:DelayFrames(10, self, function()
            self:UpdateButtonAndTimer()
          end)
        end)
      else
        self:OnPayTaxFail()
      end
    end
  end
end
function HousingManagement:OnPayTaxFail()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_pay_house_tax_fail"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
return HousingManagement
