local messageData 
local infoboxHandler = false 
  
local infobox = function () 
    dxDrawRectangle(10, 190, 364, 143, tocolor(0, 0, 0, 188), false) 
    dxDrawText(messageData["text"].."", 20, 200, 364, 308, tocolor(messageData["R"], messageData["G"], messageData["B"], 255), messageData["size"], "default", "left", "top", false, true, false, false, false) 
end 
  
  
local destroyInfobox = function () 
    removeEventHandler("onClientRender",root,infobox) 
    infoboxHandler = false 
end 
  
addEvent("infobox",true) 
addEventHandler("infobox",root, 
function ( messageData2) 
    messageData = messageData2 
    if not infoboxHandler then 
        addEventHandler("onClientRender",root,infobox) 
        playSoundFrontEnd ( 11)
        setTimer(destroyInfobox,3000,1) 
        infoboxHandler = true 
    end 
end) 
  
  