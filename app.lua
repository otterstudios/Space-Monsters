module(..., package.seeall)


------------------------------------------------------------------
-- LIBRARIES
------------------------------------------------------------------

local storyboard = require("storyboard")
local scene = storyboard.newScene()
local physics = require("physics")

physics.start(true)
physics.setDrawMode("default")
physics.setGravity(0, 0)



------------------------------------------------------------------
-- DISPLAY GROUPS
------------------------------------------------------------------

local localGroup = display.newGroup()
local monsterGroup = display.newGroup()
local hudGroup = display.newGroup()
local targetGroup = display.newGroup()
local scrollGroup = display.newGroup()
local rocketGroup = display.newGroup()
------------------------------------------------------------------
-- LOCAL VARIABLES
------------------------------------------------------------------

local cLevel = settings.currentLevel
local clockTimer = system.getTimer()


--cLevel = 50

local gameIsActive = false

local bg = {}

local scene = storyboard.newScene()

local colours = {
    { 250, 50, 50 },    -- red
    { 255, 255, 50 },   -- yellow
    { 255, 150, 50 },   -- orange
    { 50, 255, 50 },    -- green
    { 50, 255, 255 },   -- cyan
    { 220, 50, 220 },   -- purple
    { 255, 50, 150 },   -- pink
    { 152, 50, 255 },
    { 200,200,200}      -- grey

}

local cls = {}
local cl = 1
local csets = 4


local v = {}

v.score = settings.score
v.missed = 0
v.lives = settings.lives
v.bestScore = settings.bestScore
v.refuel = false


local order = {}

for a = 1, 26, 1 do

    order[a] = a

end

shuffle(order)


------------------------------------------------------------------
-- OBJECT DECLARATIONS
------------------------------------------------------------------

local monsters = {}
local rocket
local countWithout = 0
local hud = {}


------------------------------------------------------------------
-- GAME FUNCTIONS
------------------------------------------------------------------


local updateScore = function ()

      hud.score.txt2.text = "Score: "..comma_value(v.score)
      hud.score:setReferencePoint(display.CenterLeftReferencePoint)
      hud.score.x = 10 - xO

      if v.score > v.bestScore then
        v.bestScore = v.score
         hud.best.txt2.text = "Best: "..comma_value(v.bestScore)
        hud.best:setReferencePoint(display.CenterLeftReferencePoint)
        hud.best.x = 10 - xO
        settings.bestScore = v.bestScore
        settings:save()
      end



end


local gameOver = function ()


local function onComplete(event)

        if "clicked" == event.action then
            local i = event.index
            if 2 == i then

            elseif 1 == i then

             _G.nextScene = "app"
                storyboard.gotoScene("loading", "fromBottom", 500)
            end
        end

end

    native.showAlert("Bad luck!", "You ran out of lives!", {"Restart"}, onComplete)

    gameIsActive = false
    print ("GAME OVER")
    settings.lives = 3
    settings.score = 0
    settings.currentLevel = 1
    settings:save()




end


local levelComplete = function ()


local function onComplete(event)

        if "clicked" == event.action then
            local i = event.index
            if 2 == i then

            elseif 1 == i then

             _G.nextScene = "app"
                storyboard.gotoScene("loading", "fromBottom", 500)
            end
        end



end


    native.showAlert("Nice one!", "You completed level "..cLevel.."!", {"Next"}, onComplete)
    gameIsActive = false

    v.score = v.score + math.round((v.fuelLeft/v.fuel)*100)*cLevel
    updateScore()

    settings.currentLevel = settings.currentLevel + 1
    settings.score = v.score

    audio.play(sounds.win)


    settings:save()




end


local decideTarget = function()

    local c = cLevel


    print ("LEVEL "..c)

    v.monsters = 2 + math.min(4, math.floor(c / 3))
    v.totalTarget = 2 + c
    v.inPlay = math.min(26, 4 + c*2)
    v.colours = math.min(#colours, 5 + c)
    v.targets = {}
    v.got = 0
    v.time = math.max(400, (1400 - (100 * c)))
    local rn = math.random(5, 15)/10
    v.next = 10
    v.force = 25 + c
    v.fuel = v.totalTarget * 50 - (c*5)
    v.fuelLeft = v.fuel


    print("TYPES: " .. v.monsters .. " TOTAL: " .. v.totalTarget .. " IN PLAY: " .. v.inPlay)

    local ave = v.totalTarget / v.monsters
    local tgt = v.totalTarget

    for a = 1, v.monsters, 1 do

        v.targets[a] = {}

        if a ~= v.monsters then

            local ok = 0
            local this = 0

            while ok == 0 do

                ok = 1

                this = math.max(1, math.round(math.random(ave * 0.3, ave * 2)), 0)
                --print(a .. " " .. this)
                v.targets[a].tgt = this

                if tgt - this < v.monsters - a then ok = 0; end
            end

            tgt = tgt - this

        else
            v.targets[a].tgt = tgt
        end

        local ok = 0
        local mon = 0
        while ok == 0 do

            ok = 1
            mon = math.random(1, v.inPlay)

            for b = 1, a - 1, 1 do

                if v.targets[b].mon == mon then ok = 0; end
            end
        end

        v.targets[a].col = math.random(1, v.colours)
        v.targets[a].mon = mon
        --print(a)
        print("TYPE NO: "..a.." TGT: "..v.targets[a].tgt.." MONSTER: "..v.targets[a].mon .. " COLOUR: " .. v.targets[a].col)
    end
end

decideTarget()



local updateFuel = function ()

    if v.fuelLeft < 0 then v.fuelLeft = 0; end

    local fp = math.round((v.fuelLeft/v.fuel)*100).."%"

    if v.fuelLeft == 0 and v.refuel == false then
        v.refuel = nil
        fp = "EMPTY!";
        settings.lives = settings.lives - 1
        settings:save()
         hud.lives.txt2.text = "Lives: "..settings.lives
         hud.lives:setReferencePoint(display.CenterRightReferencePoint)
         hud.lives.x = 310  +xO

         audio.play(sounds.shut)
         if settings.lives > 0 then


            local delayIt = function ()
                 if settings.lives > 0 then v.refuel = true; end
            end

            timer.performWithDelay(500, delayIt)

         else
            gameOver();
         end
    end



      hud.fuel.txt2.text = "Fuel: "..fp
      hud.fuel:setReferencePoint(display.CenterLeftReferencePoint)
      hud.fuel.x = 10 - xO




end

local touchOil = function (event)

    local obj = event.target

     if event.phase == "began" and obj.active and gameIsActive then

             audio.play(sounds.hit)

        local tm = 600

        obj.active = false

        v.fuelLeft = v.fuelLeft + 40
        if v.fuelLeft > v.fuel then v.fuelLeft = v.fuel; end
        doink(hud.fuel)
        transition.to(obj, {time = tm, xScale = 2, yScale = 2, transition = easing.inOutExpo})
        transition.to(obj, {delay = tm, time = tm, x = rocket.x, y = rocket.y, xScale = 0.1, yScale = 0.1, transition = easing.inOutExpo})

        local delaySnd = function ()
            audio.play(sounds.fuel)

        end

        timer.performWithDelay(tm*2-100, delaySnd)


     end

end

local touchMonster = function (event)

    local obj = event.target

    if event.phase == "began" and obj.active and gameIsActive then

        local delaySnd = function ()

             audio.play(sounds.hit)

              local delaySnd2 = function ()

                audio.play(sounds.wee)
            end

               timer.performWithDelay(500, delaySnd2)

        end

        timer.performWithDelay(100, delaySnd)

        obj.active = false

        print ("monster hit")

        local good = false

        for a = 1, v.monsters, 1 do

            if v.targets[a].mon == obj.mon and v.targets[a].col == obj.col and v.targets[a].tgt > 0 then
                good = true
                print ("GOT ONE!")

                local tm = 600

                transition.to(obj, {time = tm, xScale = 2, yScale = 2, transition = easing.inOutExpo})
                transition.to(obj, {delay = tm, time = tm, x = rocket.x, y = rocket.y, xScale = 0.1, yScale = 0.1, transition = easing.inOutExpo})

                if v.targets[a].tgt > 0 then

                v.targets[a].tgt = v.targets[a].tgt - 1
                 v.got = v.got + 1
                 v.score = v.score + math.round((v.score + 500 - obj.y)/10)
                 updateScore()
                end

                local delayIt = function ()

                    obj.alpha = 0
                    v.targets[a].txt.txt2.text = v.targets[a].tgt
                    doink(v.targets[a].txt)
                    doink(v.targets[a].img)
                    audio.play(sounds.got)

                end

                timer.performWithDelay(tm * 2, delayIt)

            end
        end

        if good == false then

                print ("NOPE!")

                local tm = 600

                transition.to(obj, {time = tm, xScale = 2, yScale = 2, transition = easing.inOutExpo})
                transition.to(obj, {delay = tm, time = tm, x = rocket.x, y = rocket.y, xScale = 1, yScale = 1, transition = easing.inOutExpo})

                local sx = math.random(1,2)
                local rx = 600

                if sx == 1 then rx = - rx; end
                local ry = math.random(360,460)

                local rt = math.random(1,360)

                transition.to(obj, {delay = tm * 2 - 100, time = 400, x = rx, y = ry, rotation = rt})




                settings:save()

                local delayIt = function ()

                transition.to(localGroup, { time = 100, x = -4, y = 5 })
                audio.play(sounds.bang)

        for b = 0, 2, 1 do
            transition.to(localGroup, { delay = 0 + (120 * b), time = 40, x = 6, y = 4 })
            transition.to(localGroup, { delay = 40 + (120 * b), time = 40, x = -7, y = -5 })
            transition.to(localGroup, { delay = 80 + (120 * b), time = 40, x = 0, y = 0 })
        end



        v.fuelLeft = v.fuelLeft - 40
        doink(hud.fuel)

        end

        timer.performWithDelay(tm*2-100, delayIt)



        end

        if v.got == v.totalTarget then
            timer.performWithDelay(1200, levelComplete)
            gameIsActive = false
        end



    end





end



local resetColours = function()

    for b = 1, csets, 1 do

        for a = 1, v.colours, 1 do

            local cn = (b - 1) * v.colours + a

            cls[cn] = a
        end
    end

    shuffle(cls)
    cl = 1
end

resetColours()

local spawnMonster = function()

    if v.got < v.totalTarget then

    v.timer = system.getTimer()
    local rn = math.random(5, 15)/10
    v.next = v.time * rn

    local up = math.floor(cLevel/4) + 3

    local isTM = math.random(1, up)
    local isTC = math.random(1,up)

    local ok = 0
    local tm = 0

    while ok == 0 do

        ok = 1
        tm = math.random(1,v.monsters)
        if v.targets[tm].tgt == 0 then
            ok = 0
        end
    end


    local ch = math.random(1, v.inPlay)




    local sz = math.random(45, 60) / 10

    local cu = cls[cl]

    local chg = 1


    if isTC ~= 1 or isTM ~= 1 then
         countWithout = countWithout + 1
         --print ("WITHOUT: "..countWithout)
         if countWithout == 12 + cLevel then
            chg = 0
            countWithout = 0
           end
   else
        countWithout = 0
   end


    if isTC == 1 then cu = v.targets[tm].col; end
    if isTM == 1 then ch = v.targets[tm].mon; end

    if chg == 0 then
        cu = v.targets[tm].col
        ch = v.targets[tm].mon
    end


    --local cl = math.random(1,#colours)

    local ht = math.random(40,60)

    local i = display.newImage("monsters/" .. order[ch] .. ".png")
    local ratio = i.height / i.width
    --local ht = i.height / sz
    local wd = ht / ratio
    display.remove(i)

    local i = display.newImageRect("monsters/" .. order[ch] .. ".png", wd, ht)
    monsterGroup:insert(i)
    i.x = math.random(20-xO, 300+xO)

    i.rotation = math.random(-10, 10)
    i.alpha = 0.95
    i.y = -40 - yO*2
    i:setFillColor(colours[cu][1], colours[cu][2], colours[cu][3])
    physics.addBody(i, { isSensor = true, density = 0.1, bounce = 0.01 })

    local rt = math.random(0, 20+cLevel*10)
    local pos = math.random(1,2)

    if pos == 1 then rt = -rt; end
    i.rotation = rt


    local spin = 0.5 + cLevel*0.2

    local xo = math.random(-spin,spin)
     local yo = math.random(-spin,spin)

    local ff = math.random(8, 12)/10
    local xf = math.random(-3+cLevel/5,3+cLevel/5)

    i:applyForce(xf, ff * v.force , i.x + xo, i.y + yo)
    i:addEventListener("touch",touchMonster)
    i.mon = ch
    i.col = cu
    i.active = true

    cl = cl + 1
    if cl > v.colours * csets then resetColours(); end

    monsters[#monsters + 1] = i

    end
end


local spawnOil = function ()

    local i = display.newImageRect("images/oil.png", 20, 30)
    monsterGroup:insert(i)
    i.x = math.random(20-xO, 300+xO)

    i.rotation = math.random(-10, 10)
    i.alpha = 0.95
    i.y = -40 - yO*2
    --i:setFillColor(colours[cu][1], colours[cu][2], colours[cu][3])
    physics.addBody(i, { isSensor = true, density = 0.2, bounce = 0.01 })

    local rt = math.random(0, 20+cLevel*10)
    local pos = math.random(1,2)

    if pos == 1 then rt = -rt; end
    i.rotation = rt


    local spin = 0.5 + cLevel*0.2

    local xo = math.random(-5,5)
     local yo = math.random(-5,5)

    local ff = math.random(8, 12)/5
    local xf = math.random(4,4)

    i:applyForce(xf, ff * v.force , i.x + xo, i.y + yo)
    i:addEventListener("touch",touchOil)
    i.active = true
    monsters[#monsters + 1] = i



end




local halfSecond = function ()

    v.fuelLeft = v.fuelLeft - 1
    updateFuel()

    local oc = math.random(1,100+cLevel)

    if oc == 5 then

        spawnOil()


    end

    for a = #monsters, 1, -1 do

        --print (monsters[1].y)

        if monsters[a].y > 500 then
            display.remove(monsters[a])
            table.remove(monsters,a)
        end

        --print (#monsters)


    end


end




local gameLoop = function()

     scrollGroup.y = scrollGroup.y + 0.1 + cLevel /20
    -- print (scrollGroup.y)

    if v.refuel == true then
        if v.fuelLeft < v.fuel then
            v.fuelLeft = v.fuelLeft + v.fuel/50
            if v.fuelLeft  > v.fuel then
                v.fuelLeft = v.fuel
                v.refuel = false
            end
        end
    end

     if scrollGroup.y > 512 then scrollGroup.y = 0; end

    local t = system.getTimer()

    if gameIsActive then

        if t - clockTimer > 250 then
            halfSecond()
            clockTimer = system.getTimer()
        end

        if t - v.timer > v.next then

            spawnMonster()

        end

    end




end





---------------------------------------------------------------------------------
-- STORYBOARD FUNCTIONS
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene(event)
    localGroup = self.view

    local createHud = function()

        local r = display.newRect(0, 0, 384, 3)
        r:setFillColor(230,230,230)
        r.alpha = 0.8
        hudGroup:insert(r)
        r.x = 160; r.y = 60 - yO * 2

        local r = display.newRect(0, 0, 384, 60)
        r:setFillColor(0,0,0)
        hudGroup:insert(r)
        r.alpha = 1

        r.x = 160; r.y = 30 - yO * 2

        local createTarget = function()


            for a = 1, v.monsters, 1 do

                local ch = v.targets[a].mon
                local cu = v.targets[a].col
                local tg = v.targets[a].tgt

                local i = display.newImage("monsters/" .. order[ch] .. ".png")

                local ratio = i.height/i.width
                display.remove(i)

                local ht = 40
                local wd = ht / ratio

                local i = display.newImageRect("monsters/" .. order[ch] .. ".png", wd, ht)
                targetGroup:insert(i)
                i.x = a * 50
                i.y = 24 - yO*2
                i:setFillColor(colours[cu][1], colours[cu][2], colours[cu][3])


                local t = newDropText(tg, 13, a * 50, 47 - yO*2 + o, 240,240,240, targetGroup, 1, 255, 255, 255,"n")
                t:setReferencePoint(display.CenterReferencePoint)
                v.targets[a].txt = t
                v.targets[a].img = i
            end


              local t = newDropText("Score: "..comma_value(v.score), 14, 20 ,47 - yO*2 + o, 240,240,240, hudGroup, 1, 255, 255, 255,"n")
              t:setReferencePoint(display.CenterLeftReferencePoint)
              t.x = 10 - xO; t.y = 90 - yO*2
              hud.score = t

               local t = newDropText("Fuel: 100%", 14, 20 ,47 - yO*2 + o, 240,240,240, hudGroup, 1, 255, 255, 255,"n")
              t:setReferencePoint(display.CenterLeftReferencePoint)
              t.x = 10 - xO; t.y = 70 - yO*2
              hud.fuel = t


              local t = newDropText("Best: "..comma_value(v.bestScore), 14, 20 ,47 - yO*2 + o, 240,240,240, hudGroup, 1, 255, 255, 255,"n")
              t:setReferencePoint(display.CenterLeftReferencePoint)
              t.x = 10 - xO; t.y = 110 - yO*2
              hud.best = t


              local t = newDropText("Lives: "..v.lives, 14, 20 ,47 - yO*2 + o, 240,240,240, hudGroup, 1, 255, 255, 255,"n")
              t:setReferencePoint(display.CenterRightReferencePoint)
              t.x = 310 + xO; t.y = 90 - yO*2
              hud.lives = t

               local t = newDropText("Level: "..cLevel, 14, 20 ,47 - yO*2 + o, 240,240,240, hudGroup, 1, 255, 255, 255,"n")
              t:setReferencePoint(display.CenterRightReferencePoint)
              t.x = 310 + xO; t.y = 70 - yO*2
              hud.level = t



        end

        createTarget()

        targetGroup:setReferencePoint(display.CenterReferencePoint)
        targetGroup.x = 160
        hudGroup:insert(targetGroup)
    end





    local createScene = function()

           local i = display.newImageRect("images/bg.png", 512,512)
           scrollGroup:insert(i)
           i.y = 240
           i.x = 160
           i.alpha = 0.5

           local i = display.newImageRect("images/bg.png", 512,512)
           scrollGroup:insert(i)
           i.y = 240 - 512
           i.x = 160
           i.alpha = 0.5


            local i = display.newImageRect("images/rocket.png", 90, 170)
                rocketGroup:insert(i)
                i.y = 540 + yO*2
                i.x = 160
                rocket = i

                transition.to(i, {time = 2000, y = 440 + yO*2})



    end

    createScene()
    createHud()
    localGroup:insert(scrollGroup)
    localGroup:insert(rocketGroup)
    localGroup:insert(monsterGroup)

    localGroup:insert(hudGroup)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene(event)
    local group = self.view
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    local group = self.view

    --localGroup:setReferencePoint(display.CenterReferencePoint)
    --localGroup.x = 160; localGroup.y = 240 - 220
    --localGroup.xScale = 0.5; localGroup.yScale = 0.5

     local previous = storyboard.getPrevious()
        if previous ~= "main" and previous then
            storyboard.removeScene(previous)
        end

          audio.play(sounds.intro)

    local ready = function()
        v.timer = system.getTimer()
        gameIsActive = true

    end

    timer.performWithDelay(2000, ready)

    Runtime:addEventListener("enterFrame", gameLoop)
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    local group = self.view
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene(event)
    local group = self.view

    Runtime:removeEventListener("enterFrame", gameLoop)
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene(event)
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

---------------------------------------------------------------------------------

return scene
