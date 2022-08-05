---
toc: Keys Magic
summary: Spells and their information.
---
# Spell Commands
These commands are used in the Keys magic system.

`spells` - Shows you your own spell list.
`spells <name>` - Shows you <name>'s spell list.

`spellcount` - Shows you how many spells you know, and how many slots are open.

`spells/all` - Shows you a list of all the spells, divided by aspect.

`spell <spell>` - Shows you information about that spell.

`spell/scan` - Shows you all the spells and which characters know them.
`spell/scan <aspect>` - Shows you all the spells in a given aspect, and which characters know them.
`spell/scan <spell>` - Shows you which characters know that spell.

`spell/add <spell>[/<aspect>]` - Adds a spell to your spell list, if you meet the requirements. If the spell exists in more than one aspect, you need to specify which you want it to count toward (e.g., `spell/add Key Maker/Chaos` or `spell/add Key Maker/Law`)

`spell/note <spell>=<note>` - Sets a note specifying the target of an ongoing spell. Spells that currently take notes are Familiar (who/what is yours?), Favoured Item (what is it?), and Telepathy (if you have a standing mindlink, with whom?).

`spell/note <spell>` - Clears a note.

`cast <spell>` - Casts an unopposed spell you know.
`cast <name>/<spell>` - Casts an unopposed spell for another PC.
`cast <spell> <vs|on> <character>` - Casts an opposed spell on/vs another PC.
`cast <spell> <vs|on> <npc name>/<rating>` - Casts an opposed spell on/vs an NPC.
`cast/private <options>` - Shows results only to yourself.
