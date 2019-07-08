module main_desktop;

version(WebAssembly)
{
}
else 
{
    version = Desktop;
}

version(Desktop):

import std.stdio;
import std.string;
import std.conv;
import core.stdc.stdlib;
import bindbc.sdl;
import bindbc.opengl;
import application;

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
