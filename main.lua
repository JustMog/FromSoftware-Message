local Slab = require 'lib.slab'
local messageGen = require "init"

local games = {
    { name = "Demon's Souls", gen = messageGen.des },
    { name = "Dark Souls 1", gen = messageGen.ds1 },
    { name = "Dark Souls 2", gen = messageGen.ds2 },
    { name = "Dark Souls 3", gen = messageGen.ds3, hasConjunctions = true },
    { name = "Bloodborne", gen = messageGen.bloodborne, hasConjunctions = true  },
    { name = "Sekiro", gen = messageGen.sekiro, hasConjunctions = true },
    { name = "Elden Ring", gen = messageGen.eldenRing, hasConjunctions = true },
}
local numMsgs = 5
local msgLen = 2
local err
local results = {}
local customWords = false
local customConjunctions = false

for _, game in ipairs(games) do
    game.useForTemplate = true
    game.useForWords = false
    game.useForConjunctions = false
end

---comment
---@return nil | string
local function gen()
    local templates
    local words
    local conjunctions
    for _, game in ipairs(games) do
        if game.useForTemplate then
            templates = templates and templates + game.gen or game.gen
        end
        if game.useForWords then
            words = words and words + game.gen or game.gen
        end
        if game.useForConjunctions then
            conjunctions = conjunctions and conjunctions + game.gen or game.gen
        end
    end

    words = not customWords and templates or words
    if customConjunctions then
        conjunctions = conjunctions or messageGen.none
    else
        conjunctions = templates
    end

    if not templates then return "No game selected for templates" end
    if not words then return "No game selected for words" end

    for i = 1, numMsgs - #results do
        table.insert(results, templates(msgLen, {
            conjunctions = conjunctions,
            words = words
        })
    )
    end
end
err = gen()

local bgCol = {20/255,27/255,37/255}
--{43/255,57/255,77/255}
function love.load(args)
    love.graphics.setBackgroundColor(unpack(bgCol))
    Slab.SetINIStatePath(nil)
	Slab.Initialize {
        NoDocks = true
    }
    if love.system.getOS() == "Web" then
        Slab.SetScrollSpeed(1/6)
    else
        Slab.SetScrollSpeed(20)
    end
end

function love.update(dt)
    local w, h = love.graphics.getDimensions()
	Slab.Update(dt)

	Slab.BeginWindow('MainWindow', {
        --Title = "From Software Message Generator",
        X = 10, Y = -30,
        W = w-20, H = h+20,
        ShowMinimize = false,
        AutoSizeContent = false,
        AutoSizeWindow = false,
        AllowMove = false,
        AllowResize = false,
        BgColor = bgCol,
        NoOutline = true,
        --Border = 20, this breaks everything lol
    })

    local changedSettings

    -- Can we get some fucking breathing room in here, no borders do not work
    Slab.NewLine()
    Slab.NewLine()

    Slab.BeginLayout("TopSection", { Columns = 3, AlignX = "center"})
        Slab.SetLayoutColumn(1)
            if Slab.Button("Regenerate") then changedSettings = true end
            if Slab.Button("Copy to Clipboard") then
                love.system.setClipboardText(table.concat(results, "\n"))
            end

        Slab.SetLayoutColumn(2)
            Slab.Text("Number of Messages:", {Pad = 10})
            if Slab.Input('NumToGen',
                {Text = tostring(numMsgs),
                ReturnOnText = false,
                NumbersOnly = true, MinNumber = 1, MaxNumber = 500
            }) then
                numMsgs = Slab.GetInputNumber()
            end
        Slab.SetLayoutColumn(3)
            Slab.Text("Message Length:", {Pad = 10})
            if Slab.Input('MsgLen',
                {Text = tostring(msgLen),
                ReturnOnText = false,
                NumbersOnly = true, MinNumber = 1, MaxNumber = 5
            }) then
                msgLen = Slab.GetInputNumber()
                changedSettings = true
            end

    Slab.EndLayout()
    Slab.Separator{H = 20}

    Slab.BeginLayout("MainLayout", { Columns = 3, AlignX = "left"})



        Slab.SetLayoutColumn(1)
            Slab.Text("Templates:")
            if Slab.Button("All", { W = 24, H = 16}) then
                for _, game in ipairs(games) do
                    if not game.useForTemplate then changedSettings = true end
                    game.useForTemplate = true
                end
            end
            Slab.Separator()
            for _, game in ipairs(games) do
                if Slab.CheckBox(game.useForTemplate, game.name) then
                    game.useForTemplate = not game.useForTemplate
                    changedSettings = true
                end
            end


        Slab.SetLayoutColumn(2)
            Slab.Text("Words:")
            if Slab.CheckBox(not customWords, "Same as Templates") then
                for _, game in ipairs(games) do
                    if game.useForWords ~= game.useForTemplate then changedSettings = true end
                end
                customWords = not customWords
            end
            Slab.Separator()
            for _, game in ipairs(games) do
                if Slab.CheckBox(game.useForWords, game.name, {Disabled = not customWords}) then
                    game.useForWords = not game.useForWords
                    changedSettings = true
                end
            end


        Slab.SetLayoutColumn(3)
            Slab.Text("Conjunctions:")
            if Slab.CheckBox(not customConjunctions, "Same as Templates", { Disabled = msgLen == 1 }) then
                customConjunctions = not customConjunctions

                for _, game in ipairs(games) do
                    if game.hasConjunctions and game.useForConjunctions ~= game.useForTemplate then
                        changedSettings = true
                    end
                end
            end
            Slab.Separator()
            for _, game in ipairs(games) do
                if game.hasConjunctions then
                    if Slab.CheckBox(game.useForConjunctions, game.name, {
                        Disabled = msgLen == 1 or not customConjunctions,
                    }) then
                        game.useForConjunctions = not game.useForConjunctions
                        changedSettings = true
                    end
                else
                    Slab.Button("lol", {H = 16, Invisible = true})
                end

            end

    Slab.EndLayout()
    Slab.Separator{H = 20}

    if changedSettings then
        results = {}
    end
    if #results < numMsgs  then
        err = gen()
    end

    Slab.BeginLayout("lol this is the only way to center align text", { Columns = 1, AlignX = "center" })
    Slab.Textf("Messages:")
    Slab.EndLayout()

    Slab.BeginListBox('Messages', {W = w-25, StretchH = true})
    Slab.BeginLayout("Output", { Columns = 1, AlignX = "center" })
    Slab.SetLayoutColumn(1)

            Slab.NewLine()
            if err then Slab.Text(err)
            else
                for _, msg in ipairs(results) do
                    Slab.Textf(msg.."\n", { Pad = 5, W = w-40 , Align = "center"})
                end
            end

    Slab.EndLayout()
    Slab.EndListBox()




	Slab.EndWindow()
end


function love.draw()
	Slab.Draw()
end