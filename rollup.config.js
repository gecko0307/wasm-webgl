import resolve from "rollup-plugin-node-resolve";
import commonjs from "rollup-plugin-commonjs";
import babel from "rollup-plugin-babel";
import serve from "rollup-plugin-serve";

export default {
    input: "js/main.js",
    output: {
        file: "dist/main.js",
        format: "iife",
        name: "main"
    },
    plugins: [
        resolve(),
        commonjs(),
        babel({
            exclude: "node_modules/**"
        }),
        serve({
            contentBase: "dist",
            port: 8000
        })
    ]
};
