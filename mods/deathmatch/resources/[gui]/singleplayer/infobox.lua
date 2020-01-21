
function showInfoBox(source,cmd,param)
    local messageData = { 
        ["text"]=param, 
        ["R"]=255, 
        ["G"]=255, 
        ["B"]=255, 
        ["size"]=1.7
    } 
    triggerClientEvent(source,"infobox",root,messageData) 
end
addCommandHandler('box',showInfoBox,false,false)
