# wasm-webgl
WebAssembly experiment with D: a cross-platform program that can be compiled both to machine code or wasm and renders graphics using OpenGL3/WebGL2. Requires LDC 1.11.0 or higher. Includes a simple js-side malloc, basic math functions, and a `web` package that allows to use Web APIs from D code.

[![Screenshot](screenshot.jpg)](screenshot.jpg)

## Usage
By default this project targets desktop platforms. To compile WebAssembly do the following:
1. Install LDC, Node.js, Rollup
2. Build wasm module:
   `dub build --config=web --build=release --compiler=ldc2`
3. Run:
   `npm run bundle`
