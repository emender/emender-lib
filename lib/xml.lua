-- xml.lua - The class provides function for working with xml files.
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

-- TBD: default return values when no element is found

-- Define the class and set of tools which has to be installed:
xml = {requires = {"xmllint", "xmlstarlet"}}
xml.__index = xml


--
--- Constructor. File_name has to be set. 
--
--  @param file_name Name of file which will be parsed.
--  @param xinclude Enables (1) or disables (0) xincludes. Optional.
function xml.create(file_name, xinclude)
  if file_name == nil then 
    fail("File name has to be set.")
    return nil
  end
  
  -- Set default value of xinclude.
  local x = {["xinclude"]=1}
  
  -- Add this class as metatable of new created object (table).
  setmetatable(x, xml)
  x.file = file_name
  
  -- Check whether xinclude has correct value and if it has, then set it.
  if xinclude ~= nil then
    if type(xinclude) == "number" then
      if xinclude == 1 or xinclude == 0 then
        x.xinclude = xinclude
      else
        fail("Parameter 'xinclude' has to be 0 or 1, not: '" .. xinclude .. "'.")
        return nil
      end
    else
      fail("Parameter 'xinclude' has to be number value. Current type: '" .. type(xinclude) .. "'.")
      return nil
    end
  end
  
  -- Check whether file_name is set correctly.
  if not x:checkFileVariable() then 
    return nil
  end
  
  -- Return the new object
  return x
end


--
--- Function that check whether variables are set.
--
-- @return false when variable isn't set or file does not exist.
function xml:checkFileVariable() 
  -- Check whether file is set and whether file exists.
  if self.file == nil then
    fail("File was not set.")
    return false
  elseif not path.file_exists(self.file) then
    fail("File '" .. self.file .. "' does not exist.")
    return false
  end
  
  -- Everything is OK, return true.
  return true
end

--
--- Function that compose XPath query which find the content of 'element'.
--  
--  @param element name of the element which will be found. 
--  @return composed XPath as string. 
function xml:composeXPathElement(element, namespace)
  if not element then
    return nil
  end
  
  local beginning = "//"
  local get_text = "/text()"
  local namespace_prefix = "newnamespace:"
  
  -- Compose xpath query and return it
  if namespace ~= nil then
    return beginning .. namespace_prefix .. element .. get_text
  else
    return beginning .. element .. get_text
  end
end


--
--- Function that compose XPath query which find the value of 'attribute'.
-- 
--  @param attribute name of the attribute which will be found. 
--  @return composed XPath as string.
function xml:composeXPathAttribute(attribute, namespace)
  if not attribute then
    return nil
  end
  
  local beginning = "//"
  local attribute_mark = "@"
  local namespace_prefix = "newnamespace:"
  
  -- Compose xpath query and return it
  if namespace ~= nil then
    return beginning .. attribute_mark .. namespace_prefix .. attribute
  else
    return beginning .. attribute_mark .. attribute
  end
end


--
--- Compose XPath for finding value of 'attribute' attribute of particular 'element' element.
--
--  @param attribute name of attribute
--  @param element name of element
--  @param namespace namespace url. Optional.
function xml:composeXPathAttributeElement(attribute, element, namespace)
  if not attribute or not element then
    return nil
  end
  
  local beginning = "//"
  local delimiter = "/@" 
  local ns_prefix = "newnamespace:"
    
  -- Compose xpath query and return it
  if namespace ~= nil then
    return beginning .. ns_prefix .. element ..  delimiter .. ns_prefix .. attribute
  else
    return beginning .. element ..  delimiter .. attribute
  end  
end


--
--- Function that find all elements defined by xpath and get content of these elements.
--
--  @param namespace (if there is no namespace, then set this argument to empty string). For example: r=http://example.namespace.com
--  @param xpath defines path to the elements. If namespace is defined then use namespace 'newnamespace' prefix(i.e. //newnamespace:elem/newnamespace:test).
--  @return table where each item is content of one element. Otherwise, it returns nil.
function xml:parseXml(xpath, namespace)
  -- Check whether xpath parameter is set.
  if not xpath then
    return nil
  end
  
  -- Namespace check
  local new_ns = ""
  if namespace ~= nil then
    new_ns = "-N newnamespace='" .. namespace .. "' "
  else 
    new_ns = ""
  end
  
  -- Variables for composing command.
  local err_redirect = "2>/dev/null"
  local xmllint = "xmllint " 
  local xmlstarlet = "xmlstarlet sel " .. new_ns .. "-t -v '" .. xpath .. "'"
  
  -- Turn on xincludes.
  if self.xinclude > 0 then
    xmllint = xmllint .. "--xinclude --postvalid "
  end
  
  -- Compose command.
  local command = xmllint .. " " .. self.file .. " " .. err_redirect .. " | " .. xmlstarlet .. " " .. err_redirect

  -- Execute command and return table.
  return execCaptureOutputAsTable(command)
end


--
--- Function that gets content of first element with "element" name.
--  
--  @param element name of the element which you want to find.
--  @return content of the first occurence of element as string. If there is any error or no element was found then the function will return nil.
function xml:getFirstElement(element, namespace)
  local table = self:parseXml(self:composeXPathElement(element, namespace), namespace)

  if not table then
    return nil
  end
  
  -- Return content of the first found element.
  return table[1]
end


--
--- Function that finds all elements with 'element' name and returns their content.
--  
--  @param element name of the element which you want to find.
--  @return table with content of all elements. Each elements content is in each item. If there is any error or no element was found then the function will return nil. 
function xml:getElements(element, namespace)
  local table = self:parseXml(self:composeXPathElement(element, namespace), namespace)
  
  if not table or #table == 0 then
    return nil
  end
  
  -- Return result of finding.
  return table
end


--
--- Function that returns value of first attribute with 'attribute' name.
--  
--  @param attribute name of the attribute which you want to find.
--  @return value of first attribute as string. If there is any error then the function will return nil.
function xml:getFirstAttribute(attribute, namespace)
  local table = self:parseXml(self:composeXPathAttribute(attribute, namespace), namespace)
  
  if not table then
    return nil
  end
  
  -- Return content of the first found attribute.
  return table[1]
end


--
--- Function that finds all attributes with 'attribute' name and return their values as items in table.
--  
--  @param attribute name of the attribute which you want to find.
--  @return table with values of all attributes with 'attribute' name. If there is any error then the function will return nil.
function xml:getAttributes(attribute, namespace)
  local table = self:parseXml(self:composeXPathAttribute(attribute, namespace), namespace)
  
  if not table or #table == 0 then
    return nil
  end
  
  -- Return result of finding.
  return table
end


--
--- Function that finds the first element with 'element' name and with attribute with 'attribute' 
--  name in namespace (if it is set) and returns attribute value.
--  'namespace' is optional.
--
--  @param attribute name of the attribute
--  @param element name of the element
--  @param namespace namespace url
--  @return value of the first element with attribute with names which we need.
function xml:getFirstAttributeOfElement(attribute, element, namespace)
  local table = self:parseXml(self:composeXPathAttributeElement(attribute, element, namespace), namespace)
 
  if not table then
    return nil
  end
    
  -- Return content of the first found attribute
  return table[1]
end


--
--- Function that finds all elements with 'element' name with attribute with 'attribute' 
--  name in namespace (if it is set) and returns attribute value.
--  'namespace' is optional.
--
--  @param attribute name of the attribute
--  @param element name of the element
--  @param namespace namespace url
--  @return value of the first element with attribute with names which we need.
function xml:getAttributesOfElement(attribute, element, namespace)
  local table = self:parseXml(self:composeXPathAttributeElement(attribute, element, namespace), namespace)
  
  if not table or #table == 0 then
    return nil
  end
  
  -- Return result of finding.
  return table
end