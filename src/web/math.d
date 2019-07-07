module wstd.math;

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
