module web.time;

extern(C):

public:

void setInterval(int function() callback, int msec);
