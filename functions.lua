

audio.delay = function (del, aud)

    local delayIt = function ()

        audio.play(aud)

    end

    timer.performWithDelay(del, delayIt)


end


newDropText = function(txt, size, x, y, r, gn, b, grp, dp, r2, g2, b2, drop, fnt)

    local g = display.newGroup()

    if r2 == nil then
        r2 = 0; g2 = 0; b2 = 0;
    end

    if dp == nil then dp = 0.5; end

    if fnt == nil then fnt = 1; end

    if drop == nil then
        local t = display.newText(txt, 0, 0, fontName[fnt], size)
        t.x = x + 0.5; t.y = y + o + dp
        t:setTextColor(r2, g2, b2)
        g:insert(t)
        g.txt1 = t
    end

    local t = display.newText(txt, 0, 0, fontName[fnt], size)
    t.x = x; t.y = y + o
    t:setTextColor(r, gn, b)
    g:insert(t)
    g.txt2 = t

    if grp ~= nil then grp:insert(g); end

    return g
end


