module web.console;

extern(C):

public:

void consoleLog(double num);

public:

static struct console
{
    alias log = consoleLog;
}