local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local PurchasesPopup = {
  Properties = {
    PopupHolder = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    PurchaseList = {
      default = EntityId()
    },
    PurchaseItemPrototype = {
      default = EntityId()
    },
    RefreshButton = {
      default = EntityId()
    },
    RefreshButtonIcon = {
      default = EntityId()
    },
    ExitButton = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    },
    DividerBottom = {
      default = EntityId()
    },
    DividerTop = {
      default = EntityId()
    },
    ButtonClose2 = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    PurchasesDescription = {
      default = EntityId()
    }
  },
  MAX_REWARDS = 8
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PurchasesPopup)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function PurchasesPopup:OnInit()
  BaseElement.OnInit(self)
  self.PurchaseList:Initialize(self.PurchaseItemPrototype)
  self.PurchaseList:OnListDataSet(nil)
  self.ExitButton:SetCallback(self.Close, self)
  self.ButtonClose2:SetText("@ui_close")
  self.ButtonClose2:SetCallback(self.Close, self)
  self.ButtonClose2:SetButtonStyle(self.ButtonClose2.BUTTON_STYLE_CTA)
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.FrameHeader:SetText("@ui_purchases_title")
  for i = 1, eRewardTypeEntitlement do
    local grants = EntitlementsDataHandler:GetAllRewardGrantsOfType(i)
  end
  self.entitlementBusHandler = self:BusConnect(EntitlementNotificationBus)
  self.currentIndex = 0
  self.seenPackages = {}
  self.newPackagesById = {}
end
function PurchasesPopup:ShowPurchasesPopup()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentState == 1643432462 then
    LyShineManagerBus.Broadcast.SetState(1634988588)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self:FillList()
  self.ScriptedEntityTweener:Play(self.Properties.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.PopupHolder, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.3
  })
  self.DividerBottom:SetVisible(true, 1.4)
  self.DividerTop:SetVisible(true, 1.4)
end
function PurchasesPopup:StopRefreshSpinning()
  self.ScriptedEntityTweener:Stop(self.Properties.RefreshButtonIcon)
  UiTransformBus.Event.SetZRotation(self.Properties.RefreshButtonIcon, 0)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, true)
end
function PurchasesPopup:OnRefreshPurchasesPress()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonIcon, 0.38, {rotation = 0}, {timesToPlay = 40, rotation = 359})
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnRefreshServerPress)
  EntitlementRequestBus.Broadcast.SyncEntitlements()
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, false)
  TimingUtils:Delay(15, self, function(self)
    self:StopRefreshSpinning()
  end)
end
function PurchasesPopup:OnRefreshFocus()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButton, 0.1, {
    scaleX = 1.1,
    scaleY = 1.1,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_LandingScreen)
end
function PurchasesPopup:OnRefreshUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButton, 0.1, {scaleX = 1, scaleY = 1})
end
function PurchasesPopup:OnEntitlementsChange()
  TimingUtils:StopDelay(self)
  self:StopRefreshSpinning()
  self:FillList()
end
function PurchasesPopup:Close()
  EntitlementRequestBus.Broadcast.MarkAllEntitlementsSeen()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentState == 1634988588 then
    LyShineManagerBus.Broadcast.ExitState(1634988588)
  end
  self.DividerBottom:SetVisible(false)
  self.DividerTop:SetVisible(false)
end
function PurchasesPopup:FillList()
  self.entitledRewards = {}
  for i = 1, eRewardTypeEntitlement - 1 do
    local grants = EntitlementsDataHandler:GetAllRewardGrantsOfType(i)
    for j, grantInfo in ipairs(grants) do
      if EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(i, grantInfo.rewardKey) then
        local line = {
          rewardType = i,
          rewardKey = grantInfo.rewardKey,
          isNew = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeNew(i, grantInfo.rewardKey),
          displayInfo = EntitlementsDataHandler:GetEntitlementDisplayInfo(i, grantInfo.rewardKey),
          grantedBy = "@entitlement_included"
        }
        if line.displayInfo.isValid then
          for k, entitlement in pairs(grantInfo.entitlements) do
            if string.len(entitlement.entitlementInfo) > 0 and EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeEntitlement, k) then
              line.grantedBy = LyShineScriptBindRequestBus.Broadcast.LocalizeText(entitlement.entitlementInfo)
              if not self.seenPackages[k] and not self.newPackagesById[k] then
                local package = {
                  key = k,
                  entitlement = entitlement,
                  rewards = {},
                  rewardsByKey = {}
                }
                if line.isNew then
                  self.newPackagesById[k] = package
                else
                  self.seenPackages[k] = package
                end
              end
              if self.newPackagesById[k] and not self.newPackagesById[k].rewardsByKey[grantInfo.rewardKey] then
                table.insert(self.newPackagesById[k].rewards, line)
                self.newPackagesById[k].rewardsByKey[grantInfo.rewardKey] = line
              end
              break
            end
          end
          table.insert(self.entitledRewards, line)
        end
      end
    end
  end
  table.sort(self.entitledRewards, function(a, b)
    return a.grantedBy < b.grantedBy
  end)
  for i = 1, #self.entitledRewards do
    self.entitledRewards[i].index = i
  end
  self.PurchaseList:OnListDataSet(self.entitledRewards)
  if not self.currentNewPackage then
    local key
    key, self.currentNewPackage = next(self.newPackagesById)
    self.currentIndex = 0
  end
  self:ShowNewPurchases()
end
function PurchasesPopup:ShowNewPurchases()
  self.ScriptedEntityTweener:Play(self.Properties.PopupHolder, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.3
  })
  self.DividerBottom:SetVisible(true, 1.4)
  self.DividerTop:SetVisible(true, 1.4)
end
return PurchasesPopup
