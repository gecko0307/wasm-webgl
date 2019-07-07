module core.arrayinit;

extern(C):

// for array cast
size_t _d_array_cast_len(size_t len, size_t elemsz, size_t newelemsz)
{
    if (newelemsz == 1) {
        return len*elemsz;
    }
    else if ((len*elemsz) % newelemsz) {
		while(1){}
    }
    return (len*elemsz)/newelemsz;
}

