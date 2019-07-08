module web.gl;

extern(C):

alias GLenum = uint;

enum GL_DEPTH_TEST = 0x0B71;
enum GL_CULL_FACE = 0x0B44;

enum GL_LESS = 0x0201;

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

void glEnable(GLenum cap);
void glDisable(GLenum cap);
void glDepthFunc(GLenum func);
void glViewport(uint x, uint y, uint w, uint h);
void glClearColor(float r, float g, float b, float a);
void glClearDepth(float d);
void glClear(uint mask);
uint glCreateBuffer();
void glBindBuffer(uint buffType, uint buff);
void glBufferData(uint target, uint len, ubyte* offset, uint usage);
uint glCreateVertexArray();
void glBindVertexArray(uint vao);
void glEnableVertexAttribArray(uint index);
void glVertexAttribPointer(uint index, uint size, uint type, uint normalized, uint stride, uint offset);
void glDrawElements(uint mode, uint count, uint type, uint offset);
uint glCreateShader(uint type);
void glShaderSource(uint shader, uint len, ubyte* offset);
void glCompileShader(uint shader);
uint glCreateProgram();
void glAttachShader(uint program, uint shader);
void glLinkProgram(uint program);
void glUseProgram(uint program);
uint glGetUniformLocation(uint program, uint length, ubyte* offset);
void glUniformMatrix4fv(uint location, uint transpose, ubyte* offset);
