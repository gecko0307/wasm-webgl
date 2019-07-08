module main_web;

version(WebAssembly):

import wasmrt;
import web;
import application;

__gshared Application app;

extern(C):

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

void _start() { }
