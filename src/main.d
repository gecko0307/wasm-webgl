module main;

import std.traits;
import core;
import web;

extern(C):

/*
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
*/

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
        0.0, -1.0, 0.0,
        -1.0, 1.0, 0.0,
        1.0, 1.0, 0.0,
    ];

    ushort[] indices = [
        0,  1,  2
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
        position = va_Vertex * 0.5 + 0.5;
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
        frag_color = vec4(position, 1.0);
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
        glClearColor(0.5, 0.5, 0.5, 1.0);
        vbo = glCreateBuffer();
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length , cast(ubyte*)vertices.ptr, GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        eao = glCreateBuffer();
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eao);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length, cast(ubyte*)indices.ptr, GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        vao = glCreateVertexArray();
        glBindVertexArray(vao);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eao);
        
        glEnableVertexAttribArray(VertexAttrib.Vertices);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glVertexAttribPointer(VertexAttrib.Vertices, 3, GL_FLOAT, false, 0, 0);
        
        /*
        //TODO:
        webglEnableVertexAttribArray(VertexAttrib.Normals);
        webglBindBuffer(GL_ARRAY_BUFFER, nbo);
        webglVertexAttribPointer(VertexAttrib.Normals, 3, GL_FLOAT, false, 0, 0);
    
        webglEnableVertexAttribArray(VertexAttrib.Texcoords);
        webglBindBuffer(GL_ARRAY_BUFFER, tbo);
        webglVertexAttribPointer(VertexAttrib.Texcoords, 2, GL_FLOAT, false, 0, 0);
        */
        
        glBindVertexArray(0);
        
        vs = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vs, vertexShader.length, cast(ubyte*)vertexShader.ptr);
        glCompileShader(vs);
        
        fs = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fs, fragmentShader.length, cast(ubyte*)fragmentShader.ptr);
        glCompileShader(fs);
        
        shaderProgram = glCreateProgram();
        
        glAttachShader(shaderProgram, vs);
        glAttachShader(shaderProgram, fs);
        
        glLinkProgram(shaderProgram);
        
        projectionMatrix = orthoMatrix(0, canvasWidth, canvasHeight, 0, -1000, 1000);
        projectionMatrixLoc = glGetUniformLocation(shaderProgram, pMat1.length, cast(ubyte*)pMat1.ptr);
        
        auto t = translationMatrix(canvasWidth * 0.5, canvasHeight * 0.5, 0);
        auto s = scaleMatrix(100, 100, 100);
        modelViewMatrix = multMatrix(t, s);
        modelViewMatrixLoc = glGetUniformLocation(shaderProgram, pMat2.length, cast(ubyte*)pMat2.ptr);
        
        /*
        Bar* b = New!Bar(100, 0.5f);
        consoleLog(b.y);
        
        int[] arr = New!(int[])(20);
        arr[1] = 5;
        consoleLog(arr[1]);
        */
    }
    
    float time = 0.0f;
    
    void onUpdate(double dt)
    {
        time += dt;
        auto t = translationMatrix(canvasWidth * 0.5, canvasHeight * 0.5, 0);
        auto r = rotationMatrix(1, time);
        auto s = scaleMatrix(200, 200, 200);
        auto tmp = multMatrix(t, r);
        modelViewMatrix = multMatrix(tmp, s);
    }
    
    void onRender()
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glUseProgram(shaderProgram);
        
        glUniformMatrix4fv(projectionMatrixLoc, false, cast(ubyte*)projectionMatrix.ptr);
        glUniformMatrix4fv(modelViewMatrixLoc, false, cast(ubyte*)modelViewMatrix.ptr);
        
        glBindVertexArray(vao);
        glDrawElements(GL_TRIANGLES, cast(uint)indices.length, GL_UNSIGNED_SHORT, 0);
        glBindVertexArray(0);
        
        glUseProgram(0);
    }
    
    void onResize(int cw, int ch)
    {
        glViewport(0, 0, cw, ch);
        canvasWidth = cw;
        canvasHeight = ch;
        projectionMatrix = orthoMatrix(0, canvasWidth, canvasHeight, 0, -1000, 1000);
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
