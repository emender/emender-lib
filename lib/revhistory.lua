-- revhistory.lua - Class that provides functions for getting information from Revision_History.xml file.
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
revhistory = {requires = {}}
revhistory.__index = revhistory


--
--- Constructor of the revhistory class. The argument accepts xml file. 
--  Every function of this class will find in this xml file. 
--
--  @param file in which we can find bookinfo tag
--  @return New object. When there is some error then it returns nil.
function revhistory.create(file)
  -- Empty object.
  local revhist = {}
  
  -- Save content of 
  revhist.file = file
  
  -- Set metatable for new object.
  setmetatable(revhist, revhistory)
  
  -- Return the new object. 
  return revhist
end


--
--- Function that parse content of element in Revision_History.xml file. 
--
--  @param element name (or xpath) of the element inside the revhistory element. 
--  @return content of elements in table, or nil when no element matches.
function revhistory:findContent(element)
  if not element then
    return nil
  end
  
  -- Parse Book(Article)_Info.xml and return content of element which we need.
  local xmlObj = xml.create(self.file)
  
  return xmlObj:getElements("revhistory/" .. element)
end


--
--- Function that gets the dates of revisions.
--
--  @return the dates as table. In case that there is no revision history, it returns nil.
function revhistory:dates()
  return self:findContent("revision/date") 
end


--
--- Fetches all revision dates, take the first one and return it.
--
--  @return string with last date of revision.
function revhistory:lastDate()
  local dates = self:dates()
  
  if not dates then
    return nil
  end
  
  -- return the last added item
  return dates[1]
end


--
--- Function that gets all revision numbers.
--
--  @return table with all revision numbers. In case that there is no revision number, it returns nil.
function revhistory:revisionNumbers()
  return self:findContent("revision/revnumber")  
end


--
--- Function that choose only last revision number.
--
--  @return last revision number as string. In case that there is no revision number, return nil.
function revhistory:lastRevisionNumber()
  local rev_nums = self:revisionNumbers()
  
  if not rev_nums then
    return nil
  end
  
  -- return the last added item
  return rev_nums[1]
end


--
--- Function that gets content of all member elements.
--
--  @return table with content of all member elements.
--          In case that there is no revision number, it returns nil.
function revhistory:members()
  return self:findContent("revision/revdescription/simplelist/member")  
end


--
--- Function that choose only last member element and return its content.
--
--  @return last member as string. In case that there is no member, return nil.
function revhistory:lastMember()
  local members = self:members()
  
  if not members then
    return nil
  end
  
  -- return the last added item
  return members[1]
end
