ldc2 -mtriple=wasm32-unknown-unknown-wasm -betterC -O -release -link-internally -L-allow-undefined -Isrc --of=html/main.wasm src/main.d src/math.d
