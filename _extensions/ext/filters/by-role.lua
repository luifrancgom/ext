-- roles.lua
-- Builds a 'by-role' structure the same way quarto-cli's authors.lua
-- builds 'by-affiliation' from 'by-author', so that templates can use
-- $if(by-role/first)$ ... $for(by-role)$ ... $endfor$ with the same
-- Pandoc syntax already used for $if(by-affiliation/first)$.
--
-- Modeled on:
-- ~/Documents/quarto-cli/src/resources/filters/modules/authors.lua
-- it uses the source code of quarto-cli
-- the logic was created by the developers of quarto-cli at posit
-- See https://github.com/quarto-dev/quarto-cli/blob/v1.11.1/src/resources/filters/modules/authors.lua

-- Where Quarto's own authors.lua filter writes the 'by-author' list
-- (already expanded with roles/affiliations inline per author)
local kByAuthor = "by-author"

-- Where we'll write the 'by-role' list of roles which includes
-- expanded author information inline with each role
local kByRole = "by-role"

-- Properties that may appear on an individual role
local kRoles = "roles"
local kRole = "role"

-- This field will be included with 'by-role', mirroring the
-- 'number'/'letter' fields authors.lua attaches to 'by-author'
-- and 'by-affiliation'
local kAuthors = "authors"
local kId = "id"
local kNumber = "number"
local kLetter = "letter"

-- Deep Copy a table
local function deepCopy(original)
  local copy = {}
  for k, v in pairs(original) do
    if type(v) == "table" then
      v = deepCopy(v)
    end
    copy[k] = v
  end
  return copy
end

-- Get a letter for a number
local function letter(number)
  number = number%26
  return string.char(96 + number)
end

-- Finds a matching role by comparing role text (ignoring the id)
local function findMatchingRole(role, roles)
  for i, existingRole in ipairs(roles) do
    if role[kRole] == existingRole[kRole] then
      return existingRole
    end
  end
  return nil
end

-- Add a role to the list of roles if needed, and return either the
-- existing role, or the newly added role with a proper id
local function maybeAddRole(role, roles)
  local existingRole = findMatchingRole(role, roles)
  if existingRole == nil then
    local roleNumber = #roles + 1
    role[kId] = "role-" .. roleNumber
    roles[roleNumber] = role
    return role
  else
    return existingRole
  end
end

-- Finds every author that has a matching role by id
local function findRoleAuthors(id, authors)
  local matchingAuthors = {}
  for i, author in ipairs(authors) do
    local authorRoles = author[kRoles]
    if authorRoles then
      for j, authorRole in ipairs(authorRoles) do
        if authorRole[kId] == id then -- simpler than in findAffiliationAuthors from authors.lua
          matchingAuthors[#matchingAuthors + 1] = author
        end
      end
    end
  end
  return matchingAuthors
end

-- Builds the 'by-role' list of roles which includes expanded author
-- information inline with each role
local function byRoles(authors, roles)
  local denormalizedRoles = deepCopy(roles)
  for i, role in ipairs(denormalizedRoles) do
    local roleAuthors = findRoleAuthors(role[kId], authors)
    if roleAuthors then
      role[kAuthors] = roleAuthors
    end
  end
  return denormalizedRoles
end

function Meta(meta)
  local authors = meta[kByAuthor]
  local roles = {}

  -- collect the distinct roles across all authors, tagging each
  -- author's role entry with the id of its normalized role
  if authors then
    for i, author in ipairs(authors) do
      local authorRoles = author[kRoles]
      if authorRoles then
        for j, role in ipairs(authorRoles) do
          local addedRole = maybeAddRole(role, roles)
          role[kId] = addedRole[kId]
        end
      end
    end
  end

  -- number the roles, the same way authors.lua numbers authors/affiliations
  for i, role in ipairs(roles) do
    role[kNumber] = i
    role[kLetter] = letter(i)
  end

  -- write the de-normalized 'by-role' list back to metadata
  if authors and #roles ~= 0 then
    meta[kByRole] = byRoles(authors, roles)
  end

  return meta
end
