-- docbook.lua - Class that provides functions for working with docbook documents.
-- Copyright (C) 2015 Pavel Vomacka 
--
-- This program is free software:  you can redistribute it and/or modify it
-- under the terms of  the  GNU General Public License  as published by the
-- Free Software Foundation, version 3 of the License.
--
-- This program  is  distributed  in the hope  that it will be useful,  but
-- WITHOUT  ANY WARRANTY;  without  even the implied warranty of MERCHANTA-
-- BILITY or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
-- License for more details.
--
-- You should have received a copy of the GNU General Public License  along
-- with this program. If not, see <http://www.gnu.org/licenses/>.


-- Define the class:
docbook = {requires = {}}
docbook.__index = docbook


--
--- Constructor of the docbook class. 
--
--  @return New object. When there is some error then it returns nil.
function docbook.create(file_path)
  -- Empty object.
  local docb = {}
  
  if not path.file_exists(file_path) then  
    fail("File '" .. file_path .. "' does not exist.")
  end
  
  -- Store name file into object.
  docb.main_file = file_path
  
  -- Set metatable for new object.
  setmetatable(docb, docbook)
  
  -- Return the new object. 
  return docb
end


--
--- Creates infofile object and return it. From this object you can get
--  information which are in book(article)info tag. 
--
--  @return infofile object
function docbook:getInfoFile()
  return infofile.create(self.main_file)
end


--
--- Creates authorgroup object and return it. From this object you can get
--  information which are in authorgroup tag. 
--
--  @return infofile object
function docbook:getAuthorGroup()
  return authorgroup.create(self.main_file)
end


--
--- Creates revhistory object and return it. From this object you can get
--  information which are in revhistory tag. 
--
--  @return infofile object
function docbook:getRevhistory()
  return revhistory.create(self.main_file)
end


---------------------- WILL BE MOVED TO XML LIB -------------------------
--
--- Function that finds the entity file. 
--
--  @return path to the entity file
function docbook:findEntityFile()
  local content_dir = path.compose(self.path, self.language)
  
  -- Lists the files in language directory.
  local command = "ls " .. content_dir .. "/*.ent 2>/dev/null"
  
  -- Execute command and return the output and substitute .xml suffix for .ent.
  local result = execCaptureOutputAsString(command)
  if result ~= "" then
    return result
  end
  
  -- Return nil when there is not entity file.
  return nil
end


--
--- Function that finds any entity value in .ent file.
-- 
--  @param entityName name of entity which this function will find.
--  @return value of entity
function docbook:getEntityValue(entityName)
  
  if entityName == nil then
    return nil
  end
  
  -- Find entity file
  local ent_file = self:findEntityFile()
  
  -- Check whether entity file was found.
  if ent_file == nil then
    return nil
  end
  
  -- Compose command for parsing entity value.
  local cat = "cat "
  local grep = "grep \""
  local sed_one = "sed 's/^<!ENTITY " .. entityName:upper() .. " //'"
  local sed_two = "sed 's/>$//'"
  local command = cat .. ent_file .. " | " .. grep .. entityName:upper() .. "\" | " .. sed_one ..  " | " .. sed_two
  
  local output = string.trimString(execCaptureOutputAsString(command))
  
  -- Check whether entity was found.
  if output == "" then
    return nil
  end
  
  -- If it was found then return result. 
  return output
end
--------------------------------------------------------------------------------