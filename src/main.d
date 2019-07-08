module main;

import std.traits;

version(WebAssembly)
{
    import runtime;
    import web;
}
else 
{
    version = Desktop;
    import std.stdio;
    import std.string;
    import std.conv;
    import core.stdc.stdlib;
    import bindbc.sdl;
    import bindbc.opengl;
}

import matrix;

enum VertexAttrib: uint
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
        glViewport(0, 0, canvasWidth, canvasHeight);
        
        glClearColor(0.5, 0.5, 0.5, 1.0);
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

version(WebAssembly)
{
    __gshared Application app;

    extern(C) int loop(double dt)
    {
        app.onUpdate(dt);
        app.onRender();
        return 0;
    }

    extern(C) int resize(int cw, int ch)
    {
        app.onResize(cw, ch);
        return 0;
    }

    extern(C) int init(int cw, int ch)
    {
        app.create(cw, ch);
        return 0;
    }

    version(WebAssembly)
    {
        extern(C) void _start() {}
    }
}

version(Desktop)
{
    enum string[GLenum] GLErrorStrings = [
        GL_NO_ERROR: "GL_NO_ERROR",
        GL_INVALID_ENUM: "GL_INVALID_ENUM",
        GL_INVALID_VALUE: "GL_INVALID_VALUE",
        GL_INVALID_OPERATION: "GL_INVALID_OPERATION",
        GL_INVALID_FRAMEBUFFER_OPERATION: "GL_INVALID_FRAMEBUFFER_OPERATION",
        GL_OUT_OF_MEMORY: "GL_OUT_OF_MEMORY"
    ];

    void exitWithError(string message)
    {
        writeln(message);
        core.stdc.stdlib.exit(1);
    }

    auto initSDL(uint width, uint height)
    {
        SDLSupport sdlsup = loadSDL();
        if (sdlsup != sdlSupport)
        {
            if (sdlsup == SDLSupport.badLibrary)
                writeln("Warning: failed to load some SDL functions. It seems that you have an old version of SDL. Dagon will try to use it, but it is recommended to install SDL 2.0.5 or higher");
            else
                exitWithError("Error: SDL library is not found. Please, install SDL 2.0.5");
        }
        
        if (SDL_Init(SDL_INIT_EVERYTHING) == -1)
            exitWithError("Error: failed to init SDL: " ~ to!string(SDL_GetError()));
            
        SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);

        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
        SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);
        
        auto window = SDL_CreateWindow(toStringz("SDL Window"),
            SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL);
        if (window is null)
            exitWithError("Error: failed to create window: " ~ to!string(SDL_GetError()));

        SDL_GL_SetSwapInterval(1);

        auto glcontext = SDL_GL_CreateContext(window);
        if (glcontext is null)
            exitWithError("Error: failed to create OpenGL context: " ~ to!string(SDL_GetError()));

        SDL_GL_MakeCurrent(window, glcontext);

        GLSupport glsup = loadOpenGL();
        if (isOpenGLLoaded())
        {
            if (glsup < GLSupport.gl33)
            {
                exitWithError("Error: this application requires OpenGL 3.3, but your graphics card does not support it");
            }
        }
        else
        {
            exitWithError("Error: failed to load OpenGL functions. Please, update graphics card driver and make sure it supports OpenGL 3.3");
        }
        
        return window;
    }
    
    void main()
    {
        Application app;
        auto window = initSDL(800, 600);
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClearDepth(1.0);
        glDepthFunc(GL_LESS);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        
        app.create(800, 600);
        
        bool running = true;
        while(running)
        {
            SDL_Event event;

            while(SDL_PollEvent(&event))
            {
                switch (event.type)
                {
                    case SDL_QUIT:
                        running = false;
                        break;

                    default:
                        break;
                }
            }
            
            app.onUpdate(1.0 / 60.0);
            app.onRender();
            
            GLenum error = GL_NO_ERROR;
            error = glGetError();
            if (error != GL_NO_ERROR)
            {
                writefln("OpenGL error %s: %s", error, GLErrorStrings[error]);
            }
            
            SDL_GL_SwapWindow(window);
        }
    }
}