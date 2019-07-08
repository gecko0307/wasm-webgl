module application;

version(WebAssembly)
{
    import wasmrt;
    import web;
}
else 
{
    version = Desktop;
    import std.string;
    import bindbc.opengl;
    import dlib.core.memory;
}

import matrix;

enum VertexAttrib: uint
{
    Vertices = 0,
    Normals = 1,
    Texcoords = 2
}

extern(C++) class Test
{
    int x;
    
    this(int x)
    {
        this.x = x;
        foo();
    }
    
    ~this()
    {
    }
    
    final void foo()
    {
    }
}

struct Application
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
        glViewport(0, 0, canvasWidth, canvasHeight);
        glClearColor(0.5, 0.5, 0.5, 1.0);
        glClearDepth(1.0);
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);
        glDisable(GL_CULL_FACE);
        
        version(WebAssembly)
        {
            vbo = glCreateBuffer();
        }
        else
        {
            glGenBuffers(1, &vbo);
        }
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        version(WebAssembly)
        {
            glBufferData(GL_ARRAY_BUFFER, vertices.length, cast(ubyte*)vertices.ptr, GL_STATIC_DRAW);
        }
        else
        {
            glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof * 3, cast(ubyte*)vertices.ptr, GL_STATIC_DRAW);
        }
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        version(WebAssembly)
        {
            eao = glCreateBuffer();
        }
        else
        {
            glGenBuffers(1, &eao);
        }
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eao);
        version(WebAssembly)
        {
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length, cast(ubyte*)indices.ptr, GL_STATIC_DRAW);
        }
        else
        {
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * ushort.sizeof * 3, cast(ubyte*)indices.ptr, GL_STATIC_DRAW);
        }
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        version(WebAssembly)
        {
            vao = glCreateVertexArray();
        }
        else
        {
            glGenVertexArrays(1, &vao);
        }
        glBindVertexArray(vao);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eao);
        
        glEnableVertexAttribArray(cast(uint)VertexAttrib.Vertices);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        version(WebAssembly)
        {
            glVertexAttribPointer(cast(uint)VertexAttrib.Vertices, 3, GL_FLOAT, false, 0, 0);
        }
        else
        {
            glVertexAttribPointer(cast(uint)VertexAttrib.Vertices, 3, GL_FLOAT, false, 0, null);
        }
        
        glBindVertexArray(0);
        
        vs = glCreateShader(GL_VERTEX_SHADER);
        version(WebAssembly)
        {
            glShaderSource(vs, vertexShader.length, cast(ubyte*)vertexShader.ptr);
        }
        else
        {
            const char* vertexShaderSrc = vertexShader.ptr;
            GLint vertexShaderLen = cast(GLint)vertexShader.length;
            glShaderSource(vs, 1, &vertexShaderSrc, &vertexShaderLen);
        }
        glCompileShader(vs);
        
        fs = glCreateShader(GL_FRAGMENT_SHADER);
        version(WebAssembly)
        {
            glShaderSource(fs, fragmentShader.length, cast(ubyte*)fragmentShader.ptr);
        }
        else
        {
            const char* fragmentShaderSrc = fragmentShader.ptr;
            GLint fragmentShaderLen = cast(GLint)fragmentShader.length;
            glShaderSource(fs, 1, &fragmentShaderSrc, &fragmentShaderLen);
        }
        glCompileShader(fs);
        
        shaderProgram = glCreateProgram();
        
        glAttachShader(shaderProgram, vs);
        glAttachShader(shaderProgram, fs);
        
        glLinkProgram(shaderProgram);
        
        projectionMatrix = orthoMatrix(0, canvasWidth, canvasHeight, 0, -1000, 1000);
        version(WebAssembly)
        {
            projectionMatrixLoc = glGetUniformLocation(shaderProgram, pMat1.length, cast(ubyte*)pMat1.ptr);
        }
        else
        {
            projectionMatrixLoc = glGetUniformLocation(shaderProgram, toStringz(pMat1));
        }
        
        auto t = translationMatrix(canvasWidth * 0.5, canvasHeight * 0.5, 0);
        auto s = scaleMatrix(100, 100, 100);
        modelViewMatrix = multMatrix(t, s);
        version(WebAssembly)
        {
            modelViewMatrixLoc = glGetUniformLocation(shaderProgram, pMat2.length, cast(ubyte*)pMat2.ptr);
        }
        else
        {
            modelViewMatrixLoc = glGetUniformLocation(shaderProgram, toStringz(pMat2));
        }
        
        Test test = New!Test(10);
        version(WebAssembly)
            consoleLog(test.x);
        Delete(test);
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
        
        version(WebAssembly)
        {
            glUniformMatrix4fv(projectionMatrixLoc, false, cast(ubyte*)projectionMatrix.ptr);
            glUniformMatrix4fv(modelViewMatrixLoc, false, cast(ubyte*)modelViewMatrix.ptr);
        }
        else
        {
            glUniformMatrix4fv(projectionMatrixLoc, 1, GL_FALSE, projectionMatrix.ptr);
            glUniformMatrix4fv(modelViewMatrixLoc, 1, GL_FALSE, modelViewMatrix.ptr);
        }
        
        glBindVertexArray(vao);
        version(WebAssembly)
        {
            glDrawElements(GL_TRIANGLES, cast(uint)indices.length, GL_UNSIGNED_SHORT, 0);
        }
        else
        {
            glDrawElements(GL_TRIANGLES, cast(uint)indices.length, GL_UNSIGNED_SHORT, null);
        }
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
