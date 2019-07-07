# WASM-WebGL
WASM experiment with D: a program that compiles to WebAssembly and renders graphics using WebGL 2.0. Requires LDC 1.11.0 or higher. Includes a simple js-side malloc, basic math functions, and a `web` package that allows to use Web APIs from D code.

## Usage
1. Install LDC, Node.js, Rollup
2. Compile WASM module:
   `dub build --build=release --compiler=ldc2`
3. Run:
   `npm run bundle`