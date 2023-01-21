From Software message generator
===
Generate random messages from the templates of any From Software game, or any combination of games.

Usage
---
This is a lua library. I might create a simple gui if there's interest.
```lua
local msg = require "FromSoftware-Message"
print( msg.des() )          -- demon's souls message
print( msg.ds1() )          -- dark souls 1 message
print( msg.ds2() )          -- dark souls 2 message
print( msg.ds3() )          -- dark souls 3 message
print( msg.bloodborne() )   -- bloodborne message
print( msg.sekiro() )       -- sekiro message
print( msg.eldenRing() )    -- elden ring message
print( msg.all() )          -- message based on every game's templates

-- combine games
local trilogy = msg.ds1 + msg.ds2 + msg.ds3
 -- message drawing from entire dark souls trilogy's templates
print( trilogy() )

-- 2 part message. For games that only supported single part messages,
-- (des, ds1, ds2) uses "." as a default conjunction.
print( msg.des(2) )

-- 2 part message using ds1 templates, but conjunctions from any game
print( msg.ds1(2, msg.all) )


-- If you just want the raw data:
local eldenRing = require "FromSoftware-Message.eldenRing"
-- The structure should be pretty much as in-game.
-- have a poke around in the source if unsure.
print( eldenRing.templates[1] ) -- "* ahead",
print( eldenRing.conjunctions[1] ) -- "and then"
print( eldenRing.words.battleTactics[1] ) -- "close-quarters battle"

```
### About Demon's Souls

Demon's Souls' message system works differently to any other From game, in that the words you can use depend on the template selected.

"Pure" Demon's Souls messages will remain faithful to ingame messages.
"Mixed game" messages will use the "terms" category as the DeS word list, and place no restrictions on the words used in DeS templates.

I hope this strikes a good balance between faithfulness and variety.