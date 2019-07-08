/*
Copyright (c) 2013, Robin Lobel
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module wasmrt.trig;

import wasmrt.math;

enum float invtwopi = 0.1591549f;
enum float twopi = 6.283185f;
enum float threehalfpi = 4.7123889f;
enum float PI = 3.141593f;
enum float halfpi = 1.570796f;
enum float quarterpi = 0.7853982f;

float _cos_32s(float x)
{
    const float c1 =  0.99940307f;
    const float c2 = -0.49558072f;
    const float c3 =  0.03679168f;
    float x2; // The input argument squared
    x2 = x * x;
    return (c1 + x2 * (c2 + c3 * x2));
}

float cos(float angle)
{
    //clamp to the range 0..2pi
    angle = angle - floor(angle * invtwopi) * twopi;
    angle = angle > 0.0f? angle : -angle;
 
    if (angle < halfpi) return _cos_32s(angle);
    if (angle < PI) return - _cos_32s(PI - angle);
    if (angle < threehalfpi) return -_cos_32s(angle - PI);
    return _cos_32s(twopi - angle);
}

float sin(float angle)
{
    return cos(halfpi - angle);
}

float atan(float x)
{
    return quarterpi * x - x * (abs(x) - 1) * (0.2447f + 0.0663f * abs(x));
}

float atan2(float y, float x)
{
    if (abs(x) > abs(y))
    {
        float a=atan(y/x);
        if (x > 0.0f)
            return a;
        else
            return y > 0.0f? a + PI : a - PI;
    }
    else
    {
        float a = atan(x / y);
        if (x > 0.0f)
            return y > 0.0f? halfpi - a : -halfpi - a;
        else
            return y > 0.0f? halfpi + a : -halfpi + a;
    }
}
