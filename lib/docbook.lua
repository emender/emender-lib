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
--  @param file_path main file of docbook doucument.
--
--  @return New object. When there is some error then it returns nil.
function docbook.create(file_path)
  -- Empty object.
  local docb = {["readableTags"] = {"para", "title"}}

  if not file_path then
    fail("You have to set main file of docbook document.")
  elseif not path.file_exists(file_path) then
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
function docbook:getRevHistory()
  return revhistory.create(self.main_file)
end


--
--- Function which get readable text from docbook document.
--
--  @return table with content
function docbook:getReadableText()
    local xmlObj = xml.create(self.main_file)

    return xmlObj:getContentOfMoreElements(docb.readableTags)
end
