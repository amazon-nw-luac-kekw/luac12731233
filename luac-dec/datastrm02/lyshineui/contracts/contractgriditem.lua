local ContractGridItem = {
  Properties = {
    ItemTier = {
      default = EntityId()
    },
    ItemIcon = {
      default = EntityId()
    },
    ItemName = {
      default = EntityId()
    },
    ItemRarityBg = {
      default = EntityId()
    },
    ItemExpiration = {
      default = EntityId()
    },
    ItemQuantity = {
      default = EntityId()
    },
    ItemCost = {
      default = EntityId()
    },
    ItemLocation = {
      default = EntityId()
    },
    InBag = {
      default = EntityId()
    },
    Button = {
      default = EntityId()
    },
    Sell = {
      ItemRaritiesList = {
        default = EntityId()
      }
    },
    MyListings = {
      SoldProgressBar = {
        default = EntityId()
      },
      StatusText = {
        default = EntityId()
      },
      StatusTextBG = {
        default = EntityId()
      }
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractGridItem)
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function ContractGridItem:OnInit()
  BaseElement.OnInit(self)
end
function ContractGridItem:OnShutdown()
end
function ContractGridItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function ContractGridItem:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function ContractGridItem:GetHorizontalSpacing()
  return 5
end
function ContractGridItem:SetGridItemData(contractData)
  UiElementBus.Event.SetIsEnabled(self.entityId, contractData ~= nil)
  if contractData then
    local itemTier = ItemDataManagerBus.Broadcast.GetTierNumber(contractData.itemId)
    local localizedTier = GetLocalizedReplacementText("@cr_tierRequired", {
      tier = GetRomanFromNumber(itemTier)
    })
    UiTextBus.Event.SetText(self.Properties.ItemTier, localizedTier)
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemIcon, contractData.iconPath)
    UiTextBus.Event.SetText(self.Properties.ItemQuantity, contractData.quantity)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, contractData.name, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetText(self.Properties.ItemCost, contractData:GetDisplayContractPrice())
    if self.Properties.ItemRarityBg:IsValid() then
      local raritySuffix = tostring(contractData.itemDescriptor:GetRarityLevel())
      local rarityImage = "lyshineui/images/slices/itemLayout/itemRarityBgLarge" .. raritySuffix .. ".png"
      UiImageBus.Event.SetSpritePathname(self.Properties.ItemRarityBg, rarityImage)
    end
    if self.Properties.InBag:IsValid() then
      local showNumInBag = contractData.numInBag and contractData.numInBag > 0
      UiElementBus.Event.SetIsEnabled(self.Properties.InBag, showNumInBag)
      if showNumInBag then
        UiTextBus.Event.SetText(self.Properties.InBag, tostring(contractData.numInBag))
      end
    end
    if self.Properties.ItemExpiration:IsValid() then
      local shouldShowExpiration = contractData.expirationSec < 10 * timeHelpers.secondsInMinute
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemExpiration, shouldShowExpiration)
      if shouldShowExpiration then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ItemExpiration, contractData.expiration, eUiTextSet_SetLocalized)
      end
    end
    if self.Properties.ItemLocation:IsValid() then
      local shouldShowLocation = contractData.contractAtThisOutpost
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemLocation, shouldShowLocation)
      if shouldShowLocation then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ItemLocation, contractData.location, eUiTextSet_SetLocalized)
      end
    end
    if self.Properties.Sell.ItemRaritiesList:IsValid() then
    end
    if self.Properties.MyListings.StatusText:IsValid() then
      local shouldShowStatus = contractData.statusEnum ~= eContractStatus_Available
      UiElementBus.Event.SetIsEnabled(self.Properties.MyListings.StatusText, shouldShowStatus)
      UiElementBus.Event.SetIsEnabled(self.Properties.MyListings.StatusTextBG, shouldShowStatus)
      if shouldShowStatus then
        UiTextBus.Event.SetTextWithFlags(self.Properties.MyListings.StatusText, contractsDataHandler:ContractStatusToString(contractData.statusEnum), eUiTextSet_SetLocalized)
      end
    end
    if self.Properties.MyListings.SoldProgressBar:IsValid() then
      local progressBarText = GetLocalizedReplacementText("@ui_number_out_of_total", {
        total = contractData.quantity,
        number = contractData.bought
      })
      self.MyListings.SoldProgressBar:SetProgressPercent(contractData.bought / contractData.quantity, progressBarText)
    end
    if self.Properties.Button:IsValid() then
      self.Button:SetCallback(contractData.callbackFn, contractData.callbackSelf)
    else
      self.callbackSelf = contractData.callbackSelf
      self.callbackFn = contractData.callbackFn
      if contractData.callbackData then
        self.callbackData = contractData.callbackData
      else
        self.callbackData = contractData
      end
    end
  else
    self.callbackSelf = nil
    self.callbackFn = nil
    self.callbackData = nil
  end
end
function ContractGridItem:OnClick()
  if self.callbackSelf then
    self.callbackFn(self.callbackSelf, self.callbackData)
  end
end
return ContractGridItem
