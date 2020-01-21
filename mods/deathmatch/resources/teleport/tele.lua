function tele(source,cmd,placeName)
    if placeName then 
        local result = exports.db:query("SELECT * FROM `user_tele` WHERE `NAME` = '"..placeName.."'")
        if result then
            local x = result[1]["X"]
            local y = result[1]["Y"]
            local z = result[1]["Z"]
            local a = result[1]["A"]
            local int = result[1]["INT"]
            local creator = result[1]["CREATOR"]
            local rotX, rotY = getElementRotation(localPlayer)

            setElementPosition ( source, x, y, z )
            setElementRotation(localPlayer,0,0,a) 
            setElementInterior ( source, int)

            outputChatBox ( "传送到:" .. placeName .. " 制作者:" ..creator  ,source )
        else
            outputChatBox ( "[错误]: 传送点不存在!" ,source )
        end
    else
        outputChatBox ( "[用法]: /"..placeName.." [传送点名称]" ,source )
    end
end

addCommandHandler("go",tele,false)