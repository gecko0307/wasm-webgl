module runtime.arrayinit;

extern(C):

@trusted nothrow size_t _d_arraycast_len(size_t len, size_t elemsz, size_t newelemsz)
{
    const size = len * elemsz;
    const newlen = size / newelemsz;
    if (newlen * newelemsz != size)
        assert(0);
    return newlen;
}

