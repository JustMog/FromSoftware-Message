local PATH = (...).."."
local games = {
    des = require(PATH.."des"),
    ds1 = require(PATH.. "ds1"),
    ds2 = require(PATH.."ds2"),
    ds3 = require(PATH.."ds3"),
    bloodborne = require(PATH.."bloodborne"),
    sekiro = require(PATH.."sekiro"),
    eldenRing = require(PATH.."eldenRing"),
}
local templateWords = games.des.wordsByTemplate

local function deepIter(nested)
    local function recurse(t)
        for _, v in pairs(t) do
            if type(v) == "table" then
                recurse(v)
            else
                coroutine.yield(v)
            end
        end
    end
    return coroutine.wrap(function()
        recurse(nested)
    end)
end

local function union(...)
    local set = {}
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        for _, v in ipairs(t) do
            set[v] = true
        end
    end

    local res = {}
    for v in pairs(set) do
        table.insert(res, v)
    end
    return res
end

local mt
mt = {
    __add = function(a, b)
        local res = {}
        for k in pairs(a) do
            res[k] = union(a[k], b[k])
        end
        return setmetatable(res, mt)
    end
}

for gameName, game in pairs(games) do
    local flattened = {
        templates = {},
        conjunctions = {},
        words = {},
    }
    for template in deepIter(game.templates) do
        table.insert(flattened.templates, template)
    end

    for _, conjunction in ipairs(game.conjunctions or {}) do
        table.insert(flattened.conjunctions, conjunction)
    end

    for word in deepIter(game.words) do
        table.insert(flattened.words, word)
    end

    games[gameName] = setmetatable(flattened, mt)
    games.all = games.all and (games.all + flattened) or flattened
end

local function choose(t)
    return t[math.random(#t)]
end

local function getTemplate(templates)
    local res
    -- make templates without wildcards less likely
    for _ = 1, 5 do
        res = choose(templates)
        if res:find("*") then return res end
    end
    return res
end

local function getWord(game, template)
    if game == games.des and templateWords[template] then
        return choose(templateWords[template])
    end
    return choose(game.words)
end

local function getConjunction(conjunctions, sentence)
    local sentenceEndsInPunctuation = sentence:find("%p", -1)

if #conjunctions == 0 then return sentenceEndsInPunctuation and "" or "." end
    local conjunction = choose(conjunctions)


    local conjunctionStartsWithPunctiation = conjunction:find("%p", 1)

    if sentenceEndsInPunctuation and conjunctionStartsWithPunctiation then
        return ""
    end

    -- space before any nonpunctuation conjunction
    if not conjunctionStartsWithPunctiation then
        conjunction = " " .. conjunction
    end
    return conjunction

end


local function generate(game, len, conjunctionsFromGame)
    len = len or 1
    game = game or games.all
    local conjunctions = (conjunctionsFromGame or game).conjunctions
    local sentence

    for i = 1, len do
        local template = getTemplate(game.templates)
        local word = getWord(game, template)
        local clause = template:gsub("*", word)

        if sentence then
            local conjunction = getConjunction(conjunctions, sentence)
            sentence = ("%s%s %s"):format(sentence, conjunction, clause)
        else
            sentence = clause
        end
    end

    return sentence

end

mt.__call = generate

-- for i = 1, 3 do
--     for _ = 1, 4 do
--         print(message.generate(msg.all, i))
--     end
-- end

return games