local ChangeTitleWindow = {
  Properties = {
    TitleScrollbox = {
      default = EntityId()
    },
    ApplyButton = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    FrameMultiBG = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    PronounDropdownTitle = {
      default = EntityId()
    },
    PronounDropdown = {
      default = EntityId()
    },
    CurrentTitleDescriptor = {
      default = EntityId()
    },
    CurrentSetTitle = {
      default = EntityId()
    },
    CurrentSetTitleBg = {
      default = EntityId()
    },
    RemoveCurrentTitleButton = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    }
  },
  UNINITIALIZED = -1
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local CanvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChangeTitleWindow)
function ChangeTitleWindow:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.selectedTitle = self.UNINITIALIZED
  self.newTitleIds = {}
  self.ApplyButton:SetText("@ui_title_section_apply")
  self.ApplyButton:SetCallback(self.OnApplyButtonClicked, self)
  self.ApplyButton:SetButtonStyle(self.ApplyButton.BUTTON_STYLE_CTA)
  self.CloseButton:SetCallback(self.TransitionOut, self)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.TitleScrollbox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.TitleScrollbox)
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.FrameHeader:SetText("@ui_title_section_pick_title")
  UiTextBus.Event.SetTextWithFlags(self.Properties.PronounDropdownTitle, "@ui_playertitle_pronouns_header", eUiTextSet_SetLocalized)
  self.pronounDropdownData = {
    {
      text = "@ui_playertitle_pronouns_he",
      enum = ePronounType_Male
    },
    {
      text = "@ui_playertitle_pronouns_she",
      enum = ePronounType_Female
    },
    {
      text = "@ui_playertitle_pronouns_they",
      enum = ePronounType_Neutral
    }
  }
  self.PronounDropdown:SetDropdownScreenCanvasId(self.entityId)
  self.PronounDropdown:SetListData(self.pronounDropdownData)
  self.PronounDropdown:SetCallback(self.OnPronounTypeSelected, self)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTitleDescriptor, "@ui_title_section_current_title", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.CurrentTitleDescriptor, self.UIStyle.FONT_STYLE_TITLES_CURRENT_TITLE_LABEL)
  SetTextStyle(self.Properties.CurrentSetTitle, self.UIStyle.FONT_STYLE_TITLES_CURRENT_TITLE)
  SetTextStyle(self.Properties.PronounDropdownTitle, self.UIStyle.FONT_STYLE_TITLES_PRONOUN_TITLE)
  self.PronounDropdown:SetDropdownListHeightByRows(3)
  self.initialDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
end
function ChangeTitleWindow:SetScreenVisible(isVisible)
  if isVisible then
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, CanvasCommon.POPUP_DRAW_ORDER - 1)
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 1, y = 0}, {
      opacity = 0,
      y = -10,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
        UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.initialDrawOrder)
      end
    })
  end
end
function ChangeTitleWindow:TransitionIn(currentTitle, currentPronounType, categoryToTitleIdLists, categoryOrderList, categoryIdAndDataList, allTitleListData, allMetaAchievementListData)
  self.currentTitle = currentTitle
  self.currentPronounType = currentPronounType
  self.categoryToTitleIdLists = categoryToTitleIdLists
  self.categoryOrderList = categoryOrderList
  self.categoryIdAndDataList = categoryIdAndDataList
  self.allTitleListData = allTitleListData
  self.allMetaAchievementListData = allMetaAchievementListData
  if self.currentPronounType == ePronounType_Male then
    self.PronounDropdown:SetSelectedItemData(self.pronounDropdownData[1])
  elseif self.currentPronounType == ePronounType_Female then
    self.PronounDropdown:SetSelectedItemData(self.pronounDropdownData[2])
  else
    self.PronounDropdown:SetSelectedItemData(self.pronounDropdownData[3])
  end
  self:UpdateCurrentTitleSection()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.TitleScrollbox)
  self:SetScreenVisible(true)
end
function ChangeTitleWindow:TransitionOut()
  if self.categoryToTitleIdLists ~= nil then
    for k, v in pairs(self.categoryToTitleIdLists) do
      local currentOldTitleIdList = v.oldTitleIds
      local currentNewTitleIdList = v.newTitleIds
      if currentNewTitleIdList ~= nil then
        if currentOldTitleIdList == nil then
          v.oldTitleIds = {}
          currentOldTitleIdList = v.oldTitleIds
        end
        for newIndex = 1, #currentNewTitleIdList do
          table.insert(currentOldTitleIdList, currentNewTitleIdList[newIndex])
        end
        v.newTitleIds = nil
      end
    end
  end
  self.selectedTitle = self.UNINITIALIZED
  self:SetScreenVisible(false)
end
function ChangeTitleWindow:OnPronounTypeSelected(entityId, data)
  self.currentPronounType = data.enum
  JavSocialComponentBus.Broadcast.RequestSetTitlePronounType(self.currentPronounType)
  if self.onPronounTypeChangedCallbackTable ~= nil and type(self.onPronounTypeChangedCallback) == "function" then
    self.onPronounTypeChangedCallback(self.onPronounTypeChangedCallbackTable, self.currentPronounType)
  end
  self:UpdateCurrentTitleSection()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.TitleScrollbox)
end
function ChangeTitleWindow:SetOnPronounTypeChanged(onPronounTypeChangedCallback, onPronounTypeChangedCallbackTable)
  self.onPronounTypeChangedCallback = onPronounTypeChangedCallback
  self.onPronounTypeChangedCallbackTable = onPronounTypeChangedCallbackTable
end
function ChangeTitleWindow:SetOnApplyTitleCallback(applyTitleCallback, applyTitleCallbackTable)
  self.applyTitleCallback = applyTitleCallback
  self.applyTitleCallbackTable = applyTitleCallbackTable
end
function ChangeTitleWindow:OnApplyButtonClicked()
  self:ApplyNewTitle()
  self:TransitionOut()
  self:SetScreenVisible(false)
end
function ChangeTitleWindow:ApplyNewTitle()
  if self.applyTitleCallbackTable ~= nil and type(self.applyTitleCallback) == "function" and self.selectedTitle ~= self.UNINITIALIZED then
    self.applyTitleCallback(self.applyTitleCallbackTable, self.selectedTitle)
    self.currentTitle = self.selectedTitle
    self.selectedTitle = self.UNINITIALIZED
    UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.TitleScrollbox)
  end
end
function ChangeTitleWindow:UpdateCurrentTitleSection()
  local currentTitleData = self.allTitleListData[self.currentTitle]
  if currentTitleData == nil then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentSetTitle, "@ui_title_section_no_title", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.RemoveCurrentTitleButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CurrentSetTitleBg, false)
  else
    local genderedTitle = ""
    if self.currentPronounType == ePronounType_Male then
      genderedTitle = currentTitleData.titleMale
    elseif self.currentPronounType == ePronounType_Female then
      genderedTitle = currentTitleData.titleFemale
    else
      genderedTitle = currentTitleData.title
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentSetTitle, genderedTitle, eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.RemoveCurrentTitleButton, true)
    local textSize = UiTextBus.Event.GetTextSize(self.Properties.CurrentSetTitle).x
    local textWidth = textSize + 40
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.CurrentSetTitleBg, textWidth)
    UiElementBus.Event.SetIsEnabled(self.Properties.CurrentSetTitleBg, true)
  end
end
function ChangeTitleWindow:OnRemoveCurrentTitleButtonClicked()
  self.selectedTitle = 2140143823
  self:ApplyNewTitle()
  self:UpdateCurrentTitleSection()
end
function ChangeTitleWindow:OnTitleSelected(title)
  self.selectedTitle = title
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.TitleScrollbox)
end
function ChangeTitleWindow:GetNumElements()
  return #self.categoryOrderList + 1
end
function ChangeTitleWindow:OnPrepareElementForSizeCalculation(rootEntity, index)
  local entityTable = self.registrar:GetEntityTable(rootEntity)
  if index == 0 then
    entityTable:SetUpSize(1, true)
  else
    local categoryId = self.categoryOrderList[index]
    local titleIdLists = self.categoryToTitleIdLists[categoryId]
    local numNewTitles = titleIdLists.newTitleIds ~= nil and #titleIdLists.newTitleIds or 0
    local numOldTitles = titleIdLists.oldTitleIds ~= nil and #titleIdLists.oldTitleIds or 0
    local totalTitles = numNewTitles + numOldTitles
    entityTable:SetUpSize(totalTitles, false)
  end
end
function ChangeTitleWindow:OnElementBecomingVisible(rootEntity, index)
  local entityTable = self.registrar:GetEntityTable(rootEntity)
  if index == 0 then
    entityTable:SetData(nil, nil, self.allTitleListData, self.allMetaAchievementListData, self.currentPronounType, self.currentTitle, self.selectedTitle, self.OnTitleSelected, self)
  else
    local categoryId = self.categoryOrderList[index]
    entityTable:SetData(self.categoryToTitleIdLists[categoryId], self.categoryIdAndDataList[categoryId], self.allTitleListData, self.allMetaAchievementListData, self.currentPronounType, self.currentTitle, self.selectedTitle, self.OnTitleSelected, self)
  end
end
function ChangeTitleWindow:OnHoverRemoveCurrentTitleButton()
  self.ScriptedEntityTweener:Play(self.Properties.RemoveCurrentTitleButton, 0.1, {scaleX = 1, scaleY = 1}, {
    scaleX = 1.2,
    scaleY = 1.2,
    ease = "QuadOut"
  })
end
function ChangeTitleWindow:OnUnhoverRemoveCurrentTitleButton()
  self.ScriptedEntityTweener:Play(self.Properties.RemoveCurrentTitleButton, 0.1, {scaleX = 1, scaleY = 1})
end
return ChangeTitleWindow
