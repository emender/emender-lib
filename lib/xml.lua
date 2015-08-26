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


-- Define the class and set of tools which has to be installed:
xml = {requires = {"xsltproc"}}
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
--- Setter for xinclude attribute.
--
--  @param value on which you want to set xinclude attribute.
function xml:setXinclude(value)
  -- Check value and set it.
  if value == 1 or value == 0 then
    self.xinclude = value
  end
end


--
--- Getter for xinclude attribute.
--
--  @return current value of xinclude.
function xml:getXinclude()
  return self.xinclude
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
  local namespace_prefix = "newnamespace:"

  -- Compose xpath query and return it
  if namespace ~= nil then
    return beginning .. namespace_prefix .. element
  else
    return beginning .. element
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
--- Function that subtitutes double quotes and apostrophes with &quot; and &apos;.
--
--  @param xpath string
--  @return edited xpath
function xml.escapeDynamicPart(str)
  local out = str:gsub('"', "&quot;")
  out = out:gsub("'", "&apos;")

  return out
end


--
--- Function that runs xslt set as parameter
--
--  @param xslt_definition
--  @return table with output from xsl transformation.
function xml:useXslt(xslt_definition)
    local xinclude = ""

    -- Turn on xincludes.
    if self.xinclude > 0 then
      xinclude = "--xinclude "
    end

    -- Declare variables.
    local err_redirect = "2>/dev/null"
    local echo_outer = "/bin/echo -e `"
    local echo_inner = "/bin/echo " .. xslt_definition
    local xsltproc = "xsltproc " .. xinclude
    local sed = "sed -e 's/\\xC2\\xA0/ /g'" -- Substitute nbsp by normal space.
    local end_of_command = "`"

    -- Compose command.
    local command = echo_outer .. echo_inner .. " | " ..  xsltproc .. " - " .. self.file .. " " .. err_redirect .. " | " .. sed .. end_of_command

    -- Execute command.
    return execCaptureOutputAsTable(command)
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

    -- Substitute all double quotes in xpath by &quot;, because all values of attributes in xslt are in double quotes.
    -- So, another doublequote in the value would make problems. Then all apostrophes are subtituted by &apos;
    xpath = self.escapeDynamicPart(xpath)

    -- Namespace check
    local new_ns = ""
    if namespace ~= nil then
        namespace = self.escapeDynamicPart(namespace)
        new_ns = "xmlns:newnamespace=\"" .. namespace .. "\" "
    else
        new_ns = ""
    end

    local xslt_definition = "'<?xml version=\"1.0\" encoding=\"utf-8\"?><xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\"" .. new_ns .. "><xsl:output method=\"text\" indent=\"yes\"/><xsl:template match=\"/\"><xsl:for-each select=\"" .. xpath .. "\"><xsl:value-of select=\".\"/>\\n</xsl:for-each></xsl:template></xsl:stylesheet>'"

    local result_table = self:useXslt(xslt_definition)

    -- Remove last empty line. TODO: Edit in xslt.
    result_table[#result_table] = nil

    -- If there is no found item then return nil.
    if not result_table[1] then
        return nil
    end

    -- Return value.
    return result_table
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

  if not table then
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

  if not table then
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

  if not table then
    return nil
  end

  -- Return result of finding.
  return table
end


--
--- Function that finds any entity value in main file. If main file has .ent suffix
--  then this function will search only in this file. If main file has .xml suffix
--  and xinclude option is enabled then it uses xincludes and tries to find entity in whole document.
--
--  @param entityName name of entity which this function will find.
--  @return value of the entity
function xml:getEntityValue(entityName)
  if entityName == nil then
    return nil
  end

  -- Find entity file
  local ent_file = self.file
  local print_file_cmd = ""

  -- Check whether it is necessary to use xinclude.
  if not ent_file:match(".*%.ent") and self.xinclude > 0 then
    print_file_cmd = "xmllint --xinclude " .. ent_file .. " 2>/dev/null"
  else
    print_file_cmd = "cat " .. ent_file
  end

  -- Compose command for parsing entity value.
  local grep = "grep \""
  local sed_one = "sed 's/^<!ENTITY " .. entityName:upper() .. " //'"
  local sed_two = "sed 's/>$//'"
  local command = print_file_cmd .. " | " .. grep .. entityName:upper() .. "\" | " .. sed_one ..  " | " .. sed_two

  local output = string.trimString(execCaptureOutputAsString(command))

  -- Check whether entity was found.
  if output == "" then
    return nil
  end

  -- If it was found then return result.
  return output
end


--
--- More specific function which change extension of the file (set in the constructor)
--  to the 'ent' (no matter what was the original extension) and tries to find entity name in it.
--
--  @param entityName name of entity which this function will find.
--  @return value of the entity
function xml:getEntityValueSpecific(entityName)
    -- Swap extension of file to the 'ent'.
    local file_bcp = self.file
    self.file = self.file:gsub("%.%w+$", ".ent")

    -- Find entity name in new file.
    local output = self:getEntityValue(entityName)

    -- Set back the original file name.
    self.file = file_bcp

    return output
end


--
--- Function that return content of more than one tag.
--  Parameter 'tags' contains table of tags which content will be found.
--
--  @param tags table of tags from which this function parse content
--  @return content of tags which contain readable text.
function xml:getContentOfMoreElements(tags)
    local xpath = ""

    -- Compose xpath for find readable text.
    for i, oneTag in ipairs(tags) do
        local orMark = " | "
        local startMark = "//"
        local text = "/text()"

        oneTag = startMark .. oneTag .. text

        -- Add OR operator between every xpath.
        if i > 1 then
            oneTag = orMark .. oneTag
        end

        xpath = xpath .. oneTag
    end

    -- Return whole text.
    return self:parseXml(xpath)
end
