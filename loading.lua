module(..., package.seeall)

local storyboard = require("storyboard")
local scene = storyboard.newScene()

local loadLevel = true




---------------------------------------------------------------------------------
-- STORYBOARD FUNCTIONS
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene(event)
    local localGroup = self.view

    -- Note: if x and y supplied, Halign and Valign will be ignored

    -----------------

    local r = display.newRect(0, 0, 600, 420)
    localGroup:insert(r)
    r:setFillColor(0, 0, 0)
    r.alpha = 00
    r.x = 240
    r.y = 160

    adText = display.newText("Loading...", 0, 0, fontName[1], 26)
    adText.x = 240; adText.y = 138 + o
    adText:setTextColor(230, 230, 0); adText.alpha = 1
    localGroup:insert(adText)
    adText.alpha = 0



    --      CREATE display objects and add them to 'group' here.
    --      Example use-case: Restore 'group' from previously saved state.

    -----------------------------------------------------------------------------
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene(event)
    local group = self.view



    -----------------------------------------------------------------------------

    --      This event requires build 2012.782 or later.

    -----------------------------------------------------------------------------
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    local group = self.view

    local previous = storyboard.getPrevious()

    if previous ~= "main" and previous then
       storyboard.removeScene(previous)
    end

    print ("NEXT: ".._G.nextScene.." ".._G.direction)

    local ready = function()

        storyboard.gotoScene(_G.nextScene)
    end

    timer.performWithDelay(100, ready)


    -----------------------------------------------------------------------------

    --      INSERT code here (e.g. start timers, load audio, start listeners, etc.)

    -----------------------------------------------------------------------------
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    local group = self.view

    --Runtime:removeEventListener("touch", touchLogos)

    -----------------------------------------------------------------------------

    --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

    -----------------------------------------------------------------------------
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene(event)
    local group = self.view

    -----------------------------------------------------------------------------

    --      This event requires build 2012.782 or later.

    -----------------------------------------------------------------------------
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene(event)
    local group = self.view

    -----------------------------------------------------------------------------

    --      INSERT code here (e.g. remove listeners, widgets, save state, etc.)

    -----------------------------------------------------------------------------
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan(event)
    local group = self.view
    local overlay_scene = event.sceneName -- overlay scene name

    -----------------------------------------------------------------------------

    --      This event requires build 2012.797 or later.

    -----------------------------------------------------------------------------
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded(event)
    local group = self.view
    local overlay_scene = event.sceneName -- overlay scene name

    -----------------------------------------------------------------------------

    --      This event requires build 2012.797 or later.

    -----------------------------------------------------------------------------
end



---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener("createScene", scene)

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener("willEnterScene", scene)

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener("enterScene", scene)

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener("exitScene", scene)

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener("didExitScene", scene)

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener("destroyScene", scene)

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener("overlayBegan", scene)

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener("overlayEnded", scene)

---------------------------------------------------------------------------------

return scene
