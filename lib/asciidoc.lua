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

	asciidoc.printStructure(tree, 0)
	asciidoc.getLinks(tree)

	-- Return the new object:
	return ascii
end


--
--- Function that takes main file, fetch its content and parse all includes.
--  Then recursively goes through all includes. The output is table with files
--  from which the documentation is composed. It stores the path to the file,
--  content of the file, number of lines and children.
--
--  @param file_path path to the main file
--  @param tree the table for storing information.
--
function asciidoc.get_content(file_path, tree)
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
		if entry:match("include::") and not entry:match("^//") then -- skip commented includes
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

	-- Insert the file into table.
	table.insert(tree, {["file"] = file_path, ["content"] = file_content, ["lineCount"] = #file_content, ["children"] = {}})

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
		asciidoc.get_content(includedFile, tree[#tree]["children"])
	end
end


--
--- Trims file name from the path to the file. Useful for building path to the files
--  which are included.
--
--  @param filePath path which should be trimmed
--  @return path to the directory where the file is
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
--- Function that prints filu structure of the current asciidoc book.
--
--  @param tree the table which contains file tree
--  @param level when calling this function set it to the 0. Then the files
--				in the root directory will have depth of 0.
function asciidoc.printStructure(tree, level)
	for key, value in ipairs(tree) do
		if type(value["file"]) == "string" then
			print("Depth: " .. level, value["file"])

			if not table.isEmpty(value["children"]) then
				asciidoc.printStructure(value["children"], level+1)
			end
		end
	end
end



--
--- Function that should be use for getting links from the asciidoc documentation.
--  Only parameter which this function needs is tree of files stored in asciidoc
--  object (created while the object was created.)
--
--  @param tree table with all asciidoc files
--  @return table with links in [1]="link1", [2]=link2, ... format
function asciidoc.getLinks(tree)
	-- if given table is nil then return.
	if not tree then
		return nil
	end

	-- Prepare variables for all links and for links from current file.
	local links = {}
	local currentLinks = {}

	-- Go through all files and parse them.
	for i, fileInfo in ipairs(tree) do
		if type(fileInfo["file"]) == "string" then
			-- In case that there is file name (not empty table) parse this file
			-- and fetch links from it.
			tempLinks = asciidoc.findLinks(fileInfo["content"])
			links = table.appendTables(links, currentLinks)

			-- In case that file has at least one include in it, the recursively
			-- call this function again,
			if not table.isEmpty(fileInfo["children"]) then
				asciidoc.getLinks(fileInfo["children"])
			end
		end
	end

	-- Return table with links
	return links
end


--
--- Function that goes through all lines in file (table where each item is
--  one line from the file) and stores every link which occurres in the line.
--
--  @param contentTable table with content of the file.
--  @return table which contains links
function asciidoc.findLinks(contentTable)
	local links = {}

	for i, line in ipairs(contentTable) do
		-- URL pattern taken from http://stackoverflow.com/a/23592008 and edited
		local getLink = line:gmatch'(([hf][t][tp][ps]?[s]?://)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
		for url in getLink do
			table.insert(links, url)
		end
	end

	-- Return table with links
	return links
end
