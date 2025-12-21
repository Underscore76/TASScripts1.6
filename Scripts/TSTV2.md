# Needs:

Basic simulator for forward rng prediction

- really no way to get around it, need to be able to run 12-15 frames into the future

# Chores:

60836 -> Joja Cola, Herring (2 fish caught on beach day 2)

- Caroline pre-seeding for week 1
  - Meet day 1
  - Day 2 get quest, fish up joja cola and herring, talk, gift, turn in joja cola
  - Day 4 get quest, talk, gift, turn in herring
  - Day 5 talk
  - Day 6 talk
  - Day 7 walk into tea sapling room
- Tree books
  - find basic manip to get book from tree within X frames
- Farm clearing
  - distance from door and entrances (pre-compute all diffs and create weighted matrix)
  - live add distance from current location
  - sorted lowest distance tile that has something we can clear is selected, walk within range and hit
- Clay farming
  - calc spot time by distance from current tile \* movement speed + pickaxe time if needed
  - walk to range of lowest time tile and hit
- Fishing
  - dont manip catch time, but do manip caught fish
  - need to figure out better fishing solver
- Fishing weapon manip (min fishing level 2)
  - Manip a baller weapon
  - Do a catch and then wait on the catch menu until rng matches getting a weapon
- Forage map
  - find maps that have forage/artifact spots we can collect
  - map chain starts/ends at farm
    - bus stop, forest, town, mountain, backwoods
- Mines Depth
  - roll floor for nearby ladder spot
  - go down floor
  - walk to rock range
  - hit, leave
- Mines monster items
  - roll floor to have monster with item
  - go down floor
  - walk to monster range
  - fight?
- Mines dig spots
  - Get to mines floor
  - Wait for specific mines floor item (GOLD BARS)
