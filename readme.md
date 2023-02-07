From Software message generator
===
Generate random messages from the templates of any From Software game, or any combination of games.

# Usage
## Gui:
[Also available with web build on itch.io](https://iyashikei.itch.io/fromsoft-message-generator).
Simply download, unzip and run a release.
I can't test non-windows builds, sorry.
.love versions should work cross-platform, but you will need [Love](https://love2d.org/) installed.

### From source
You will need [Love](https://love2d.org/) installed and added to system PATH.
You will also have to clone recursively (for gui only, not to just use the library)
then:
```
cd FromSoftMessage
love .
```

Hopefully web version forthcoming but no luck so far
## Lua library:
```lua
local msg = require "FromsoftMessage"
print( msg.des() )          -- demon's souls message
print( msg.ds1() )          -- dark souls 1 message
print( msg.ds2() )          -- dark souls 2 message
print( msg.ds3() )          -- dark souls 3 message
print( msg.bloodborne() )   -- bloodborne message
print( msg.sekiro() )       -- sekiro message
print( msg.eldenRing() )    -- elden ring message
print( msg.all() )          -- message based on every game's templates

-- aliases
msg.bb()  -- msg.bloodborne()
msg.sek() -- msg.sekiro()
msg.er()  -- msg.eldenRing()

-- combine games
local trilogy = msg.ds1 + msg.ds2 + msg.ds3
 -- message drawing from entire dark souls trilogy's templates
print( trilogy() )

-- 2 part message. For games that only supported single part messages,
-- (des, ds1, ds2) "." is used as a default conjunction.
print( msg.des(2) )

-- 2 part message using ds1 templates, but conjunctions from any game
print( msg.ds1(2, { conjunctions = msg.all }) )
-- 2 part ds3 message with "." as conjunction
print( msg.ds3(2, { conjunctions = msg.none }) )

-- ds1 message template using words from bloodborne
print( msg.ds1(1, { words = msg.bloodborne }) )

-- can use combined games like this too
print( msg.ds1(1, {
    words = msg.des + msg.ds3
    conjunctions = msg.ds1 + msg.ds2
}) )


-- If you just want the raw data:
local eldenRing = require "FromsoftMessage.eldenRing"
-- The structure should be pretty much as in-game.
-- have a poke around in the source if unsure.
print( eldenRing.templates[1] ) -- "* ahead",
print( eldenRing.conjunctions[1] ) -- "and then"
print( eldenRing.words.battleTactics[1] ) -- "close-quarters battle"

```
### About Demon's Souls

Demon's Souls' message system works differently to any other From game, in that the words you can use depend on the template selected.

"Pure" Demon's Souls messages will remain faithful to ingame messages.
"Mixed game" messages will use the "terms" category in DeS for the DeS word list, and place no restrictions on the words used in DeS templates.

I hope this strikes a good balance between faithfulness and variety.