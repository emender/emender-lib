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
sql.__index = sql


--
--- Constructor. File_name has to be set.
--
--  @param file_name Name of the database file.
--  @return sqlite3 object.
function sql.create(fileName)
    if not fileName then
        fail("sql.lua: File name has to be set.")
        return nil
    end

    local s = {}
    s.file = fileName

    -- Add this class as metatable of new created object (table).
    setmetatable(s, sql)

    -- Check whether file exists.
    if not path.file_exists(s.file) then
        fail("sql.lua: Database file does not exist.")
        return nil
    end

    -- Return the new object
    return s
end


--
--- Get schema of database and return it as string
--
--  @return database schema as string.
function sql:getDBSchema()
    -- Compose command.
    local command = "sqlite3 \"" .. self.file .. "\" \".schema\""

    -- Execute command and capture the output.
    local output = execCaptureOutputAsString(command)

    -- Return schema of the database.
    return output
end


--
--- Function that find id of last inserted row.
--
--  @return last insert id as string
function sql:lastInsertedRowId()
    -- Compose command for getting last inserted row.
    local command = "sqlite3 \"" .. self.file .. "\" \".last_insert_rowid()"

    -- Execute command.
    local output = execCaptureOutputAsString(command)

    -- Return the output.
    return output
end


--
--- Execute slq query.
--  Use apostrophes to quoting string in queries which will be executed by this function.
--
--  @param query which will be executed
--  @return table with the output of the query,
function sql:executeQueryGetAll(query)
    -- Compose commanf for executing query

    local command = "sqlite3 \"" .. self.file .. "\" \"" .. query .. "\""

    -- Execute command.
    local output = execCaptureOutputAsTable(command)
    -- Return nil when table is empty.
    if table.isEmpty(output) then
        return nil
    end

    -- Return the output.
    return output
end


--
--- Execute slq query (and return only first result).
--  Use apostrophes to quoting string in queries which will be executed by this function.
--
--  @param query which will be executed
--  @return the first line from output,
function sql:executeQueryGetFirst(query)
    -- Compose command for executing query
    local command = "sqlite3 \"" .. self.file .. "\" \"" .. query .. "\""

    -- Execute command.
    local output = execCaptureOutputAsTable(command)

    -- Return the output.
    return output[1]
end
