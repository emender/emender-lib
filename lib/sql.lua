-- sql.lua - The class provides function for working with sqlite3 databases.
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
sql = {requires = {"sqlite3"}}
sql.__index = sqlite3


--
--- Constructor. File_name has to be set.
--
--  @param file_name Name of the database file.
--  @return sqlite3 object.
function sqlite3.create(fileName)
  if fileName == nil then
    fail("File name has to be set.")
    return nil
  end

  local s = {}
  s.file = fileName

  -- Add this class as metatable of new created object (table).
  setmetatable(s, sql)

  -- Return the new object
  return s
end


--
--- Get schema of database and return it as string
--
--  @return database schema.
function slq:getDBSchema()
    -- Compose command.
    local command = "sqlite3 \"" .. self.file .. "\" \".schema\""

    -- Execute command and capture the output.
    local output = execCaptureOutputAsString(command)

    -- Return schema of the database.
    return output
end


--
---
--
--
function sql:executeQuery()




end