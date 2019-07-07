var canvas = document.getElementById("canv-main");
canvas.width = canvas.clientWidth;
canvas.height = canvas.clientHeight;

var gl = canvas.getContext("webgl2");

console.log(canvas.clientWidth, canvas.clientHeight);

gl.viewport(0, 0, canvas.clientWidth, canvas.clientHeight);
    
var wasmInstance;
var wasmMemory;
    
var stringCache = {
};
    
var arrayCache = {
};
    
var heap = [];
var buffers = [];
var vaos = [];
    
var shaders = [];
var programs = [];
var locations = [];
    
var pageSize = (64 * 1024);
    
function malloc(size)
{
    var offset = wasmMemory.grow(size / pageSize + size % pageSize);
    var buf = new Uint8Array(wasmMemory.buffer, offset, size);
    return offset;
}
    
function free(buf)
{
    //TODO
}
    
function getString(bufferOffset, bufferLen)
{
    if (bufferOffset in stringCache)
        return stringCache[bufferOffset];

    var buf = new Uint8Array(wasmMemory.buffer, bufferOffset, bufferLen);
    var s = "";
    for (var i = 0; i < bufferLen; i++) {
        s += String.fromCharCode(buf[i]);
    }
    stringCache[bufferOffset] = s;
    return s;
}
    
function getFloat32Array(bufferOffset, bufferLen)
{
    if (bufferOffset in arrayCache)
        return arrayCache[bufferOffset];

    var buf = new Float32Array(wasmMemory.buffer, bufferOffset, bufferLen);
    arrayCache[bufferOffset] = buf;
    return buf;
}
    
function webglClearColor(r, g, b, a)
{
    gl.clearColor(r, g, b, a);
}
    
function webglClear(mask)
{
    gl.clear(mask); 
}
    
function webglCreateBuffer()
{
    buffers.push(gl.createBuffer());
    return buffers.length;
}
    
function webglBindBuffer(target, buff)
{
    if (buff == 0)
        gl.bindBuffer(target, null);
    else
        gl.bindBuffer(target, buffers[buff - 1]);
}
    
function webglBufferData(target, len, offset, usage)
{
    var buf;
    if (target == gl.ELEMENT_ARRAY_BUFFER)
        buf = new Uint16Array(wasmMemory.buffer, offset, len);
    else
        buf = new Float32Array(wasmMemory.buffer, offset, len);
    gl.bufferData(target, buf, usage);
}
    
function webglCreateVertexArray()
{
    vaos.push(gl.createVertexArray());
    return vaos.length;
}
    
function webglBindVertexArray(vao)
{        
    if (vao == 0)
        gl.bindVertexArray(null);
    else
        gl.bindVertexArray(buffers[vaos - 1]);
}
    
function webglEnableVertexAttribArray(index)
{        
    gl.enableVertexAttribArray(index);
}
    
function webglVertexAttribPointer(index, size, type, normalized, stride, offset)
{
    gl.vertexAttribPointer(index, size, type, normalized, stride, offset);
}
    
function webglDrawElements(mode, count, type, offset)
{
    gl.drawElements(mode, count, type, offset);
}
    
function webglCreateShader(type)
{
    shaders.push(gl.createShader(type));
    return shaders.length;
}
    
function webglShaderSource(shader, length, offset)
{
    var code = getString(offset, length);
    gl.shaderSource(shaders[shader - 1], code);
}
    
function webglCompileShader(shader)
{
    gl.compileShader(shaders[shader - 1]);
    if (!gl.getShaderParameter(shaders[shader - 1], gl.COMPILE_STATUS))
        console.log(gl.getShaderInfoLog(shaders[shader - 1]));
}
    
function webglCreateProgram()
{        
    programs.push(gl.createProgram());
    return programs.length;
}
    
function webglAttachShader(program, shader)
{
    gl.attachShader(programs[program - 1], shaders[shader - 1]);
}
    
function webglLinkProgram(program)
{
    gl.linkProgram(programs[program - 1]);
}
    
function webglUseProgram(program)
{
    if (program == 0)
        gl.useProgram(null);
    else
        gl.useProgram(programs[program - 1])
}
    
function webglGetUniformLocation(program, length, offset)
{
    var str = getString(offset, length);
    var loc = gl.getUniformLocation(programs[program - 1], str);
    locations.push(loc);
    return locations.length;
}
    
function webglUniformMatrix4fv(location, transpose, offset)
{
    if (location != 0)
    {
        var data = getFloat32Array(offset, 16);
        gl.uniformMatrix4fv(locations[location - 1], transpose, data);
    }
}
    
const request = new XMLHttpRequest();
request.open('GET', 'main.wasm');
request.responseType = 'arraybuffer';
request.onload = () => {
    const wasmBuffer = request.response;
        
    const importObject = 
    {
        env: 
        {           
            consoleLog: console.log,
                
            malloc: malloc,
            free: free,

            webglClearColor: webglClearColor,
            webglClear: webglClear,
            webglCreateBuffer: webglCreateBuffer,
            webglBindBuffer: webglBindBuffer,
            webglBufferData: webglBufferData,
            webglCreateVertexArray: webglCreateVertexArray,
            webglBindVertexArray: webglBindVertexArray,
            webglEnableVertexAttribArray: webglEnableVertexAttribArray,
            webglVertexAttribPointer: webglVertexAttribPointer,
            webglDrawElements: webglDrawElements,
            webglCreateShader: webglCreateShader,
            webglShaderSource: webglShaderSource,
            webglCompileShader: webglCompileShader,
            webglCreateProgram: webglCreateProgram,
            webglAttachShader: webglAttachShader,
            webglLinkProgram: webglLinkProgram,
            webglUseProgram: webglUseProgram,
            webglGetUniformLocation: webglGetUniformLocation,
            webglUniformMatrix4fv: webglUniformMatrix4fv,
            
            setInterval: function(f, n)
            {
                setInterval(function()
                {
                    wasmInstance.exports.runCallback(f);
                }, n);
            }
        }
    };
    
    WebAssembly.instantiate(wasmBuffer, importObject).then(result => 
    {        
        wasmInstance = result.instance;
        wasmMemory = wasmInstance.exports.memory;
        const { exports } = result.instance;
        const ret = exports.main(canvas.clientWidth, canvas.clientHeight);
    });
};

request.send();
