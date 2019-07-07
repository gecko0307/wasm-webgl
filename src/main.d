module main;

import std.traits;
import memory;
import math;
import js;
import webgl2;

enum psize = 8;
__gshared ulong _allocatedMemory = 0;

extern(C):

T allocate(T, A...) (A args) if (is(T == class))
{
    enum size = __traits(classInstanceSize, T);
    void* p = cast(void*)malloc(size);
    consoleLog(cast(size_t)p);
    T c = cast(T)p;
    return c;
}

alias New = allocate;

extern(C++) class Foo
{
    int x;
}

double benchmark()
{
    double r;
    for (int i = 0; i < 10000000; i++)
        r = sqrt(i);
    return r;
}

enum VertexAttrib
{
    Vertices = 0,
    Normals = 1,
    Texcoords = 2
}

extern(C) struct Application
{
    enum int fps = 60;
    enum double dt = 1.0 / fps;

    int canvasWidth;
    int canvasHeight;
    
    float[] vertices = [
        -1.0, -1.0,  1.0,
        1.0, -1.0,  1.0,
        1.0,  1.0,  1.0,
        -1.0,  1.0,  1.0,
        
        -1.0, -1.0, -1.0,
        -1.0,  1.0, -1.0,
        1.0,  1.0, -1.0,
        1.0, -1.0, -1.0,

        -1.0,  1.0, -1.0,
        -1.0,  1.0,  1.0,
        1.0,  1.0,  1.0,
        1.0,  1.0, -1.0,

        -1.0, -1.0, -1.0,
        1.0, -1.0, -1.0,
        1.0, -1.0,  1.0,
        -1.0, -1.0,  1.0,

        1.0, -1.0, -1.0,
        1.0,  1.0, -1.0,
        1.0,  1.0,  1.0,
        1.0, -1.0,  1.0,

        -1.0, -1.0, -1.0,
        -1.0, -1.0,  1.0,
        -1.0,  1.0,  1.0,
        -1.0,  1.0, -1.0
    ];

    ushort[] indices = [
        0,  1,  2,      0,  2,  3,    // front
        4,  5,  6,      4,  6,  7,    // back
        8,  9,  10,     8,  10, 11,   // top
        12, 13, 14,     12, 14, 15,   // bottom
        16, 17, 18,     16, 18, 19,   // right
        20, 21, 22,     20, 22, 23    // left
    ];
    
    void create(int w, int h)
    {
        canvasWidth = w;
        canvasHeight = h;
        
        onAllocate();
    }
    
    uint vbo;
    uint eao;
    uint vao;
    
    uint vs;
    uint fs;
    
    string vertexShader = 
    "#version 300 es
    precision highp float;
    
    layout (location = 0) in vec3 va_Vertex;
    
    uniform mat4 projectionMatrix;
    uniform mat4 modelViewMatrix;
				
    void main(void)
    {
        vec4 pos = projectionMatrix * modelViewMatrix * vec4(va_Vertex, 1.0);
        gl_Position = pos;
    }
    ";
    
    string fragmentShader =
    "#version 300 es
    precision highp float;
    
    out vec4 frag_color;
    
    void main(void)
    {
        frag_color = vec4(1.0, 1.0, 1.0, 1.0);
    }";
    
    uint shaderProgram;
    
    string pMat1 = "projectionMatrix";
    float[16] projectionMatrix;
    uint projectionMatrixLoc;
    
    string pMat2 = "modelViewMatrix";
    float[16] modelViewMatrix;
    uint modelViewMatrixLoc;
    
    void onAllocate()
    {
        webglClearColor(0.5, 0.5, 0.5, 1.0);
        vbo = webglCreateBuffer();
        webglBindBuffer(GL_ARRAY_BUFFER, vbo);
        webglBufferData(GL_ARRAY_BUFFER, vertices.length , cast(ubyte*)vertices.ptr, GL_STATIC_DRAW);
        webglBindBuffer(GL_ARRAY_BUFFER, 0);
        
        eao = webglCreateBuffer();
        webglBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eao);
        webglBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length, cast(ubyte*)indices.ptr, GL_STATIC_DRAW);
        webglBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        vao = webglCreateVertexArray();
        webglBindVertexArray(vao);
        webglBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eao);
        
        webglEnableVertexAttribArray(VertexAttrib.Vertices);
        webglBindBuffer(GL_ARRAY_BUFFER, vbo);
        webglVertexAttribPointer(VertexAttrib.Vertices, 3, GL_FLOAT, false, 0, 0);
        /*
        //TODO:
        webglEnableVertexAttribArray(VertexAttrib.Normals);
        webglBindBuffer(GL_ARRAY_BUFFER, nbo);
        webglVertexAttribPointer(VertexAttrib.Normals, 3, GL_FLOAT, false, 0, 0);
    
        webglEnableVertexAttribArray(VertexAttrib.Texcoords);
        webglBindBuffer(GL_ARRAY_BUFFER, tbo);
        webglVertexAttribPointer(VertexAttrib.Texcoords, 2, GL_FLOAT, false, 0, 0);
        */
        
        webglBindVertexArray(0);
        
        vs = webglCreateShader(GL_VERTEX_SHADER);
        webglShaderSource(vs, vertexShader.length, cast(ubyte*)vertexShader.ptr);
        webglCompileShader(vs);
        
        fs = webglCreateShader(GL_FRAGMENT_SHADER);
        webglShaderSource(fs, fragmentShader.length, cast(ubyte*)fragmentShader.ptr);
        webglCompileShader(fs);
        
        shaderProgram = webglCreateProgram();
        
        webglAttachShader(shaderProgram, vs);
        webglAttachShader(shaderProgram, fs);
        
        webglLinkProgram(shaderProgram);
        
        projectionMatrix = orthoMatrix(0, canvasWidth, 0, canvasHeight, 0, 100);
        projectionMatrixLoc = webglGetUniformLocation(shaderProgram, pMat1.length, cast(ubyte*)pMat1.ptr);
        
        auto t = translationMatrix(0, 0, 0);
        auto s = scaleMatrix(100, 100, 100);
        modelViewMatrix = multMatrix(t, s);
        modelViewMatrixLoc = webglGetUniformLocation(shaderProgram, pMat2.length, cast(ubyte*)pMat2.ptr);
        
        Foo foo = New!Foo();
        foo.x = 100;
        consoleLog(foo.x);
    }
    
    void onUpdate(double dt)
    {
    }
    
    void onRender()
    {
        webglClear(WEBGL_COLOR_BUFFER_BIT | WEBGL_DEPTH_BUFFER_BIT);
        
        webglUseProgram(shaderProgram);
        
        webglUniformMatrix4fv(projectionMatrixLoc, false, cast(ubyte*)projectionMatrix.ptr);
        webglUniformMatrix4fv(modelViewMatrixLoc, false, cast(ubyte*)modelViewMatrix.ptr);
        
        webglBindVertexArray(vao);
        webglDrawElements(GL_TRIANGLES, cast(uint)indices.length, GL_UNSIGNED_SHORT, 0);
        webglBindVertexArray(0);
        
        webglUseProgram(0);
    }
}

__gshared Application app;

int loop()
{
    app.onUpdate(app.dt);
    app.onRender();
    return 0;
}

int runCallback(int function() callback)
{
    return callback();
}

int main(int cw, int ch)
{
    app.create(cw, ch);
    consoleLog(app.canvasWidth);
    consoleLog(app.canvasHeight);
    setInterval(&loop, 1000 / app.fps);
    return 0;
}

void _start() {}
