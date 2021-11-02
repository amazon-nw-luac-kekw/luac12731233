local ContractBrowser_PerkSelectionPopup = {
  Properties = {
    FrameHeader = {
      default = EntityId()
    },
    PerksGrid = {
      default = EntityId()
    },
    PerksGridBg = {
      default = EntityId()
    },
    PerksGridPrototype = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    },
    SelectionsContainer = {
      default = EntityId()
    },
    SelectionNoneText = {
      default = EntityId()
    },
    Selection1 = {
      default = EntityId()
    },
    Selection2 = {
      default = EntityId()
    },
    Selection3 = {
      default = EntityId()
    },
    Selection4 = {
      default = EntityId()
    },
    Selection5 = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_PerkSelectionPopup)
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function ContractBrowser_PerkSelectionPopup:OnInit()
  BaseElement.OnInit(self)
  self.selections = {
    self.Selection1,
    self.Selection2,
    self.Selection3,
    self.Selection4,
    self.Selection5
  }
  for i = 1, #self.selections do
    self.selections[i]:SetCallbacks(nil, self.OnRemoveSelection, self)
  end
  self.PerksGrid:Initialize(self.PerksGridPrototype)
  self.PerksGrid:OnListDataSet(nil)
  self.CloseButton:SetCallback(self.OnClose, self)
  UiFaderBus.Event.SetFadeValue(self.Properties.ScreenScrim, self.UIStyle.BACKGROUND_ALPHA)
  SetTextStyle(self.Properties.SelectionNoneText, self.UIStyle.FONT_STYLE_BODY_NEW)
end
function ContractBrowser_PerkSelectionPopup:SetPerkSelectionPopupData(data)
  self.callbackFunction = data.callbackFunction
  self.callbackSelf = data.callbackSelf
  self.isSelectingGem = data.isSelectingGem
  self.isMultiSelect = data.isMultiSelect
  self.showSelected = data.showSelected
  self.selectedGem = data.selectedGem
  self.restoreHeader = data.restoreHeader
  if data.isMultiSelect then
    self.selectedPerks = data.selectedPerks
    self.maxPerks = data.maxPerks or 3
  end
  local headerText = data.isSelectingGem and "@ui_select_gem" or "@ui_select_perk"
  self.FrameHeader:SetText(headerText)
  local height = data.showSelected and 682 or 758
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.PerksGridBg, height)
  height = data.showSelected and 662 or 738
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.PerksGrid, height)
  self:UpdateSelectionsContainer()
  self.perksList = {}
  local possiblePerks
  if data.showAllPerks then
    if data.isSelectingGem then
      possiblePerks = ItemDataManagerBus.Broadcast.GetGemPerkIds()
    else
      possiblePerks = ItemDataManagerBus.Broadcast.GetNonGemPerkIds()
    end
  else
    possiblePerks = ItemDataManagerBus.Broadcast.GetPerksForItemClass(data.itemId)
  end
  for i = 1, #possiblePerks do
    local perkId = possiblePerks[i]
    local isCompatible = data.itemId and ItemDataManagerBus.Broadcast.IsPerkCompatibleWithItemClass(perkId, data.itemId)
    if isCompatible or data.showAllPerks then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData:IsValid() then
        local isValidChannel = data.isSelectingGem or data.maxPerkChannel and perkData.channel <= data.maxPerkChannel
        local isEmptyGemSlot = perkId == itemCommon.EMPTY_GEM_SLOT_PERK_ID
        local isCorrectType = false
        if data.isSelectingGem then
          isCorrectType = perkData.perkType == ePerkType_Gem and not isEmptyGemSlot
        else
          isCorrectType = perkData.perkType ~= ePerkType_Gem
        end
        local isSelected = false
        if data.isSelectingGem then
          isSelected = perkId == data.selectedGem
        else
          isSelected = data.selectedPerks[perkId] ~= nil
        end
        local isVisible = data.showAllPerks and not isEmptyGemSlot or isCorrectType and isValidChannel and (not isSelected or data.showSelected)
        local isDisabled = data.itemId ~= nil and (not isCompatible or not isValidChannel or not isCorrectType)
        if isVisible then
          local listData = {
            localizedName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(perkData.displayName),
            perkId = perkId,
            isSelectingGem = data.isSelectingGem,
            isDisabled = isDisabled,
            isSelected = isSelected,
            callbackFunction = self.OnPerkSelected,
            callbackSelf = self
          }
          if #perkData.groupName > 0 then
            listData.localizedGroupName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(perkData.groupName)
            listData.tier = perkData.tier
          end
          if listData.localizedName ~= "" then
            table.insert(self.perksList, listData)
          end
        end
      end
    end
  end
  table.sort(self.perksList, function(a, b)
    if a.localizedGroupName and b.localizedGroupName then
      if a.localizedGroupName ~= b.localizedGroupName then
        return a.localizedGroupName:lower() < b.localizedGroupName:lower()
      end
      return a.tier < b.tier
    end
    return a.localizedName:lower() < b.localizedName:lower()
  end)
  if data.isSelectingGem then
    local isSelected = data.selectedGem == itemCommon.EMPTY_GEM_SLOT_PERK_ID and data.showSelected
    table.insert(self.perksList, 1, {
      perkId = itemCommon.EMPTY_GEM_SLOT_PERK_ID,
      isSelectingGem = data.isSelectingGem,
      isSelected = isSelected,
      callbackFunction = self.OnPerkSelected,
      callbackSelf = self
    })
  end
  if not data.hideAny then
    table.insert(self.perksList, 1, {
      perkId = 0,
      isSelectingGem = data.isSelectingGem,
      callbackFunction = self.OnPerkSelected,
      callbackSelf = self
    })
  end
  self.PerksGrid:OnListDataSet(self.perksList)
  self:SetPerkSelectionPopupVisibility(true)
end
function ContractBrowser_PerkSelectionPopup:SetPerkSelectionPopupVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
    DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(true)
    DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(true)
  else
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.15, tweenerCommon.fadeOutQuadIn, nil, function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end)
    if self.restoreHeader then
      DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(false)
      DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(false)
    end
  end
end
function ContractBrowser_PerkSelectionPopup:IsVisible()
  return self.isVisible
end
function ContractBrowser_PerkSelectionPopup:UpdateSelectionsContainer()
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectionsContainer, self.showSelected)
  if not self.showSelected then
    return
  end
  local selectionIndex = 1
  if self.isSelectingGem then
    if self.selectedGem then
      local selection = self.selections[selectionIndex]
      selection:SetPerkSelectorData(self.selectedGem)
      UiElementBus.Event.SetIsEnabled(selection.entityId, true)
      selectionIndex = selectionIndex + 1
    end
  else
    for perkId, _ in pairs(self.selectedPerks) do
      local selection = self.selections[selectionIndex]
      selection:SetPerkSelectorData(perkId)
      UiElementBus.Event.SetIsEnabled(selection.entityId, true)
      selectionIndex = selectionIndex + 1
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectionNoneText, selectionIndex == 1)
  local maxSelections = #self.selections
  if selectionIndex <= maxSelections then
    for i = selectionIndex, maxSelections do
      UiElementBus.Event.SetIsEnabled(self.selections[i].entityId, false)
    end
  end
end
function ContractBrowser_PerkSelectionPopup:ExecuteCallback(perkId)
  if self.callbackFunction then
    self.callbackFunction(self.callbackSelf, self.isSelectingGem, perkId)
  end
end
function ContractBrowser_PerkSelectionPopup:OnPerkSelected(entityTable)
  if self.isMultiSelect then
    if entityTable.isSelected then
      self.selectedPerks[entityTable.perkId] = nil
    else
      local numSelected = CountAssociativeTable(self.selectedPerks)
      if numSelected == self.maxPerks then
        PopupWrapper:RequestPopup(ePopupButtons_OK, "@ui_max_perk_popup_title", "@ui_max_perk_popup_message", "ReachedMaxPerkPopupId")
        return
      end
      if 0 < numSelected then
        local newPerkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(entityTable.perkId)
        for selectedPerkId, _ in pairs(self.selectedPerks) do
          local selectedPerkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(selectedPerkId)
          if selectedPerkData:HasExclusiveLabel(newPerkData.exclusiveLabels) then
            local message = GetLocalizedReplacementText("@ui_exclusive_perk_popup_message_no_replace", {
              newPerkName = newPerkData.displayName,
              selectedPerkName = selectedPerkData.displayName
            })
            PopupWrapper:RequestPopup(ePopupButtons_OK, "@ui_exclusive_perk_popup_title", message, "ExclusivePerkPopupId")
            return
          end
        end
      end
      self.selectedPerks[entityTable.perkId] = true
    end
    for i = 1, #self.perksList do
      local listData = self.perksList[i]
      if listData.perkId == entityTable.perkId then
        listData.isSelected = not entityTable.isSelected
        break
      end
    end
    local skipScrollToTop = true
    self.PerksGrid:OnListDataSet(self.perksList, nil, skipScrollToTop)
    self:UpdateSelectionsContainer()
  else
    self:ExecuteCallback(entityTable.perkId)
  end
end
function ContractBrowser_PerkSelectionPopup:OnRemoveSelection(perkSelector)
  if self.isMultiSelect and self.selectedPerks[perkSelector.perkId] then
    self.selectedPerks[perkSelector.perkId] = nil
    for i = 1, #self.perksList do
      local listData = self.perksList[i]
      if listData.perkId == perkSelector.perkId then
        listData.isSelected = false
        break
      end
    end
    local skipScrollToTop = true
    self.PerksGrid:OnListDataSet(self.perksList, nil, skipScrollToTop)
    self:UpdateSelectionsContainer()
  else
    self:ExecuteCallback()
  end
end
function ContractBrowser_PerkSelectionPopup:OnClose()
  if self.isMultiSelect then
    self:ExecuteCallback()
  else
    self:SetPerkSelectionPopupVisibility(false)
  end
end
function ContractBrowser_PerkSelectionPopup:OnScrimClicked()
  self:OnClose()
end
return ContractBrowser_PerkSelectionPopup
