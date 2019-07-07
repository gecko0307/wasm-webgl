module main;

import std.traits;
import core;
import web;

extern(C):

extern(C++) class Foo
{
    int x;
    float y;
    this(int v, float v2)
    {
        x = v;
        y = v2;
    }
}

struct Bar
{
    int x;
    float y;
    this(int v, float v2)
    {
        x = v;
        y = v2;
    }
}

enum VertexAttrib
{
    Vertices = 0,
    Normals = 1,
    Texcoords = 2
}

extern(C) struct Application
{
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
    
    out vec3 position;
    
    uniform mat4 projectionMatrix;
    uniform mat4 modelViewMatrix;
	
    void main(void)
    {
        vec4 pos = projectionMatrix * modelViewMatrix * vec4(va_Vertex, 1.0);
        position = pos.xyz;
        gl_Position = pos;
    }
    ";
    
    string fragmentShader =
    "#version 300 es
    precision highp float;
    
    in vec3 position;
    
    out vec4 frag_color;
    
    void main(void)
    {
        frag_color = vec4(1.0, 1.0, 0.0, 1.0);
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
        gl.clearColor(0.5, 0.5, 0.5, 1.0);
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
        
        projectionMatrix = orthoMatrix(0, canvasWidth, canvasHeight, 0, 0, 100);
        projectionMatrixLoc = webglGetUniformLocation(shaderProgram, pMat1.length, cast(ubyte*)pMat1.ptr);
        
        auto t = translationMatrix(canvasWidth * 0.5, canvasHeight * 0.5, 0);
        auto s = scaleMatrix(100, 100, 100);
        modelViewMatrix = multMatrix(t, s);
        modelViewMatrixLoc = webglGetUniformLocation(shaderProgram, pMat2.length, cast(ubyte*)pMat2.ptr);
        
        Bar* b = New!Bar(100, 0.5f);
        consoleLog(b.y);
        
        int[] arr = New!(int[])(20);
        arr[1] = 5;
        consoleLog(arr[1]);
        
        /*
        Bar* b = New!Bar(100, 0.5f);
        consoleLog(b.y);
        
        int[] arr = New!(int[])(20);
        arr[1] = 5;
        consoleLog(arr[1]);
        */
    }
    
    void onUpdate(double dt)
    {
    }
    
    void onRender()
    {
        webglClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        webglUseProgram(shaderProgram);
        
        webglUniformMatrix4fv(projectionMatrixLoc, false, cast(ubyte*)projectionMatrix.ptr);
        webglUniformMatrix4fv(modelViewMatrixLoc, false, cast(ubyte*)modelViewMatrix.ptr);
        
        webglBindVertexArray(vao);
        webglDrawElements(GL_TRIANGLES, cast(uint)indices.length, GL_UNSIGNED_SHORT, 0);
        webglBindVertexArray(0);
        
        webglUseProgram(0);
    }
    
    void onResize(int cw, int ch)
    {
        gl.viewport(0, 0, cw, ch);
        canvasWidth = cw;
        canvasHeight = ch;
        projectionMatrix = orthoMatrix(0, canvasWidth, canvasHeight, 0, 0, 100);
        
        auto t = translationMatrix(canvasWidth * 0.5, canvasHeight * 0.5, 0);
        auto s = scaleMatrix(100, 100, 100);
        modelViewMatrix = multMatrix(t, s);
    }
}

__gshared Application app;

int loop(double dt)
{
    app.onUpdate(dt);
    app.onRender();
    return 0;
}

int resize(int cw, int ch)
{
    app.onResize(cw, ch);
    return 0;
}

int init(int cw, int ch)
{
    app.create(cw, ch);
    return 0;
}

void _start() {}
