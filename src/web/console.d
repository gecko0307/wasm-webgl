module web.console;

extern(C):

public:

void consoleLog(double num);
//void setInterval(int function() callback, int msec);

public:

static struct console
{
    alias log = consoleLog;
}