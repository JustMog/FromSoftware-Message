local games = {
    ds1 = require "ds1",
    ds2 = require "ds2",
    bloodborne = require "bloodborne",
    eldenRing = require "eldenRing",
}

local function deepCopyAsSet(t, into)
    local res = into or {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            res[k] = deepCopyAsSet(v, res[k])
        else
            res[v] = true
        end
    end
    return res
end

local function deepSetToList(t)
    local list = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            deepSetToList(v)
        else
            table.insert(list, k)
        end
    end
    for i, v in ipairs(list) do
        t[i] = v
        t[v] = nil
    end
end

local function combine(tables)
    local res = {}
    for _, t in pairs(tables) do
        res = deepCopyAsSet(t, res)
    end
    deepSetToList(res)
    return res
end

for _, game in pairs(games) do
    local allWords = {}
    for _, category in pairs(game.words) do
        for _, word in ipairs(category) do
            table.insert(allWords, word)
        end
    end
    game.words = allWords

    setmetatable(game, {
        __add = function(self, other)
            return combine({self, other})
        end
    })
end

do local all
    for _, v in pairs(games) do
        if not all then all = v
        else all = all + v end
    end
    games.all = all
end

local function deepPrint(t, indent)
    indent = indent or ""
    if t[1] then
        for i, v in ipairs(t) do
            print((indent.."%i: %s"):format(i, v))
        end
    end

    for k, v in pairs(t) do
        if type(k) ~= "number" then
            if type(v) == "table" then
                print((indent.."%s:"):format(k))
                deepPrint(v, indent.."        ")
            else
                print((indent.."%s: %s"):format(k, v))
            end
        end
    end

end

local function choose(t)
    if t[1] then
        return t[math.random(#t)]
    end
    local list = {}
    for k, v in pairs(t) do
        table.insert(list, v)
    end
    return choose(list)
end

local function getConjunction(conjunctions, sentence)
    local conjunction = choose(conjunctions)

    local sentenceEndsInPunctuation = sentence:find("%p", -1)
    local conjunctionStartsWithPunctiation = conjunction:find("%p", 1)

    if sentenceEndsInPunctuation and conjunctionStartsWithPunctiation then
        return " "
    end
    -- space after any nonempty conjunction
    conjunction = conjunction .. " "

    -- space before any nonpunctuation conjunction
    if not conjunctionStartsWithPunctiation then
        conjunction = " " .. conjunction
    end
    return conjunction

end

local function generate(numClauses, game, conjunctionsFromGame)
    game = game or combine(games)

    if conjunctionsFromGame then
        game.conjunctions = conjunctionsFromGame.conjunctions
    end
    if not game.conjunctions then
        numClauses = 1
    end

    local sentence
    for i = 1, numClauses do
        local clause = choose(game.templates)
        local word = choose(game.words)
        clause = clause:gsub("*", word)

        if sentence == nil then
            sentence = clause
        else
            local conjunction = getConjunction(game.conjunctions, sentence)
            sentence = ("%s%s%s"):format(sentence, conjunction, clause)
        end
    end
    return sentence
end

-- for i = 1, 2 do
--     for _ = 1, 8 do
--         print(generate(i, games.ds1, games.all))
--     end
-- end

return setmetatable(games,{
    __call = function(_, ...) return generate(...) end
})