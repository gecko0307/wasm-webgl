module core.mem;

import std.traits;

extern(C):

uint malloc(uint size);
void free(uint mem);

void* memset(void* ptr, int value, uint num)
{
    for (uint i = 0; i < num; i++)
    {
        (cast(ubyte*)ptr)[i] = cast(ubyte)value;
    }
    
    return ptr;
}

enum psize = 8;
__gshared ulong _allocatedMemory = 0;

T allocate(T, A...) (A args) if (is(T == class))
{
    enum size = __traits(classInstanceSize, T);
    void* p = cast(void*)malloc(size);
    T c = cast(T)p;
    static if (is(typeof(c.__ctor(args))))
    {
        c.__ctor(args);
    }
    return c;
}

T* allocate(T, A...) (A args) if (is(T == struct))
{
    enum size = T.sizeof;
    void* p = cast(void*)malloc(size);
    T* c = cast(T*)p;
    static if (is(typeof(c.__ctor(args))))
    {
        c.__ctor(args);
    }
    return c;
}

T allocate(T) (size_t length) if (isArray!T)
{
    alias AT = ForeachType!T;
    size_t size = length * AT.sizeof;
    void* p = cast(void*)malloc(size);
    T arr = cast(T)p[0..size];
    foreach(ref v; arr)
        v = v.init;
    return arr;
}

alias New = allocate;

// TODO: Delete
