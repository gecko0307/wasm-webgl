module matrix;

version(WebAssembly) 
{
    import wasmrt.math;
}
else
{
    import std.math;
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

float[16] rotationMatrix(uint rotaxis, float theta)
{
    float[16] res;

    float s = sin(theta);
    float c = cos(theta);
    
    res[3] = 0.0;
    res[7] = 0.0;
    res[11] = 0.0;
    res[12] = 0.0;
    res[13] = 0.0;
    res[14] = 0.0;
    res[15] = 1.0;

    switch (rotaxis)
    {
        case 0: // X
            res[0] = 1.0; res[4] = 0.0; res[8] = 0.0;
            res[1] = 0.0; res[5] = c;   res[9] =  s;
            res[2] = 0.0; res[6] = -s;  res[10] =  c;
            break;

        case 1: // Y
            res[0] = c;   res[4] = 0.0; res[8] = -s;
            res[1] = 0.0; res[5] = 1.0; res[9] = 0.0;
            res[2] = s;   res[6] = 0.0; res[10] = c;
            break;

        case 2: // Z
            res[0] = c;   res[4] =  s;  res[8] = 0.0;
            res[1] = -s;  res[5] =  c;  res[9] = 0.0;
            res[2] = 0.0; res[6] = 0.0; res[10] = 1.0;
            break;

        default:
            res[0] = 1.0; res[4] = 0.0; res[8] = 0.0;
            res[1] = 0.0; res[5] = 1.0; res[9] = 0.0;
            res[2] = 0.0; res[6] = 0.0; res[10] = 1.0;
            break;
    }

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

    res[0] = (m1[0] * m2[0]) + (m1[4] * m2[1]) + (m1[8] * m2[2]) + (m1[12] * m2[3]);
    res[1] = (m1[1] * m2[0]) + (m1[5] * m2[1]) + (m1[9] * m2[2]) + (m1[13] * m2[3]);
    res[2] = (m1[2] * m2[0]) + (m1[6] * m2[1]) + (m1[10] * m2[2]) + (m1[14] * m2[3]);
    res[3] = (m1[3] * m2[0]) + (m1[7] * m2[1]) + (m1[11] * m2[2]) + (m1[15] * m2[3]);

    res[4] = (m1[0] * m2[4]) + (m1[4] * m2[5]) + (m1[8] * m2[6]) + (m1[12] * m2[7]);
    res[5] = (m1[1] * m2[4]) + (m1[5] * m2[5]) + (m1[9] * m2[6]) + (m1[13] * m2[7]);
    res[6] = (m1[2] * m2[4]) + (m1[6] * m2[5]) + (m1[10] * m2[6]) + (m1[14] * m2[7]);
    res[7] = (m1[3] * m2[4]) + (m1[7] * m2[5]) + (m1[11] * m2[6]) + (m1[15] * m2[7]);

    res[8] = (m1[0] * m2[8]) + (m1[4] * m2[9]) + (m1[8] * m2[10]) + (m1[12] * m2[11]);
    res[9] = (m1[1] * m2[8]) + (m1[5] * m2[9]) + (m1[9] * m2[10]) + (m1[13] * m2[11]);
    res[10] = (m1[2] * m2[8]) + (m1[6] * m2[9]) + (m1[10] * m2[10]) + (m1[14] * m2[11]);
    res[11] = (m1[3] * m2[8]) + (m1[7] * m2[9]) + (m1[11] * m2[10]) + (m1[15] * m2[11]);

    res[12] = (m1[0] * m2[12]) + (m1[4] * m2[13]) + (m1[8] * m2[14]) + (m1[12] * m2[15]);
    res[13] = (m1[1] * m2[12]) + (m1[5] * m2[13]) + (m1[9] * m2[14]) + (m1[13] * m2[15]);
    res[14] = (m1[2] * m2[12]) + (m1[6] * m2[13]) + (m1[10] * m2[14]) + (m1[14] * m2[15]);
    res[15] = (m1[3] * m2[12]) + (m1[7] * m2[13]) + (m1[11] * m2[14]) + (m1[15] * m2[15]);

    return res;
}
