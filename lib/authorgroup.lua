-- authorgroup.lua - Class that provides functions for getting information from Author_Group.xml file.
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
authorgroup = {requires = {}}
authorgroup.__index = authorgroup

--
--- Constructor of the authorgroup class. The argument accepts xml file. 
--  Every function of this class will find in this xml file. 
--
--  @param file in which we can find bookinfo tag
--  @return New object. When there is some error then it returns nil.
function authorgroup.create(file)
  -- Empty object.
  local author_g = {}
  
  -- Save content of 
  author_g.file = file
  
  -- Set metatable for new object.
  setmetatable(author_g, authorgroup)
  
  -- Return the new object. 
  return author_g
end


--
--- Function that finds the firstnames of all authors.
--
--  @return table with firstnames of all authors. Nil when no author was found.
function authorgroup:firstnames()
  local xmlObj = xml.create(self.file)
  
  return xmlObj:getElements("authorgroup/author/firstname")
end



--
--- Function that finds the surnames of all authors.
--
--  @return table with surnames of all authors. Nil when no author was found.
function authorgroup:surnames()
  local xmlObj = xml.create(self.file)
  
  return xmlObj:getElements("authorgroup/author/surname")
end


--
--- Function that finds the emails of all authors.
--
--  @return table with emails of all authors. Nil when no author was found.
function authorgroup:emails()
  local xmlObj = xml.create(self.file)
  
  return xmlObj:getElements("authorgroup/author/email")
end