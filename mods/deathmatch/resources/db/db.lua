-- 获取配置
local config = xmlLoadFile("config.xml")
if config then
    host = xmlNodeGetAttribute(config,"host")
    user = xmlNodeGetAttribute(config,"user")
    pwd = xmlNodeGetAttribute(config,"pwd")
    db = xmlNodeGetAttribute(config,"db")

    -- mySQL = dbConnect( "mysql", "dbname=mta;host=localhost", "myserver", "12345")
    mySQL = dbConnect( "mysql", "charset=utf8;dbname="..db..";host="..host, user, pwd)
    if mySQL then
        print("DB Connection OK!")
    else
        print("DB Connection Fail!")   
    end
else
    print("Cannot Found db config file!")
end


function query(str)
	if mySQL then
		local query = dbQuery(mySQL, str)
		if not ( query ) then
			return false
		end
		local result, num_rows, id = dbPoll(query, -1)
		return result or false, num_rows or false, id or false
	end
	return false
end