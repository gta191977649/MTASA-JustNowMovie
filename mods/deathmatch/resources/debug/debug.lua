function setRain(player,cmd,level)
    setRainLevel(level)
end

addCommandHandler('rain',setRain,false,false)
