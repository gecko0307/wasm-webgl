import { memoryInit, memorySymbols } from "./memory";
import { glInit, glSymbols } from "./glwrap";

var wasmInstance, wasmMemory;

const canvas = document.getElementById("canv-main");
canvas.width = canvas.clientWidth;
canvas.height = canvas.clientHeight;

const request = new XMLHttpRequest();
request.open('GET', 'main.wasm');
request.responseType = 'arraybuffer';
request.onload = () => {
    const wasmBuffer = request.response;
        
    const importObject = 
    {
        env: {
            consoleLog: console.log,
            ...memorySymbols(),
            ...glSymbols()
        }
    };
    
    WebAssembly.instantiate(wasmBuffer, importObject).then(result => 
    {        
        wasmInstance = result.instance;
        wasmMemory = wasmInstance.exports.memory;
        memoryInit(wasmMemory);
        const gl = glInit(wasmMemory, canvas);
        
        const { exports } = result.instance;
        const ret = exports.init(canvas.clientWidth, canvas.clientHeight);
        
        setInterval(function()
        {
            wasmInstance.exports.loop(1.0 / 60.0);
        }, 1000 / 60);
        
        window.onresize = function(event)
        {
            canvas.width = canvas.clientWidth;
            canvas.height = canvas.clientHeight;
            wasmInstance.exports.resize(canvas.width, canvas.height);
        };
    });
};

request.send();
