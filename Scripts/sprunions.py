import json

with open("../sprunions.txt", "r") as f:
    lines = [l.strip().split(",") for l in f.readlines()]
tiles = []
for l in lines:
    tiles.append(
        {
            "x": int(l[0]),
            "y": int(l[1]),
            "placeable": bool(int(l[2])),
            "hoeable": bool(int(l[3])),
        }
    )
print(tiles[0])

with open("sprunions.json", "w") as f:
    json.dump(tiles, f, indent=2)
