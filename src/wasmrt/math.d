module wasmrt.math;

public import wasmrt.trig;

T abs(T)(T v)
{
    return (v > 0.0)? v : -v;
}

T clamp(T)(T v, T mi, T ma)
{
    if (v < mi) return mi;
    else if (v > ma) return ma;
    else return v;
}

T floor(T)(T x)
{
    long xi = cast(long)x;
    return x < xi ? xi - 1 : xi;
}

T rationalSmoothstep(T)(T x, float k)
{
    T s = (x + x * k - k * 0.5 - 0.5) / (abs(x * k * 4.0 - k * 2.0) - k + 1.0) + 0.5;
    return clamp(s, 0.0, 1.0);
}

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
