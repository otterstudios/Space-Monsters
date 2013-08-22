display.setStatusBar(display.HiddenStatusBar) -- hide the status bar
system.setIdleTimer(false) -- disable device sleeping
audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode) -- allow user's background music to play
math.randomseed(os.time())
json = require("json") -- import json library (used by GGData)
GGData = require("GGData") -- import data storage library (courtesy of Glitch Games)
settings = GGData:new("settings") -- load data storage object
_G.en = system.getInfo("environment") -- whether or not app is running on simulator or device

_G.osTarget = "iOS" -- is app targeted for iOS or Android devices
_G.nextScene = "app" -- which scene to load initially
_G.direction = "fromRight" -- which animation to use for loading scene
local first = settings.first -- get whether or not the app has been run before (if not, first = nil)
--first = nil

---------------------------------------------------------------------------------
-- LIBRARIES					-- load global libraries that will be used throughout the app
---------------------------------------------------------------------------------
local storyboard = require"storyboard" -- import storyboard library
require ("functions")

AutoStore = require("dmc") -- load automatic json data storage library
data = AutoStore.data -- create link to the AutoStore file



---------------------------------------------------------------------------------
-- LOCAL VARIABLES
---------------------------------------------------------------------------------

local scene = storyboard.newScene() -- initialise this scene
local testing = false -- whether or not to use testing mode for debugging

--------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------------

_G.en = system.getInfo("environment") -- whether or not app is running on simulator or device
_G.platformName = system.getInfo("platformName") -- platform the app is running on (iPhone OS, Android etc)
_G.fontName = {} -- array to hold font information
_G.o = 1 -- 'y' offset amount for text positioning differences between simulator and device
_G.sounds = {} -- array to hold sound files
_G.device = system.getInfo("model") -- device to target for current build
_G.model = "I4"; _G.xO = 0; _G.yO = 0 -- offsets for iPad & iPhone 5

if  ((device == "iPhone" or device == "iPhone Simulator" ) and ( display.pixelHeight > 960 )) then _G.model = "I5"; end
local ratio = display.pixelHeight / display.pixelWidth



if (display.pixelHeight == 1024 or display.pixelHeight == 2048) then _G.model = "IP"; end
if _G.model == "I5" and _G.osTarget == "iOS" then _G.yO = 22; end
if _G.model == "IP" and _G.osTarget == "iOS" then _G.xO = 0; _G.xO = 20; end

if (device ~= "iPhone" and device ~= "iPhone Simulator" )  then

    _G.useIads = false
    --_G.model = "I5"
    _G.yO = (display.actualContentHeight-480)/4
    _G.xO = (display.actualContentWidth-320)/4

else
    --if _G.useIads then ads = require ("ads"); end
end


if en == "device" then
    if _G.platformName == "iPhone OS" then
        _G.o = 3
    end
end

---------------------------------------------------------------------------------
-- ADVERTS							-- initialise advert library
---------------------------------------------------------------------------------



---------------------------------------------------------------------------------
-- SOUNDS						-- load sounds into memory
---------------------------------------------------------------------------------


sounds[7] = audio.loadSound("touch1.mp3") -- sounds for button touches
sounds[9] = audio.loadSound("touch3.mp3"); sounds[8] = audio.loadSound("touch4.mp3")
sounds[11] = audio.loadSound("touch5.mp3"); sounds[10] = audio.loadSound("touch2.mp3") -- hint earned sound
sounds[1] = audio.loadSound("w1.mp3"); sounds[4] = audio.loadSound("w4.mp3") -- sounds for screen transitions
sounds[2] = audio.loadSound("w2.mp3"); sounds[3] = audio.loadSound("w3.mp3")
sounds[5] = audio.loadSound("w5.mp3") sounds[6] = audio.loadSound("w6.mp3")
sounds["woosh"] = audio.loadSound("whoosh.mp3") -- screen whoosh sound

sounds["bang"] = audio.loadSound("bang.mp3")
sounds["intro"] = audio.loadSound("gemchange.wav")
sounds["hit"] = audio.loadSound("5a.m4a")
sounds["got"] = audio.loadSound("27.m4a")
sounds["shut"] = audio.loadSound("shut.mp3")
sounds["fuel"] = audio.loadSound("fuel.mp3")
sounds["win"] = audio.loadSound("win.mp3")
sounds["wee"] = audio.loadSound("wee.mp3")



---------------------------------------------------------------------------------
-- FONTS						-- initialise fonts depending on device type
---------------------------------------------------------------------------------

fontName[1] = "Montserrat-Bold"; if platformName == "Android" then fontName[1] = "AldotheApache"; end

if platformName == "Win" then fontName[1] = system.defaultFont; end
---------------------------------------------------------------------------------
-- FIRST RUN					-- sets up storage database on first run
---------------------------------------------------------------------------------


local deleteAutostore = function()

    local file = "dmc_autostore.json"; local doc_dir = system.DocumentsDirectory;
    local theFile = system.pathForFile(file, doc_dir); local resultOK, errorMsg;

    resultOK, errorMsg = os.remove(theFile);

    if (resultOK) then
        --print(file .. " removed");
    else
        --print("Error removing file: " .. file .. ":" .. errorMsg);
    end

    data = AutoStore.data
end


local firstRun = function() end
if first == nil then

    if AutoStore.is_new_file then

    else
        deleteAutostore()
    end

    local monsters = {}

    for a = 1, 100, 1 do

        monsters[a] = {}

        for b = 1, 10, 1 do

            monsters[a][b] = 0

        end

    end

    data.monsters = monsters


    local createDatabase = function()

        settings.sound = 1
        settings.currentLevel = 1
        settings.lives = 3
        settings.first = 1
        settings.score = 0
        settings.bestScore = 0
        settings:save()
    end

    createDatabase()

    _G.paid = 0
else

end


---------------------------------------------------------------------------------
-- EXTERNAL CONFIG FILE
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS
---------------------------------------------------------------------------------
function shuffle(t)
    local rand = math.random; assert(t, "table.shuffle() expected a table, got nil")
    local iterations = #t; local j

    for i = iterations, 2, -1 do
        j = rand(i); t[i], t[j] = t[j], t[i] -- function to shuffle a table (used for shuffling clues)
    end
end


comma_value = function(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end

    return formatted
end

swipe = function() -- global function to play a random 'swipe' sound

    local playIt = function()

        local s = math.random(1, 6)



        audio.setVolume(0.3, { channel = swipeCh })

        audio.play(sounds[s], { channel = swipeCh })

        swipeCh = swipeCh + 1
        if swipeCh == 17 then swipeCh = 13; end
    end
    timer.performWithDelay(3, playIt)
end


doink = function(obj) -- global function to animate buttons
    local obj = obj

    local ys = 1.2; local yb = 1; local xs = 1.2; local xb = 1
    if obj.yScale < 0 then ys = -1.2; yb = -1; end
    if obj.xScale < 0 then xs = -1.2; xb = -1; end
    transition.to(obj, { time = 100, xScale = xs, yScale = ys })
    transition.to(obj, { delay = 100, time = 300, xScale = xb, yScale = yb })
end




---------------------------------------------------------------------------------
-- INITIALISE
---------------------------------------------------------------------------------

_G.sound = settings.sound -- set sound according to saved parameter
audio.setVolume(_G.sound)



---------------------------------------------------------------------------------
-- FACEBOOK								-- function to handle facebook posting
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- STORYBOARD FUNCTIONS
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene(event)
    local group = self.view
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene(event)
    local group = self.view
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    local group = self.view
end

-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    local group = self.view
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene(event)
    local group = self.view
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan(event)
    local group = self.view
    local overlay_scene = event.sceneName -- overlay scene name
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded(event)
    local group = self.view
    local overlay_scene = event.sceneName -- overlay scene name
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("didExitScene", scene)
scene:addEventListener("destroyScene", scene)
scene:addEventListener("overlayBegan", scene)
scene:addEventListener("overlayEnded", scene)

storyboard.gotoScene("loading")

---------------------------------------------------------------------------------

return scene


