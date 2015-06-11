-- infofile.lua - Class that provides functions for getting information from Book(Article)_Info file.
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
infofile = {requires = {}}
infofile.__index = infofile

--
--- Constructor of the infofile class. The argument accepts xml file. 
--  Every function of this class will find in this xml file. 
--
--  @param file in which we can find bookinfo tag
--  @return New object. When there is some error then it returns nil.
function infofile.create(file)
  -- Empty object.
  local info_f = {}
  
  -- Save content of 
  info_f.file = file
  
  -- Set metatable for new object.
  setmetatable(info_f, infofile)
  
  -- Return the new object. 
  return info_f
end


--
--- Function that parse content of 'element' from Book(Article)_Info.xml
--
--  @param element name of the element
--  @return content of this element
function infofile:getOneElement(element)
  if element == nil then
    return nil
  end
  
  -- Parse Book(Article)_Info.xml and return content of element which we need.
  local xmlObj = xml.create(self.file)
  
  return xmlObj:parseXml("//articleinfo/" .. element .. "|//bookinfo/" .. element)
end


--
--- Function that finds document title and returns it.
--
--  @return document title as string.
function infofile:documentTitle()
  -- Find title element.
  local title = self:getOneElement("title")
  
  -- Check whether there is title
  if title then
    return title[1]
  end
  
  return nil
end


--
--- Function that finds document subtitletitle and returns it.
--
--  @return document subtitle as string.
function infofile:documentSubtitle()
  local subtitle = self:getOneElement("subtitle")
  
  -- Check whether there is subtitle.
  if subtitle then
    return subtitle[1]
  end
  
  return nil
end


--
--- Function that finds product name and returns it.
--
--  @return  product name as string.
function infofile:productName()
  local productname = self:getOneElement("productname")
  
  if productname then
    return productname[1]
  end
  
  return nil
end


--
--- Function that finds product version and returns it.
--
--  @return product version as string.
function infofile:productVersion()
  local productnumber = self:getOneElement("productnumber")
  
  if productnumber then
    return productnumber[1]
  end
  
  return nil
end


--
--- Function that finds keywords and returns them.
--
--  @return product keywords in table, one item for each keyboard.
function infofile:keywords()
  return self:getOneElement("keywordset/keyword")
end


--
--- Function that finds abstract and returns it.
--
--  @return product abstract as string.
function infofile:abstract()
  local abstract = self:getOneElement("abstract")
  
  if abstract then
    return abstract[1]
  end
  
  return nil
end





