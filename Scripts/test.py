with open("../randomtraces.txt", "r") as f:
    lines = [x.strip() for x in f.readlines()]


class Node:
    line: str
    children: dict[str, "Node"]
    count: int

    def __init__(self, line):
        self.count = 0
        self.line = line
        self.children = {}

    def add_child(self, child: "Node"):
        self.count += 1
        # print("LINE:", self.line)
        # print("CHILD:", child.line if child is not None else None)
        # print()
        if child is not None and child.line not in self.children:
            self.children[child.line] = child


def get_call_blocks(lines: list[str], block: tuple[int, int]):
    calls = []
    block_start = block[0] + 1
    for i in range(block[0] + 1, block[1]):
        line = lines[i]
        if lines[i] == "":
            if block_start != i:
                calls.append(slice(block_start, i))
            block_start = i + 1
    if block_start != block[1]:
        calls.append(slice(block_start, block[1]))
    return calls


frame_blocks = []
block_start = 0
for i, line in enumerate(lines):
    if line.startswith("Frame"):
        if block_start != i:
            frame_blocks.append((block_start, i))
        block_start = i
frame_blocks.append((block_start, len(lines)))

player_blocks = []
for block in frame_blocks:
    players = []
    block_start = block[0] + 1
    for i in range(block[0] + 1, block[1]):
        line = lines[i]
        if line.strip().startswith("Player"):
            if block_start != i:
                players.append((block_start, i))
            block_start = i + 1
    if block_start != block[1]:
        players.append((block_start, block[1]))
    player_blocks.append(players)

print(player_blocks)
all_calls = []
for blocks in player_blocks:
    block = blocks[0]
    calls = get_call_blocks(lines, block)
    all_calls.extend(calls)

nodes: dict[str, Node] = {}
for call in all_calls:
    prev_node = None
    for line in lines[call]:
        if line not in nodes:
            nodes[line] = Node(line)
        if prev_node is not None:
            nodes[line].add_child(prev_node)
            # prev_node.add_child(nodes[line])
        prev_node = nodes[line]

# frame_blocks = []
# block_start = 0
# for i, line in enumerate(lines):
#     if line.startswith("Frame"):
#         if block_start != i:
#             frame_blocks.append((block_start, i))
#         block_start = i
# frame_blocks.append((block_start, len(lines)))
# all_calls = []
# for block in frame_blocks:
#     calls = get_call_blocks(lines, block)
#     all_calls.extend(calls)

# nodes: dict[str, Node] = {}

# for call in all_calls:
#     prev_node = None
#     for line in lines[call]:
#         if line not in nodes:
#             nodes[line] = Node(line)
#         if prev_node is not None:
#             nodes[line].add_child(prev_node)
#             # prev_node.add_child(nodes[line])
#         prev_node = nodes[line]
# break
# exit(0)
# print(len(nodes))
# for node in nodes:
#     print(f"{nodes[node].line}\t*{nodes[node].count}*\t{len(nodes[node].children)}")

# root = "at StardewModdingAPI.Framework.SGame.Update(GameTime gameTime) in SMAPI\\Framework\\SGame.cs:line 209"
end_frames = [
    "at System.Environment.get_StackTrace()",
    "at System.Linq.OrderedEnumerable`1.GetEnumerator()+MoveNext()",
]
# for node in nodes:
#     print(node)
# print(nodes[root].children)


def recurse_print(node: Node, depth=0):
    if node.line in end_frames:
        return
    print(node.line.rjust(len(node.line) + depth) + "\t\t" + str(node.count))
    for next_node in sorted(node.children, key=lambda x: -node.children[x].count):
        recurse_print(node.children[next_node], depth + 1)


print(len(frame_blocks))
roots = [
    "at StardewModdingAPI.Framework.SCore.OnPlayerInstanceUpdating_PatchedBy<underscore.tasmod>(SCore this, SGame instance, GameTime gameTime, Action runUpdate)",
    "at StardewModdingAPI.Framework.SGame._draw(GameTime gameTime, RenderTarget2D target_screen) in /home/pathoschild/git/SMAPI/src/SMAPI/Framework/SGame.cs:line 250",
]
for root in roots:
    if root in nodes:
        recurse_print(nodes[root])
