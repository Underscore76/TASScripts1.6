import itertools
from collections import defaultdict

with open("randomtraces.txt", "r") as f:
    lines = f.readlines()

frame_traces = defaultdict(dict)
player_index = None
player_start = None
ptr = 0
while ptr < len(lines):
    line = lines[ptr].strip()
    if line.startswith("Frame"):
        if player_start is not None:
            frame_traces[frame_num][player_index] = lines[player_start:ptr]
        frame_num = int(line.split()[1].strip())
        ptr += 1
        player_start = None
        print(frame_num)
        continue
    elif line.startswith("Player"):
        if player_start is None:
            player_start = ptr
        else:
            frame_traces[frame_num][player_index] = lines[player_start:ptr]
        player_index = int(line.split()[1].strip())
        print("  Player", player_index, player_start)
        player_start = ptr
        ptr += 1
        continue
    ptr += 1

player_0_traces = [
    frame_traces[f][2] for f in sorted(frame_traces.keys()) if 2 in frame_traces[f]
]
player_0_traces = list(itertools.chain(*player_0_traces))
# player_0_traces = list(
#     itertools.chain(
#         *filter(
#             lambda x: any("_newDayAfterFade" in line for line in x), player_0_traces
#         )
#     )
# )

# index_of_farmcave = None
# for i, trace in enumerate(player_0_traces):
#     if "FarmCave" in trace:
#         index_of_farmcave = i
#         break

# if index_of_farmcave is not None:
#     player_0_traces = player_0_traces[: index_of_farmcave + 1]

print(f"Found {len(player_0_traces)} traces for player 0")
with open("cleaned_traces.txt", "w") as f:
    for trace in player_0_traces:
        f.write(trace)

# start_line = "at System.Environment.get_StackTrace()"
# final_line = (
#     # "at StardewValley.Game1.<>c.<newDayAfterFade>b__782_2() in Game1.cs:line 8549"
#     # "at StardewValley.Game1._newDayAfterFade()+MoveNext()"
#     "at StardewValley.Game1.Update(GameTime gameTime)"
# )

# blocks = []
# active = False
# cur_block = None
# counter = 0
# for line in map(lambda x: x.strip(), player_0_traces):
#     if line == start_line:
#         cur_block = [line]
#         counter += 1
#         active = True
#     elif line.startswith(final_line) and cur_block:
#         if any("RandomLong" in l for l in cur_block):
#             counter += 7
#         cur_block.append(f"{counter}:{line}")
#         if cur_block:
#             blocks.append(cur_block[::-1])
#         cur_block = None
#     elif cur_block:
#         cur_block.append(line)

# print(blocks[-1])
# with open("cleaned_traces.txt", "w") as f:
#     for block in blocks:
#         f.write("\n".join(block))
#         f.write("\n\n")
