local LocalizedItemSearch = {}
function LocalizedItemSearch:Reset()
  self.allItems = nil
  self.lastSearchResults = nil
  self.lastSearchTerm = nil
  self.lastSearchLanguage = nil
  self.localizedNames = nil
end
function LocalizedItemSearch:Search(termIn, sorted)
  local term = string.lower(termIn)
  local language = LyShineScriptBindRequestBus.Broadcast.GetLanguage()
  if not self.allItems or language ~= self.lastSearchLanguage then
    self.allItems = ItemDataManagerBus.Broadcast.GetFilteredItemList("", "", "", "")
    self.localizedNames = {}
    for k = 1, #self.allItems do
      local itemData = self.allItems[k]
      self.localizedNames[itemData.key] = string.lower(LyShineScriptBindRequestBus.Broadcast.LocalizeText(itemData.displayName))
    end
    self.lastSearchTerm = nil
    self.lastSearchResults = nil
  end
  local itemsToSearch = self.allItems
  if self.lastSearchTerm and string.len(self.lastSearchTerm) > string.len(term) and string.sub(term, 1, string.len(self.lastSearchTerm)) == self.lastSearchTerm then
    itemsToSearch = self.lastSearchResults
  end
  local newSearchResults = {}
  self.lastSearchResults = {}
  for k = 1, #itemsToSearch do
    local item = itemsToSearch[k]
    local name = self.localizedNames[item.key]
    local start = string.find(name, term, 1, true)
    if start then
      newSearchResults[#newSearchResults + 1] = item
      self.lastSearchResults[#self.lastSearchResults + 1] = item
    end
  end
  self.lastSearchTerm = term
  self.lastSearchLanguage = language
  if sorted then
    table.sort(newSearchResults, function(a, b)
      local aName = self.localizedNames[a.key]
      local bName = self.localizedNames[b.key]
      if aName == bName then
        return a.tier < b.tier
      else
        return aName < bName
      end
    end)
  end
  return newSearchResults
end
return LocalizedItemSearch
