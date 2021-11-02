local MetaAchievementsTreeRow = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    CompletedTotalCount = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    RowBg = {
      default = EntityId()
    },
    SelectedBg = {
      default = EntityId()
    }
  },
  expandedArrow = "LyShineUI/Images/Icons/Misc/dropdownArrowWhite.dds",
  collapsedArrow = "LyShineUI/Images/Icons/Misc/dropdownArrowWhiteRight.dds",
  summaryIcon = "LyShineUI/Images/Icons/Housing/icon_housing_category_all.dds",
  completedIcon = "LyShineUI/Images/SocialPane/socialPane_accept_symbol.dds",
  childRow = false,
  expanded = false
}
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
BaseElement:CreateNewElement(MetaAchievementsTreeRow)
function MetaAchievementsTreeRow:OnInit()
  BaseElement.OnInit(self)
end
function MetaAchievementsTreeRow:SetTreeRowData(id, treeRowData, onClickedCallback, onClickedCallbackTable)
  self.id = id
  self.treeRowData = treeRowData
  self.onClickedCallback = onClickedCallback
  self.onClickedCallbackTable = onClickedCallbackTable
  UiElementBus.Event.SetIsEnabled(self.entityId, self.treeRowData ~= nil)
  self.ScriptedEntityTweener:Set(self.Properties.Highlight, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RowBg, {opacity = 0})
  if self.treeRowData.itemData.parentCategory ~= 0 then
    self.childRow = true
    UiElementBus.Event.SetIsEnabled(self.Properties.Icon, false)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Title, 40)
    SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_TREE_CHILD)
    UiElementBus.Event.SetIsEnabled(self.Properties.CompletedTotalCount, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Icon, true)
    if self.id == 3458754147 then
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.summaryIcon)
      UiElementBus.Event.SetIsEnabled(self.Properties.CompletedTotalCount, false)
    elseif self.id == 181160428 then
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.completedIcon)
      UiElementBus.Event.SetIsEnabled(self.Properties.CompletedTotalCount, false)
    else
      self.expanded = self.treeRowData.expanded
      self.childRow = false
      if treeRowData.hasChildren then
        local expandedIcon = self.expanded and self.expandedArrow or self.collapsedArrow
        UiImageBus.Event.SetSpritePathname(self.Properties.Icon, expandedIcon)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.Icon, false)
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.CompletedTotalCount, true)
    end
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Title, 30)
    SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_TREE_PARENT)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, self.treeRowData.itemData.title, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.CompletedTotalCount, string.format("%d / %d", self.treeRowData.completedCount, self.treeRowData.totalCount))
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedBg, self.treeRowData.selected)
  if self.treeRowData.selected then
    self.ScriptedEntityTweener:Play(self.Properties.SelectedBg, 0.15, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.SelectedBg, 0.15, {opacity = 0, ease = "QuadOut"})
  end
end
function MetaAchievementsTreeRow:OnClicked()
  if self.onClickedCallback ~= nil and type(self.onClickedCallback) == "function" then
    self.onClickedCallback(self.onClickedCallbackTable, self.id)
  end
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.3, {opacity = 0.2}, {opacity = 0, ease = "QuadOut"})
  local audio
  if not self.childRow then
    if self.expanded then
      audio = self.audioHelper.MetaAchievements_List_Collapse
    else
      audio = self.audioHelper.MetaAchievements_List_Expand
    end
  end
  self.audioHelper:PlaySound(audio)
end
function MetaAchievementsTreeRow:OnFocus()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.15, {opacity = 0.1, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.MetaAchievements_List_Hover)
end
function MetaAchievementsTreeRow:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.15, {opacity = 0, ease = "QuadIn"})
end
return MetaAchievementsTreeRow
