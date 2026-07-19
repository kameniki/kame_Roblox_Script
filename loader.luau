task.spawn(function() 
task.wait(1) 
local urls = { 
"https://pastefy.app/KG4whuxa/raw", 
"https://rawscripts.net/raw/Universal-Script-Good-Aimbot-Mobile-122484" 
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
