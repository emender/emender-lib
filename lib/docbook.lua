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
--- Constructor of the docbook class. It allows to set language of this document 
--  and path to the document root directory. If test is ran from root directory 
--  of book, path variable will be empty string.
--
--  @param language of this document. For example: en-US
--  @param path to the directory where this book has publican.cfg file. 
--              Optional parameter, if not set then path will be set to "".
--  @return New object. When there is some error then it returns nil.
function docbook.create(language, new_path)
  -- Check whether language is set.
  if language == nil then
    fail("The language of the document has to be set. e.g. 'en-US'")
    return nil
  end
  
  -- Set default value of docbook object.
  local docb = {["conf_file_name"]="publican.cfg"}
  
  if new_path == nil then 
    new_path = ""
  end
  
  docb.path = new_path
  docb.language = language 
  
  -- Set metatable for new object.
  setmetatable(docb, docbook)
  
  -- Check whether object attributes are set.
  if not docb:checkAttributes() then
    return nil
  end
  
  -- Check whether the directory with content for this language exists.
  local content_dir = path.compose(docb.path, docb.language)

  if not path.directory_exists(content_dir) then
    fail("Directory '" .. content_dir .. "' does not exist.")
    return nil 
  end
  
  -- Return the new object. 
  return docb
end


--
--- Function that checks whether all attributes are set.
--
--  @return true when everything is set. Otherwise return false.
function docbook:checkAttributes()
  if self.path == nil or self.language == nil then
    -- Both or one of the attributes is not set. Print error message.
    fail("Attributes error, path: '" .. self.path .. "', language: '" .. self.language .. "'.")
    return false
  end
  
  -- Everything is OK, return true.
  return true
end


--
--- Function that checks whether set directory is the root directory of publican document.
--
--  @return true when there is publican. Otherwise false.
function docbook:isPublicanProject()
  
  -- Check whether publican.cfg exist.
  if not path.file_exists(self.conf_file_name) then
    fail("File '" .. self.conf_file_name .. "' does not exists.")
    return false
  end
  
  return true
end


--
--- Function that finds the file where the document starts.
--
--  @return path to the file from current directory 
function docbook:findStartFile()  
  local content_dir = path.compose(self.path, self.language)
  
  -- Lists the files in language directory.
  local command = "ls " .. content_dir .. "/*.ent 2>/dev/null"
  
  -- Execute command and return the output and substitute .xml suffix for .ent.
  local result = execCaptureOutputAsString(command)
  if result ~= "" then
    return string.gsub(result, "%.ent$", ".xml", 1)
  end
  
  -- Return nil when there is not entity file.
  return nil
end


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
--- Function that finds document type and returns it. The type can be Book, Article or Set.
--
--  @return 'Book', 'Article' or 'Set' string according to type of book.
function docbook:getDocumentType()  
  local default_type = "Book"
  
  -- Get if there si Book_Info.xml or Article_Info.xml
  local command = "cat " .. path.compose(self.path, self.conf_file_name) .. " 2>/dev/null | grep -E '^[ \t]*type:[ \t]*.*' | awk '{ print $2 }' | sed 's/[[:space:]]//g'"
   
  -- Book or Article, execute command and return its output.
  local output = execCaptureOutputAsString(command)  
  
  -- In case that type is not mentioned in publican.cfg, default type is used.
  if output == "" then
    output = default_type
  end
  
  return output
end


--
--- Function that parse content of 'element' from Book(Article)_Info.xml
--
--  @param element name of the element
--  @return content of this element
function docbook:getElementFromInfoXML(element)
  if element == nil then
    return nil
  end
  
  -- Get document type.
  local document_type = self:getDocumentType()
  
  -- Parse Book(Article)_Info.xml and return content of element which we need.
  local xmlObj = xml.create(path.compose(self.language, document_type .. "_Info.xml"))
  xmlObj.setXinclude(0)
  return xmlObj:getFirstElement(element)
end


--
--- Function that finds document title and returns it.
--
--  @return document title as string.
function docbook:getDocumentTitle()
  return self:getElementFromInfoXML("title")
end


--
--- Function that finds product name and returns it.
--
--  @return  product name as string.
function docbook:getProductName()
  return self:getElementFromInfoXML("productname")
end


--
--- Function that finds product version and returns it.
--
--  @return product version as string.
function docbook:getProductVersion()
  return self:getElementFromInfoXML("productnumber")
end


--
--- Function that parse values from publican.cfg file.
--
--  @param item_name is name of value which we want to find. The name without colon.
--  @return the value.
function docbook:getPublicanOption(item_name)
  local command = "cat " .. path.compose(self.path, self.conf_file_name) .. " | grep -E '^[ \t]*" .. item_name .. ":[ \t]*.*' | sed 's/^[^:]*://'"
   
  -- Execute command, trim output and return it.
  local output = string.trimString(execCaptureOutputAsString(command))
  if output == "" then
    return nil
  end
  
  return output
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
