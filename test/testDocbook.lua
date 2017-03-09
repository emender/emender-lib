package.path=package.path..";../lib/?.lua"

function fail(message)
    print(message)
end

local ok = true

require("docbook")

function checkVersion(filename, expectedVersion)
    local version = docbook.readDocbookVersion(filename)
    if not version then
        print("failure: version is not recognized")
        ok = false
    elseif version == expectedVersion then
        print("ok " .. version)
    else
        print("failure " .. expectedVersion .. " != " .. version) 
        ok = false
    end
end

checkVersion("Test_Book_4_0.xml", "4.0")
checkVersion("Test_Book_4_2.xml", "4.2")
checkVersion("Test_Book_4_3.xml", "4.3")
checkVersion("Test_Book_4_4.xml", "4.4")
checkVersion("Test_Book_4_5.xml", "4.5")

checkVersion("Test_Book_4_0_b.xml", "4.0")
checkVersion("Test_Book_4_2_b.xml", "4.2")
checkVersion("Test_Book_4_3_b.xml", "4.3")
checkVersion("Test_Book_4_4_b.xml", "4.4")
checkVersion("Test_Book_4_5_b.xml", "4.5")

checkVersion("Test_Book_5_0.xml", "5.0")
checkVersion("Test_Book_5_0_B.xml", "5.0")
checkVersion("Test_Book_5_0_C.xml", "5.0")
checkVersion("Test_Book_5_0_D.xml", "5.0")
checkVersion("Test_Book_5_0_E.xml", "5.0")

checkVersion("Test_Book_5_0_article.xml", "5.0")
checkVersion("Test_Book_5_0_set.xml", "5.0")

if not ok then
    os.exit(1)
end

