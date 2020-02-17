local anim_timer = {}
local pos_runingMachine = {
    {773.4922, -2.6016 ,1000.7209}
}

function anim_walkToRunningMachine(source)
    -- 播放去跑步机动作
    setPedAnimation(source, "GYMNASIUM", "gym_tread_geton",-1,false,false)
    function anim_running(source) 
        setPedAnimation(source, "GYMNASIUM", "gym_tread_sprint",-1,true,false)
    end
    -- 延迟后播放跑步动作
    if isTimer(anim_timer[source]) then
        killTimer(anim_timer[source])
    end
    anim_timer[source] = setTimer ( anim_running, 2000, 1, source )
end
function gym_set_camera(source,posX,posY,posZ) 
    x, y, z = getElementPosition (source) 
    setCameraMatrix(source,posX+2,posY-2,posZ+0.8,posX,posY,posZ,0,45)
    --setCameraTarget (source)
end
function gym_reset_camera(source,posX,posY,posZ) 
    setCameraTarget (source)
end
function gym_reset_status(source) 
    if isTimer(anim_timer[source]) then
        killTimer(anim_timer[source])
    end
    setPedAnimation ( source ) 
    gym_reset_camera(source)
end
function gym(source)
    --print(pos_runingMachine[1][1])
    local type = "runing_machine"
    local machine_index = 1 -- 哪一台机器

    
    if type == "runing_machine" then 
        setElementPosition(source,pos_runingMachine[machine_index][1], pos_runingMachine[machine_index][2]+ 1.5,pos_runingMachine[machine_index][3])
        local px,py,pz = getElementRotation(source)
        setElementRotation(source,px,py,180)
        setElementInterior(source,5)

        gym_set_camera(source,pos_runingMachine[machine_index][1]+2, pos_runingMachine[machine_index][2]-2,pos_runingMachine[machine_index][3]+0.5)

        anim_walkToRunningMachine(source)
    end

end
addCommandHandler("gym",gym)
addCommandHandler("ca",gym_reset_status)


function gym_event_rest() 
    gym_reset_status(source)
end
addEventHandler ( "onPlayerWasted", getRootElement(), gym_event_rest )
addEventHandler ( "onPlayerQuitServerside", getRootElement(), gym_event_rest )