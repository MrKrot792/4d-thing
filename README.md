# What is 4d-thing?
4d-thingy/4d-thing - is a small "engine" that can render 4d objects. There's no much yet, hopefully the engine will evolve.

# Hot to build.
## Linux.
### For linux.
```bash
git clone https://github.com/MrKrot792/4d-thing
cd 4d-thing 
zig build -Doptimize=ReleaseFast run
```

### For Windows.
```bash
git clone https://github.com/MrKrot792/4d-thing
cd 4d-thing 
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-windows-gnu run
```

## Windows.
Not sure how it works on Windows, but it's probably just `zig build`.
