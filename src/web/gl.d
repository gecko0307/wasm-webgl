module web.gl;

extern(C):

// WebGL declarations
enum GL_COLOR_BUFFER_BIT = 0x00004000;
enum GL_DEPTH_BUFFER_BIT = 0x00000100;
enum GL_STENCIL_BUFFER_BIT = 0x00000400;

enum GL_FLOAT = 0x1406;
enum GL_UNSIGNED_INT = 0x1405;
enum GL_UNSIGNED_SHORT = 0x1403;

enum GL_ARRAY_BUFFER = 0x8892;
enum GL_ELEMENT_ARRAY_BUFFER = 0x8893;
enum GL_STATIC_DRAW = 0x88E4;

enum GL_TRIANGLES = 0x0004;

enum GL_VERTEX_SHADER = 0x8B31;
enum GL_FRAGMENT_SHADER = 0x8B30;

public:

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

public:

static struct gl
{
    alias clearColor = webglClearColor;
    alias clear = webglClear;
    alias createBuffer = webglCreateBuffer;
    alias bindBuffer = webglBindBuffer;
    alias bufferData = webglBufferData;
    alias createVertexArray = webglCreateVertexArray;
    alias bindVertexArray = webglBindVertexArray;
    alias enableVertexAttribArray = webglEnableVertexAttribArray;
    alias vertexAttribPointer = webglVertexAttribPointer;
    alias drawElements = webglDrawElements;
    alias createShader = webglCreateShader;
    alias shaderSource = webglShaderSource;
    alias compileShader = webglCompileShader;
    alias createProgram = webglCreateProgram;
    alias attachShader = webglAttachShader;
    alias linkProgram = webglLinkProgram;
    alias useProgram = webglUseProgram;
    alias getUniformLocation = webglGetUniformLocation;
    alias uniformMatrix4fv = webglUniformMatrix4fv;
}