task.spawn(function() 
task.wait(1) 
local urls = { 
"https://raw.githubusercontent.com/kameniki/kame_Roblox_Script/refs/heads/main/FTAP/kicker.luau/", 
"https://raw.githubusercontent.com/kameniki/kame_Roblox_Script/refs/heads/main/FTAP/ping__FPS%3Dcoin.luau/" 
} 
for _, url in ipairs(urls) do 
local success, err = pcall(function() 
loadstring(game:HttpGet(url))() 
end) 
if not success then 
print("load: " .. url .. " - " .. tostring(err)) 
end 
end 
end)
