local TitleListItem = {
  Properties = {
    NewTag = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    CurrentTitleTag = {
      default = EntityId()
    },
    SelectedBg = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    }
  },
  NewTagSize = 50
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TitleListItem)
function TitleListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_TITLES_LIST_NAME)
  SetTextStyle(self.Properties.CurrentTitleTag, self.UIStyle.FONT_STYLE_TITLES_LIST_CURRENT)
  UiTextBus.Event.SetTextWithFlags(self.Properties.NewTag, "@ui_title_section_new", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTitleTag, "@ui_title_section_current_title_tag", eUiTextSet_SetLocalized)
end
function TitleListItem:SetData(data, metaAchievementData, pronounType, isNew, isCurrentTitle, isSelected, onClickedCallback, onClickedCallbackTable)
  self.onClickedCallback = onClickedCallback
  self.onClickedCallbackTable = onClickedCallbackTable
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  if isNew then
    UiElementBus.Event.SetIsEnabled(self.Properties.NewTag, true)
    UiLayoutCellBus.Event.SetTargetWidth(self.Properties.NewTag, self.NewTagSize)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NewTag, false)
    UiLayoutCellBus.Event.SetTargetWidth(self.Properties.NewTag, 0)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrentTitleTag, isCurrentTitle)
  if isSelected then
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedBg, true)
    self.ScriptedEntityTweener:Play(self.Properties.SelectedBg, 0.1, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.Title, 0.1, {
      textColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut"
    })
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedBg, false)
    self.ScriptedEntityTweener:Set(self.Properties.SelectedBg, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.Title, {
      textColor = self.UIStyle.COLOR_FLAVOR_TEXT
    })
  end
  self.data = data
  if self.data == nil then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Title, "@ui_title_section_no_title", eUiTextSet_SetLocalized)
  else
    local genderedTitle = ""
    if pronounType == ePronounType_Male then
      genderedTitle = self.data.titleMale
    elseif pronounType == ePronounType_Female then
      genderedTitle = self.data.titleFemale
    else
      genderedTitle = self.data.title
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.Title, genderedTitle, eUiTextSet_SetLocalized)
  end
  local tooltipText = "@ui_playertitle_generic_description"
  if self.data == nil then
    tooltipText = "@ui_playertitle_no_title_description"
  elseif self.data.description ~= "" then
    tooltipText = self.data.description
  elseif metaAchievementData ~= nil then
    local metaAchievementTitle = metaAchievementData.title
    local isDisplayOneIndexed = JavMetaAchievementRequestBus.Broadcast.IsDisplayOneIndexed(metaAchievementData.id)
    local metaAchievementDescription = GetLocalizedReplacementText(metaAchievementData.description, {
      number = GetLocalizedNumber(isDisplayOneIndexed and metaAchievementData.total + 1 or metaAchievementData.total)
    })
    tooltipText = GetLocalizedReplacementText("@ui_playertitle_meta_achievement_description", {title = metaAchievementTitle, description = metaAchievementDescription})
  end
  if self.data ~= nil then
    if self.data.type == eTitleType_Character then
      tooltipText = tooltipText .. "\n" .. "@ui_playertitle_addendum_charactertype"
    else
      tooltipText = tooltipText .. "\n" .. "@ui_playertitle_addendum_accounttype"
    end
  end
  self.Tooltip:SetSimpleTooltip(tooltipText)
end
function TitleListItem:OnClicked()
  if self.onClickedCallback ~= nil and type(self.onClickedCallback) == "function" then
    if self.data ~= nil then
      self.onClickedCallback(self.onClickedCallbackTable, self.data.id)
    else
      self.onClickedCallback(self.onClickedCallbackTable, 2140143823)
    end
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function TitleListItem:OnFocus()
  self.Tooltip:OnTooltipSetterHoverStart()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.1, {opacity = 1, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.MetaAchievements_List_Hover)
end
function TitleListItem:OnUnfocus()
  self.Tooltip:OnTooltipSetterHoverEnd()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.1, {opacity = 0, ease = "QuadOut"})
end
function TitleListItem:SetBackgroundEnabled(enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, enabled)
end
function TitleListItem:SetBgIndex(index)
  self.Background:SetIndex(index)
  self.Background:SetFocusGlowEnabled(false)
  self.Background:SetZebraOpacity(0.5)
  self.Background:SetListItemStyle(self.Background.LIST_ITEM_STYLE_ZEBRA)
end
return TitleListItem
