local TerritoryPlanning_RecurringProjectsPanel = {
  Properties = {
    AvailableBuffsList = {
      default = EntityId()
    },
    UpgradeItemPrototype = {
      default = EntityId()
    },
    ActivatedBuffsList = {
      default = EntityId()
    },
    ActivatedItemPrototype = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_RecurringProjectsPanel)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function TerritoryPlanning_RecurringProjectsPanel:OnInit()
  BaseElement.OnInit(self)
  self.rowTypes = {
    header = {
      name = "header",
      maxItems = 1,
      jumpable = true
    },
    project = {
      name = "project",
      maxItems = 20,
      jumpable = false
    }
  }
  self.AvailableBuffsList:Initialize(self.UpgradeItemPrototype, self.rowTypes)
  self.ActivatedBuffsList:Initialize(self.ActivatedItemPrototype)
end
function TerritoryPlanning_RecurringProjectsPanel:SetActiveProjectData(activeBuffs)
  self.ActivatedBuffsList:OnListDataSet(activeBuffs)
end
function TerritoryPlanning_RecurringProjectsPanel:SetUpgradeData(projects)
  local categoriesToProjects = {}
  local activeProjects = {}
  local now = timeHelpers:ServerNow()
  for i = 1, #projects do
    local projectData = projects[i]
    if not categoriesToProjects[projectData[1].projectSubCategory] then
      categoriesToProjects[projectData[1].projectSubCategory] = {}
    end
    table.insert(categoriesToProjects[projectData[1].projectSubCategory], projectData)
  end
  self.listData = {}
  for category, projectList in pairs(categoriesToProjects) do
    table.insert(self.listData, {
      rowType = self.rowTypes.header,
      categoryData = category
    })
    for i = 1, #projectList do
      local projectData = projectList[i]
      table.insert(self.listData, {
        rowType = self.rowTypes.project,
        projectData = projectData
      })
      local projectDataTable = projectData[#projectData]
      if projectDataTable:IsComplete() then
        local totalDurationSec = projectDataTable.lifestyleBuffEffectDuration
        local endTime = projectDataTable:GetLifestyleEndTime()
        local remainingDurSec = endTime:Subtract(now):ToSeconds()
        table.insert(activeProjects, {
          image = projectDataTable.projectIcon,
          title = projectDataTable.projectTitle,
          buttonLabel = projectDataTable.projectButtonLabel,
          remainingDurSec = remainingDurSec,
          totalDurationSec = totalDurationSec
        })
      end
    end
  end
  self.AvailableBuffsList:OnListDataSet(self.listData)
  self:SetActiveProjectData(activeProjects)
end
return TerritoryPlanning_RecurringProjectsPanel
