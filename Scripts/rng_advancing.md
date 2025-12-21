# RNG Advancing

Areas to explore

# Tree Leafy shaking

- for fully run tree on shake

```csharp
if (Game1.random.NextDouble() < 0.66)
{
    int numberOfLeaves2 = Game1.random.Next(1, 6);
    for (int j = 0; j < numberOfLeaves2; j++)
    {
        leaves.Add(new Leaf(new Vector2(Game1.random.Next((int)(tileLocation.X * 64f - 64f), (int)(tileLocation.X * 64f + 128f)), Game1.random.Next((int)(tileLocation.Y * 64f - 256f), (int)(tileLocation.Y * 64f - 192f))), (float)Game1.random.Next(-10, 10) / 100f, Game1.random.Next(4), (float)Game1.random.Next(5) / 10f));
    }
}
if (Game1.random.NextDouble() < 0.01 && (localSeason == Season.Spring || localSeason == Season.Summer))
{
    bool isIslandButterfly = Location.InIslandContext();
    while (Game1.random.NextDouble() < 0.8)
    {
        location.addCritter(new Butterfly(location, new Vector2(tileLocation.X + (float)Game1.random.Next(1, 3), tileLocation.Y - 2f + (float)Game1.random.Next(-1, 2)), isIslandButterfly));
    }
}
```

25 frames between tree shakes
max 5 leaves per shake -> 28 random calls assuming no butterflies

Butterflies are an option,

Spring butterfly is 7 calls on constructor
Summer butterfly is 9-11 calls on constructor

13 frame flap for 2-3 calls?

so at 300 butterflies you're getting maybe 300 / 13 \* 2.5 = ~57 calls per frame (takes a ton of time to build up to this, you'd want a 4 tree setup to get this many butterflies because you can only get butterflies from a tree at earliest every 25 frames)

# Torches

Each torch that is within 256px of your screen gets 3-6 updates a frame (3 guaranteed checks that could each rarely spawn a secondary check)

So with like 100 torches and really zoomed out view you're getting 300 guaranteed calls a frame

# Weather debris?

Worth looking at, I don't want to have to deal with it but it's probably similar to rain?

# nonsense

- forest is 3 checks per frame min
- clicking a character sprite on their social menu page with >= 4 hearts is 1 call
