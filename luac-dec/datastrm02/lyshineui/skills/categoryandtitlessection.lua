local CategoryAndTitlesSection = {
  Properties = {
    CategoryTitleSectionHeader = {
      default = EntityId()
    },
    TitlesGrid = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CategoryAndTitlesSection)
function CategoryAndTitlesSection:OnInit()
  BaseElement.OnInit(self)
  self.categoryTitleSectionHeaderHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.CategoryTitleSectionHeader)
  self.titleItemHeight = UiLayoutGridBus.Event.GetCellSize(self.TitlesGrid).y
  self.titlesGridPadding = UiLayoutGridBus.Event.GetPadding(self.TitlesGrid)
  self.titlesGridSpacing = UiLayoutGridBus.Event.GetSpacing(self.TitlesGrid)
  self.CategoryTitleSectionHeader:SetTextStyle(self.UIStyle.FONT_STYLE_TITLES_SECTION_HEADER)
end
function CategoryAndTitlesSection:SetUpSize(totalTitles, isNoTitle)
  if isNoTitle then
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.titleItemHeight + self.titlesGridPadding.top)
  else
    local numRows = math.ceil(totalTitles / 3)
    local newHeight = self.categoryTitleSectionHeaderHeight + self.titlesGridPadding.top + numRows * self.titleItemHeight + self.titlesGridSpacing.y * (numRows - 1)
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, newHeight)
  end
end
function CategoryAndTitlesSection:SetData(titleIdLists, categoryData, allTitleListData, allMetaAchievementListData, currentPronounType, currentTitle, selectedTitle, onClickedCallback, onClickedCallbackTable)
  if categoryData == nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.CategoryTitleSectionHeader, false)
    UiTransform2dBus.Event.SetOffsets(self.TitlesGrid, UiOffsets(0, 0, 0, 0))
    UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.TitlesGrid, 1)
    local id = UiElementBus.Event.GetChild(self.Properties.TitlesGrid, 0)
    local entityTable = self.registrar:GetEntityTable(id)
    local noTitleTitleId = 2140143823
    entityTable:SetData(nil, nil, currentPronounType, false, currentTitle == noTitleTitleId, selectedTitle == noTitleTitleId, onClickedCallback, onClickedCallbackTable)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.CategoryTitleSectionHeader, true)
    self.CategoryTitleSectionHeader:SetText(categoryData.title, false)
    UiTransform2dBus.Event.SetOffsets(self.TitlesGrid, UiOffsets(0, self.categoryTitleSectionHeaderHeight, 0, 0))
    local newTitleIds = titleIdLists.newTitleIds
    local oldTitleIds = titleIdLists.oldTitleIds
    local numNewTitles = newTitleIds ~= nil and #newTitleIds or 0
    local numOldTitles = oldTitleIds ~= nil and #oldTitleIds or 0
    local totalTitles = numNewTitles + numOldTitles
    if totalTitles ~= 0 then
      UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.TitlesGrid, totalTitles)
      local childElements = UiElementBus.Event.GetChildren(self.Properties.TitlesGrid)
      for i = 1, #childElements do
        local id = childElements[i]
        local entityTable = self.registrar:GetEntityTable(id)
        local titleId, isNew
        if i > numNewTitles then
          titleId = oldTitleIds[i - numNewTitles]
          isNew = false
        else
          titleId = newTitleIds[i]
          isNew = true
        end
        local data = allTitleListData[titleId]
        local metaAchievementData
        if data ~= nil and data.metaAchievementIds ~= nil and #data.metaAchievementIds ~= 0 then
          local metaAchievementId = data.metaAchievementIds[1]
          metaAchievementData = allMetaAchievementListData[metaAchievementId]
        end
        entityTable:SetData(data, metaAchievementData, currentPronounType, isNew, currentTitle == titleId, selectedTitle == titleId, onClickedCallback, onClickedCallbackTable)
      end
    end
  end
end
return CategoryAndTitlesSection
