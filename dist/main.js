(function () {
  'use strict';

  function ownKeys(object, enumerableOnly) {
    var keys = Object.keys(object);

    if (Object.getOwnPropertySymbols) {
      var symbols = Object.getOwnPropertySymbols(object);
      enumerableOnly && (symbols = symbols.filter(function (sym) {
        return Object.getOwnPropertyDescriptor(object, sym).enumerable;
      })), keys.push.apply(keys, symbols);
    }

    return keys;
  }

  function _objectSpread2(target) {
    for (var i = 1; i < arguments.length; i++) {
      var source = null != arguments[i] ? arguments[i] : {};
      i % 2 ? ownKeys(Object(source), !0).forEach(function (key) {
        _defineProperty(target, key, source[key]);
      }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(target, Object.getOwnPropertyDescriptors(source)) : ownKeys(Object(source)).forEach(function (key) {
        Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key));
      });
    }

    return target;
  }

  function _defineProperty(obj, key, value) {
    if (key in obj) {
      Object.defineProperty(obj, key, {
        value: value,
        enumerable: true,
        configurable: true,
        writable: true
      });
    } else {
      obj[key] = value;
    }

    return obj;
  }

  var wasmMemory;
  function memoryInit(mem) {
    wasmMemory = mem;
  }
  var pageSize = 64 * 1024;
  function malloc(size) {
    var offset = wasmMemory.grow(size / pageSize + size % pageSize);
    return offset;
  }
  function free(buf) {
  }
  function memorySymbols() {
    return {
      malloc: malloc,
      free: free
    };
  }

  var gl;
  var wasmMemory$1;
  function glInit(mem, canvas) {
    wasmMemory$1 = mem;
    gl = canvas.getContext("webgl2");
    return gl;
  }
  var stringCache = {};
  var arrayCache = {};
  function getString(bufferOffset, bufferLen) {
    if (bufferOffset in stringCache) return stringCache[bufferOffset];
    var buf = new Uint8Array(wasmMemory$1.buffer, bufferOffset, bufferLen);
    var s = "";
    for (var i = 0; i < bufferLen; i++) {
      s += String.fromCharCode(buf[i]);
    }
    stringCache[bufferOffset] = s;
    return s;
  }
  function getFloat32Array(bufferOffset, bufferLen) {
    if (bufferOffset in arrayCache) return arrayCache[bufferOffset];
    var buf = new Float32Array(wasmMemory$1.buffer, bufferOffset, bufferLen);
    arrayCache[bufferOffset] = buf;
    return buf;
  }
  var buffers = [];
  var vaos = [];
  var shaders = [];
  var programs = [];
  var locations = [];
  function glEnable(v) {
    gl.enable(v);
  }
  function glDisable(v) {
    gl.disable(v);
  }
  function glDepthFunc(f) {
    gl.depthFunc(f);
  }
  function glViewport(x, y, w, h) {
    gl.viewport(x, y, w, h);
  }
  function glClearColor(r, g, b, a) {
    gl.clearColor(r, g, b, a);
  }
  function glClearDepth(d) {
    gl.clearDepth(d);
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
    if (target == gl.ELEMENT_ARRAY_BUFFER) buf = new Uint16Array(wasmMemory$1.buffer, offset, len);else buf = new Float32Array(wasmMemory$1.buffer, offset, len);
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
  function glSymbols() {
    return {
      glEnable: glEnable,
      glDisable: glDisable,
      glDepthFunc: glDepthFunc,
      glViewport: glViewport,
      glClearColor: glClearColor,
      glClearDepth: glClearDepth,
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
    };
  }

  var wasmInstance, wasmMemory$2;
  var canvas = document.getElementById("canv-main");
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;
  var request = new XMLHttpRequest();
  request.open('GET', 'main.wasm');
  request.responseType = 'arraybuffer';
  request.onload = function () {
    var wasmBuffer = request.response;
    var importObject = {
      env: _objectSpread2(_objectSpread2({
        consoleLog: console.log
      }, memorySymbols()), glSymbols())
    };
    WebAssembly.instantiate(wasmBuffer, importObject).then(function (result) {
      wasmInstance = result.instance;
      wasmMemory$2 = wasmInstance.exports.memory;
      memoryInit(wasmMemory$2);
      var gl = glInit(wasmMemory$2, canvas);
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
