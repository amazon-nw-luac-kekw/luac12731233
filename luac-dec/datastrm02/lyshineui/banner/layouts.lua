local Layouts = {}
local style = RequireScript("LyShineUI._Common.UIStyle")
function Layouts:Init()
  self.layoutRows = {}
  self.layoutBackgrounds = {}
  self.layoutDisplayContainer = {}
  self.slicePaths = {}
  self.DEFAULT_DISPLAY_DURATION = 4
  self.ROW_TEXT_CARD = "TextCard"
  self.slicePaths[self.ROW_TEXT_CARD] = "LyShineUI\\Banner\\TextCard"
  self.LAYOUT_TEXT_CARD = "LAYOUT_TEXT_CARD"
  self.layoutBackgrounds[self.LAYOUT_TEXT_CARD] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_TEXT_CARD] = {
    {
      rowType = self.ROW_TEXT_CARD
    }
  }
  self.ROW_LEVEL_UP_BANNER = "BannerLevelUp"
  self.slicePaths[self.ROW_LEVEL_UP_BANNER] = "LyShineUI\\Banner\\BannerLevelUp"
  self.LAYOUT_LEVEL_UP_BANNER = "LAYOUT_LEVEL_UP_BANNER"
  self.layoutBackgrounds[self.LAYOUT_LEVEL_UP_BANNER] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_LEVEL_UP_BANNER] = {
    {
      rowType = self.ROW_LEVEL_UP_BANNER
    }
  }
  self.ROW_TERRITORY_LEVEL_UP_BANNER = "BannerTerritoryLevelUp"
  self.slicePaths[self.ROW_TERRITORY_LEVEL_UP_BANNER] = "LyShineUI\\Banner\\BannerTerritoryLevelUp"
  self.LAYOUT_TERRITORY_LEVEL_UP_BANNER = "LAYOUT_TERRITORY_LEVEL_UP_BANNER"
  self.layoutBackgrounds[self.LAYOUT_TERRITORY_LEVEL_UP_BANNER] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_TERRITORY_LEVEL_UP_BANNER] = {
    {
      rowType = self.ROW_TERRITORY_LEVEL_UP_BANNER
    }
  }
  self.WAR_BANNER_DISPLAY_DURATION = 5
  self.INVASION_BANNER_DISPLAY_DURATION = 9
  self.ROW_WAR_CARD = "WarCard"
  self.slicePaths[self.ROW_WAR_CARD] = "LyShineUI\\Banner\\WarCard"
  self.LAYOUT_WAR_CARD = "LAYOUT_WAR_CARD"
  self.layoutBackgrounds[self.LAYOUT_WAR_CARD] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_WAR_CARD] = {
    {
      rowType = self.ROW_WAR_CARD
    }
  }
  self.ROW_TERRITORY_CLAIMED = "TerritoryClaimedCard"
  self.slicePaths[self.ROW_TERRITORY_CLAIMED] = "LyShineUI\\Banner\\TerritoryClaimedCard"
  self.LAYOUT_TERRITORY_CLAIMED = "LAYOUT_TERRITORY_CLAIMED"
  self.layoutBackgrounds[self.LAYOUT_TERRITORY_CLAIMED] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_TERRITORY_CLAIMED] = {
    {
      rowType = self.ROW_TERRITORY_CLAIMED
    }
  }
  self.ROW_TERRITORY_ENTERED = "TerritoryEnteredCard"
  self.slicePaths[self.ROW_TERRITORY_ENTERED] = "LyShineUI\\Banner\\TerritoryEnteredCard"
  self.LAYOUT_TERRITORY_ENTERED = "LAYOUT_TERRITORY_ENTERED"
  self.layoutBackgrounds[self.LAYOUT_TERRITORY_ENTERED] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_TERRITORY_ENTERED] = {
    {
      rowType = self.ROW_TERRITORY_ENTERED
    }
  }
  self.LAYOUT_RESURRECT = "LAYOUT_RESURRECT"
  self.layoutBackgrounds[self.LAYOUT_RESURRECT] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_RESURRECT] = {
    {
      rowType = self.ROW_TEXT,
      textStyle = {
        fontFamily = style.FONT_FAMILY_PICA,
        fontSize = style.FONT_SIZE_BODY,
        fontColor = style.COLOR_TAN_LIGHT,
        characterSpacing = style.FONT_SPACING_HEADER
      },
      textCaps = "Upper"
    }
  }
  self.ROW_ACHIEVEMENT = "AchievementCard"
  self.slicePaths[self.ROW_ACHIEVEMENT] = "LyShineUI\\Banner\\AchievementCard"
  self.LAYOUT_ACHIEVEMENT = "LAYOUT_ACHIEVEMENT"
  self.layoutBackgrounds[self.LAYOUT_ACHIEVEMENT] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_ACHIEVEMENT] = {
    {
      rowType = self.ROW_ACHIEVEMENT
    }
  }
  self.ROW_TOWN_STRUCTURE_CHANGED = "TownStructureChanged"
  self.slicePaths[self.ROW_TOWN_STRUCTURE_CHANGED] = "LyShineUI\\Banner\\TownStructureChanged"
  self.LAYOUT_TOWN_STRUCTURE_CHANGED = "LAYOUT_TOWN_STRUCTURE_CHANGED"
  self.layoutBackgrounds[self.LAYOUT_TOWN_STRUCTURE_CHANGED] = ColorRgba(0, 0, 0, 0)
  self.layoutRows[self.LAYOUT_TOWN_STRUCTURE_CHANGED] = {
    {
      rowType = self.ROW_TOWN_STRUCTURE_CHANGED
    }
  }
end
function Layouts:GetRows(layoutName)
  return self.layoutRows[layoutName]
end
function Layouts:GetBackground(layoutName)
  return self.layoutBackgrounds[layoutName]
end
function Layouts:GetDisplayContainer(layoutName)
  return self.layoutDisplayContainer[layoutName] or "Center"
end
function Layouts:GetSlicePath(rowType)
  return self.slicePaths[rowType]
end
function CreateLayouts(table)
  table:Init()
end
CreateLayouts(Layouts)
return Layouts
