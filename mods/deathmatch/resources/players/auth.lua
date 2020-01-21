-- acount 
addCommandHandler('register',function(player,cmd,user,pwd)
    if not user or not password then
        return outputChatBox('[S]: /' .. cmd .. '[用户名] [密码]',player,255,255,255)
    end
    
end)
-- login 

-- logout