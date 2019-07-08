# wasm-webgl
WebAssembly experiment with D: a cross-platform program that can be compiled both to machine code or wasm. It renders graphics using OpenGL 3.3 or WebGL 2, includes a simple js-side malloc and a basic `betterC` math library.

[![Screenshot](screenshot.jpg)](screenshot.jpg)

## Usage
By default this project targets desktop platforms. To compile WebAssembly do the following:
1. Install latest LDC, Node.js, Rollup
2. Build wasm module:
   `dub build --config=web --build=release --compiler=ldc2`
3. Run:
   `npm run bundle`

Or you can just run the bundle in `dist` folder using your preferred web server for a quick test.