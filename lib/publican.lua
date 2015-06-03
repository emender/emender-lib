-- publican.lua - Class that provides functions for working with publican documents.
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
publican = {requires = {}}
publican.__index = publican


--
--- Constructor of the publican class. It allows to set name of publican configuration file 
--  and path to the publican conf file. This function returns new object of this class 
--  when everything is correct, otherwise nil.
--
--  @param conf_file the name of configuration file"".
--  @param path to the publican configuration file.
--  @return New object. When there is some error then it returns nil.
function publican.create(conf_file, new_path)
  -- Check whether name of file is set.
  if conf_file == nil then
    fail("The name of configuration file has to be set. e.g. 'publican.cfg'")
    return nil
  end
  
  -- Create variable for new object.
  local publ = {}
  
  if new_path == nil then 
    new_path = ""
  end
  
  publ.path = new_path
  publ.configuration_file = conf_file 
  
  -- Set metatable for new object.
  setmetatable(publ, publican)

  -- Check whether configuration file exists.
  if not publ:isPublicanProject() then
    return nil 
  end
  
  -- Return the new object. 
  return cfg_file_path
end

--
--- Function that checks whether set directory is the root directory of publican document.
--
--  @return true when there is publican. Otherwise false.
function publican:isPublicanProject()
  
  -- Check whether publican.cfg exist.
  if not path.file_exists(self.conf_file_name) then
    fail("File '" .. self.conf_file_name .. "' does not exists.")
    return false
  end
  
  return true
end


--
--- Function that parse values from publican config file.
--
--  @param item_name is name of value which we want to find. The name without colon.
--  @return the value.
function publican:getPublicanOption(item_name)
  local command = "cat " .. path.compose(self.path, self.configuration_file) .. " | grep -E '^[ \t]*" .. item_name .. ":[ \t]*.*' | sed 's/^[^:]*://'"
   
  -- Execute command, trim output and return it.
  local output = string.trimString(execCaptureOutputAsString(command))
  if output == "" then
    return nil
  end
  
  return output
end


--
--- Function that allows find all options from publican.cfg which match pattern.
--
--  @param pattern 
--  @return table with options which match the pattern
function publican:matchPublicanOption(pattern) 
  -- TBD  
  
  
  
end






