module main;

import std.traits;

enum psize = 8;
__gshared ulong _allocatedMemory = 0;

/*
T allocate(T, A...) (A args) if (is(T == class))
{
    enum size = __traits(classInstanceSize, T);
    void* p = cast(void*)malloc(size);
    consoleLog(cast(size_t)p);
    T c = cast(T)p;
    return c;
}

alias New = allocate;
*/

T abs(T)(T v)
{
    if (v < 0.0) return -v;
    else return v;
}

T clamp(T)(T v, T mi, T ma)
{
    if (v < mi) return mi;
    else if (v > ma) return ma;
    else return v;
}

T rationalSmoothstep(T)(T x, float k)
{
    T s = (x + x * k - k * 0.5 - 0.5) / (abs(x * k * 4.0 - k * 2.0) - k + 1.0) + 0.5;
    return clamp(s, 0.0, 1.0);
}

extern(C):

double sqrt(double number)
{
    long i;
    float x, y;
    const float f = 1.5f;
    x = number * 0.5f;
    y = number;
    i = *cast(long*)&y;
    i = 0x5f3759df - (i >> 1);
    y = *cast(float*)&i;
    y = y * (f - (x * y * y));
    return number * y;
}

double rsqrt(double number)
{
	long i;
	float x2, y;
	const float threehalfs = 1.5f;
	x2 = number * 0.5f;
	y  = number;
	i  = * cast(long*)&y;
	i  = 0x5f3759df - (i >> 1);
	y  = * cast(float*)&i;
	y  = y * (threehalfs - (x2 * y * y));
	return y;
}

double benchmark()
{
    double r;
    for (int i = 0; i < 10000000; i++)
        r = sqrt(i);
    return r;
}

void consoleLog(double num);
void jsSetInterval(int function() callback, int msec);

uint malloc(uint size);
void free(uint mem);

// WebGL declarations
enum WEBGL_COLOR_BUFFER_BIT = 0x00004000;
enum WEBGL_DEPTH_BUFFER_BIT = 0x00000100;
enum WEBGL_STENCIL_BUFFER_BIT = 0x00000400;

enum GL_FLOAT = 0x1406;
enum GL_UNSIGNED_INT = 0x1405;
enum GL_UNSIGNED_SHORT = 0x1403;

enum GL_ARRAY_BUFFER = 0x8892;
enum GL_ELEMENT_ARRAY_BUFFER = 0x8893;
enum GL_STATIC_DRAW = 0x88E4;

enum GL_TRIANGLES = 0x0004;

enum GL_VERTEX_SHADER = 0x8B31;
enum GL_FRAGMENT_SHADER = 0x8B30;

void webglClearColor(float r, float g, float b, float a);
void webglClear(uint mask);
uint webglCreateBuffer();
void webglBindBuffer(uint buffType, uint buff);
void webglBufferData(uint target, uint len, ubyte* offset, uint usage);
uint webglCreateVertexArray();
void webglBindVertexArray(uint vao);
void webglEnableVertexAttribArray(uint index);
void webglVertexAttribPointer(uint index, uint size, uint type, uint normalized, uint stride, uint offset);
void webglDrawElements(uint mode, uint count, uint type, uint offset);
uint webglCreateShader(uint type);
void webglShaderSource(uint shader, uint len, ubyte* offset);
void webglCompileShader(uint shader);
uint webglCreateProgram();
void webglAttachShader(uint program, uint shader);
void webglLinkProgram(uint program);
void webglUseProgram(uint program);
uint webglGetUniformLocation(uint program, uint length, ubyte* offset);
void webglUniformMatrix4fv(uint location, uint transpose, ubyte* offset);

enum VertexAttrib
{
    Vertices = 0,
    Normals = 1,
    Texcoords = 2
}

float[16] orthoMatrix(float l, float r, float b, float t, float n, float f)
{
    float[16] res;

    float width  = r - l;
    float height = t - b;
    float depth  = f - n;

    res[0] =  2.0 / width;
    res[1] =  0.0;
    res[2] =  0.0;
    res[3] =  0.0;

    res[4] =  0.0;
    res[5] =  2.0 / height;
    res[6] =  0.0;
    res[7] =  0.0;

    res[8] =  0.0;
    res[9] =  0.0;
    res[10]= -2.0 / depth;
    res[11]=  0.0;

    res[12]= -(r + l) / width;
    res[13]= -(t + b) / height;
    res[14]= -(f + n) / depth;
    res[15]=  1.0;

    return res;
}

float[16] translationMatrix(float x, float y, float z)
{
    float[16] res;
    
    res[0] = 1.0;
    res[1] = 0.0;
    res[2] = 0.0;
    res[3] = 0.0;
    
    res[4] = 0.0;
    res[5] = 1.0;
    res[6] = 0.0;
    res[7] = 0.0;

    res[8] = 0.0;
    res[9] = 0.0;
    res[10] = 1.0;
    res[11] = 0.0;

    res[12] = x;
    res[13] = y;
    res[14] = z;
    res[15] = 1.0;

    return res;
}

float[16] scaleMatrix(float x, float y, float z)
{
    float[16] res;
    
    res[0] = x;
    res[1] = 0.0;
    res[2] = 0.0;
    res[3] = 0.0;
    
    res[4] = 0.0;
    res[5] = y;
    res[6] = 0.0;
    res[7] = 0.0;

    res[8] = 0.0;
    res[9] = 0.0;
    res[10] = z;
    res[11] = 0.0;

    res[12] = 0.0;
    res[13] = 0.0;
    res[14] = 0.0;
    res[15] = 1.0;

    return res;
}

float[16] multMatrix(ref float[16] m1, ref float[16] m2)
{
    float[16] res;
    for(size_t y = 0; y < 16; y++)
    for(size_t x = 0; x < 16; x++)
    {
        res[y * 4 + x] = 
            m1[y * 4 + 0] * m2[0 * 4 + x] +
            m1[y * 4 + 1] * m2[1 * 4 + x] +
            m1[y * 4 + 2] * m2[2 * 4 + x] +
            m1[y * 4 + 3] * m2[3 * 4 + x];
    }
    return res;
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
    jsSetInterval(&loop, 1000 / app.fps);
    return 0;
}

void _start() {}
