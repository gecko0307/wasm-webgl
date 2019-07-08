(function () {
    'use strict';

    var canvas = document.getElementById("canv-main");
    canvas.width = canvas.clientWidth;
    canvas.height = canvas.clientHeight;
    var gl = canvas.getContext("webgl2");
    gl.viewport(0, 0, canvas.clientWidth, canvas.clientHeight);
    gl.enable(gl.DEPTH_TEST);
    gl.depthFunc(gl.LESS);
    var wasmInstance;
    var wasmMemory;
    var stringCache = {};
    var arrayCache = {};
    var buffers = [];
    var vaos = [];
    var shaders = [];
    var programs = [];
    var locations = [];
    var pageSize = 64 * 1024;
    function malloc(size) {
      var offset = wasmMemory.grow(size / pageSize + size % pageSize);
      return offset;
    }
    function free(buf) {
    }
    function getString(bufferOffset, bufferLen) {
      if (bufferOffset in stringCache) return stringCache[bufferOffset];
      var buf = new Uint8Array(wasmMemory.buffer, bufferOffset, bufferLen);
      var s = "";
      for (var i = 0; i < bufferLen; i++) {
        s += String.fromCharCode(buf[i]);
      }
      stringCache[bufferOffset] = s;
      return s;
    }
    function getFloat32Array(bufferOffset, bufferLen) {
      if (bufferOffset in arrayCache) return arrayCache[bufferOffset];
      var buf = new Float32Array(wasmMemory.buffer, bufferOffset, bufferLen);
      arrayCache[bufferOffset] = buf;
      return buf;
    }
    function glViewport(x, y, w, h) {
      gl.viewport(x, y, w, h);
    }
    function glClearColor(r, g, b, a) {
      gl.clearColor(r, g, b, a);
    }
    function glClear(mask) {
      gl.clear(mask);
    }
    function glCreateBuffer() {
      buffers.push(gl.createBuffer());
      return buffers.length;
    }
    function glBindBuffer(target, buff) {
      if (buff == 0) gl.bindBuffer(target, null);else gl.bindBuffer(target, buffers[buff - 1]);
    }
    function glBufferData(target, len, offset, usage) {
      var buf;
      if (target == gl.ELEMENT_ARRAY_BUFFER) buf = new Uint16Array(wasmMemory.buffer, offset, len);else buf = new Float32Array(wasmMemory.buffer, offset, len);
      gl.bufferData(target, buf, usage);
    }
    function glCreateVertexArray() {
      vaos.push(gl.createVertexArray());
      return vaos.length;
    }
    function glBindVertexArray(vao) {
      if (vao == 0) gl.bindVertexArray(null);else gl.bindVertexArray(buffers[vaos - 1]);
    }
    function glEnableVertexAttribArray(index) {
      gl.enableVertexAttribArray(index);
    }
    function glVertexAttribPointer(index, size, type, normalized, stride, offset) {
      gl.vertexAttribPointer(index, size, type, normalized, stride, offset);
    }
    function glDrawElements(mode, count, type, offset) {
      gl.drawElements(mode, count, type, offset);
    }
    function glCreateShader(type) {
      shaders.push(gl.createShader(type));
      return shaders.length;
    }
    function glShaderSource(shader, length, offset) {
      var code = getString(offset, length);
      gl.shaderSource(shaders[shader - 1], code);
    }
    function glCompileShader(shader) {
      gl.compileShader(shaders[shader - 1]);
      if (!gl.getShaderParameter(shaders[shader - 1], gl.COMPILE_STATUS)) console.log(gl.getShaderInfoLog(shaders[shader - 1]));
    }
    function glCreateProgram() {
      programs.push(gl.createProgram());
      return programs.length;
    }
    function glAttachShader(program, shader) {
      gl.attachShader(programs[program - 1], shaders[shader - 1]);
    }
    function glLinkProgram(program) {
      gl.linkProgram(programs[program - 1]);
    }
    function glUseProgram(program) {
      if (program == 0) gl.useProgram(null);else gl.useProgram(programs[program - 1]);
    }
    function glGetUniformLocation(program, length, offset) {
      var str = getString(offset, length);
      var loc = gl.getUniformLocation(programs[program - 1], str);
      locations.push(loc);
      return locations.length;
    }
    function glUniformMatrix4fv(location, transpose, offset) {
      if (location != 0) {
        var data = getFloat32Array(offset, 16);
        gl.uniformMatrix4fv(locations[location - 1], transpose, data);
      }
    }
    var request = new XMLHttpRequest();
    request.open('GET', 'main.wasm');
    request.responseType = 'arraybuffer';
    request.onload = function () {
      var wasmBuffer = request.response;
      var importObject = {
        env: {
          consoleLog: console.log,
          malloc: malloc,
          free: free,
          glViewport: glViewport,
          glClearColor: glClearColor,
          glClear: glClear,
          glCreateBuffer: glCreateBuffer,
          glBindBuffer: glBindBuffer,
          glBufferData: glBufferData,
          glCreateVertexArray: glCreateVertexArray,
          glBindVertexArray: glBindVertexArray,
          glEnableVertexAttribArray: glEnableVertexAttribArray,
          glVertexAttribPointer: glVertexAttribPointer,
          glDrawElements: glDrawElements,
          glCreateShader: glCreateShader,
          glShaderSource: glShaderSource,
          glCompileShader: glCompileShader,
          glCreateProgram: glCreateProgram,
          glAttachShader: glAttachShader,
          glLinkProgram: glLinkProgram,
          glUseProgram: glUseProgram,
          glGetUniformLocation: glGetUniformLocation,
          glUniformMatrix4fv: glUniformMatrix4fv
        }
      };
      WebAssembly.instantiate(wasmBuffer, importObject).then(function (result) {
        wasmInstance = result.instance;
        wasmMemory = wasmInstance.exports.memory;
        var exports = result.instance.exports;
        var ret = exports.init(canvas.clientWidth, canvas.clientHeight);
        setInterval(function () {
          wasmInstance.exports.loop(1.0 / 60.0);
        }, 1000 / 60);
        window.onresize = function (event) {
          canvas.width = canvas.clientWidth;
          canvas.height = canvas.clientHeight;
          wasmInstance.exports.resize(canvas.width, canvas.height);
        };
      });
    };
    request.send();

}());
//# sourceMappingURL=main.js.map
