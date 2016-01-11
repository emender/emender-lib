-- asciidoc.lua - A class that provides functions for working with AsciiDoc
-- documents. Copyright (C) 2015 Bara Ancincova, Pavel Vomacka
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

asciidoc = {requires = {}}
asciidoc.__index = asciidoc

-- Create an object

function asciidoc.create(file_path)
	-- Create a variable for the new object
	local ascii = {}

	-- Fail when the main file is not specified:
	if not file_path then
		fail("Specify the main AsciiDoc file with the '--Xmain_file=<path_to_the_main_file>' variable.")
	end

	-- Store the main file into as an object:
	ascii.main_file = file_path

	-- Set metatable for the new object:
	setmetatable(ascii, asciidoc)

	local tree = {}

	asciidoc.get_content(file_path, tree)

	ascii.tree = tree

	asciidoc.printStructure(tree, -1)

	-- Return the new object:
	return ascii
end


--
--
--
--
function asciidoc.get_content(file_path, tree)
    table.insert(tree, {file_path})

	-- Add content of the main file to a table
	local file_content = slurpTable(file_path)

	-- End the function when the slurpTable returns nil - then the file does not exists or is empty.
	if not file_content then
		return
	end

	-- Create an empty table that will list all lines that includes other files
	local includes = {}

	-- Create an empty table that will list all attributes and theirs values
	local attributes_values = {}

	local attribute_exists = false

	-- Get lines that includes other files:
	for i,entry in ipairs(file_content) do
		if entry:match("include::") and not entry:match("^//") then
			local trim_entry = entry:gmatch("include::(.+)%[.*%]")
			entry = trim_entry()
			table.insert(includes,entry)

			-- Determine if includes consists of attribute (for example {includedir})
			if entry:match("{.*}") then
				attribute_exists = true
			end

		-- Create a table with attributes and theirs values:
		elseif entry:match("^:[^:]+:") then
			local attr_val = entry:gmatch(":([^:]+):%s?(.*)")
			local attribute, value = attr_val()
			attributes_values[attribute] = value
		end
	end

	-- Replace an attribute with its actual value
	if attribute_exists then
		for i,entry in ipairs(includes) do
			if entry:match("{.*}") then
				for item in entry:gmatch("{(%w+)}") do
					if attributes_values[item] then
						includes[i] = entry:gsub("{" .. item .. "}", attributes_values[item])
					else
						warn("Asciidoc.lua: Attribute '" .. item  .. "' not found.")
					end
				end
			end
		end
	end

	-- Go through all includes which are in current file
	for _, includedFile in ipairs(includes) do
		-- Take the path to the directory where current file is placed. Current file is the file which contains these includes.
		local parentDir = asciidoc.trimFileName(file_path)

		-- in case, that we have parent directory and included another file compose new path. New path can be used from the root directory of this book.
		if parentDir and includedFile then
			includedFile = path.compose(parentDir, includedFile)
		end

		-- Recursively check next file.
		asciidoc.get_content(includedFile, tree[#tree])
	end
end


--
--
--
--
--
function asciidoc.trimFileName(filePath)
	if not filePath then
		return nil
	end

	-- File is in the root directory.
	if not filePath:match("/") then
		return ""
	end

	-- Reverse the string because of easier pattern matching
	local helpStr = filePath:reverse()

	-- Remove the file name and reverse the path back.
	helpStr = helpStr:gsub("[^/]*/", "")
	filePath = helpStr:reverse()

	return filePath
end


--
--
--
--
--
function asciidoc.printStructure(tree, level)
	for key, value in ipairs(tree) do
		if type(value) == "string" then
			print(level, value)
		elseif type(value) == "table" then
			asciidoc.printStructure(value, level+1)
		end
	end
end
