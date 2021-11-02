local InventoryFilter = {}
function InventoryFilter:ParseFilterText(text)
  ClearTable(self.optionalTerms)
  ClearTable(self.requiredTerms)
  ClearTable(self.excludedTerms)
  self.minGearScore = 0
  self.minTier = 0
  local terms = StringSplit(text, " ")
  for k, term in ipairs(terms) do
    term = string.lower(term)
    if 0 < string.len(term) then
      local firstChar = string.sub(term, 1, 1)
      local num = tonumber(term) or 0
      if term == "inf" then
        num = 0
      end
      if firstChar == "+" then
        if string.len(term) > 1 then
          table.insert(self.requiredTerms, string.sub(term, 2))
        end
      elseif firstChar == "-" then
        if string.len(term) > 1 then
          table.insert(self.excludedTerms, string.sub(term, 2))
        end
      elseif 0 < num then
        self.minGearScore = num
      elseif firstChar == "t" and 0 < (tonumber(string.sub(term, 2)) or 0) then
        self.minTier = tonumber(string.sub(term, 2)) or 0
      else
        table.insert(self.optionalTerms, term)
      end
    end
  end
  self.version = self.version + 1
end
function InventoryFilter:SetSortBy(sortBy)
  self.sortBy = sortBy
  self.version = self.version + 1
end
function InventoryFilter:IsInFilter(itemDef)
  if not itemDef.displayName then
    local localizedText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(itemDef.itemDescriptor:GetItemDisplayName())
    itemDef.displayName = string.lower(localizedText)
  end
  if not itemDef.gearScore then
    itemDef.gearScore = itemDef.itemDescriptor:GetGearScore()
  end
  if #self.optionalTerms > 0 then
    local inFilter = false
    for i, term in ipairs(self.optionalTerms) do
      if string.find(itemDef.displayName, term, 1, true) then
        inFilter = true
        break
      end
    end
    if not inFilter then
      return false
    end
  end
  if 0 < #self.requiredTerms then
    for i, term in ipairs(self.requiredTerms) do
      if not string.find(itemDef.displayName, term, 1, true) then
        return false
      end
    end
  end
  if 0 < #self.excludedTerms then
    for i, term in ipairs(self.excludedTerms) do
      if string.find(itemDef.displayName, term, 1, true) then
        return false
      end
    end
  end
  if itemDef.gearScore < self.minGearScore then
    return false
  end
  if itemDef.tier < self.minTier then
    return false
  end
  return true
end
function InventoryFilter:FilterAndSortItemDefs(itemDefs)
  local unfilteredCount = 0
  for k, itemDef in pairs(itemDefs) do
    itemDef.isInFilter = self:IsInFilter(itemDef)
    if itemDef.isInFilter then
      unfilteredCount = unfilteredCount + 1
    end
  end
  table.sort(itemDefs, function(a, b)
    if a.isContainer ~= b.isContainer then
      return a.isContainer and not b.isContainer
    end
    if self.sortBy == self.SORT_BY_GEARSCORE and a.gearScore ~= b.gearScore then
      return a.gearScore > b.gearScore
    end
    if self.sortBy == self.SORT_BY_TIER and a.tier ~= b.tier then
      return a.tier > b.tier
    end
    if self.sortBy == self.SORT_BY_WEIGHT and a.weight ~= b.weight then
      return a.weight > b.weight
    end
    return a.chrono > b.chrono
  end)
  return unfilteredCount
end
function InventoryFilter:IsClear()
  return self.minGearScore == 0 and self.minTier == 0 and #self.optionalTerms == 0 and #self.requiredTerms == 0 and #self.excludedTerms == 0
end
function InventoryFilter.new()
  local o = {
    SORT_BY_CHRONO = 1,
    SORT_BY_WEIGHT = 2,
    SORT_BY_GEARSCORE = 3,
    SORT_BY_TIER = 4,
    sortBy = 1,
    optionalTerms = {},
    requiredTerms = {},
    excludedTerms = {},
    minGearScore = 0,
    minTier = 0,
    version = 0
  }
  o.ParseFilterText = InventoryFilter.ParseFilterText
  o.SetSortBy = InventoryFilter.SetSortBy
  o.IsInFilter = InventoryFilter.IsInFilter
  o.FilterAndSortItemDefs = InventoryFilter.FilterAndSortItemDefs
  o.IsClear = InventoryFilter.IsClear
  return o
end
return InventoryFilter
