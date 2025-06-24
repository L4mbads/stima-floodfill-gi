

vec3 sampleGGXVNDF(vec3 Ve, float rough, vec2 rand) {
    /*
    // Section 3.2: transforming the view direction to the hemisphere configuration
    vec3 Vh = normalize(vec3(rough* Ve.x, rough * Ve.y, Ve.z));
    // Section 4.1: orthonormal basis (with special case if cross product is zero)
    float lensq = Vh.x * Vh.x + Vh.y * Vh.y;
    vec3 T1 = lensq > 0 ? vec3(-Vh.y, Vh.x, 0) * inversesqrt(lensq) : vec3(1,0,0);
    vec3 T2 = cross(Vh, T1);
    // Section 4.2: parameterization of the projected area
    float r = sqrt(rand.x); 
    float phi = 2.0 * PI * rand.y;    
    float t1 = r * cos(phi);
    float t2 = r * sin(phi);
    float s = 0.5 * (1.0 + Vh.z);
    t2 = (1.0 - s)*sqrt(1.0 - t1*t1) + s*t2;
    // Section 4.3: reprojection onto hemisphere
    vec3 Nh = t1*T1 + t2*T2 + sqrt(max(0.0, 1.0 - t1*t1 - t2*t2))*Vh;
    // Section 3.4: transforming the normal back to the ellipsoid configuration
    vec3 Ne = normalize(vec3(rough * Nh.x, rough * Nh.y, max(0.0, Nh.z)));  
    return Ne;
    */

    //function from zombye

    // Transform viewer direction to the hemisphere configuration
    Ve = normalize(vec3(rough * Ve.xy, Ve.z));

    // Sample a reflection direction off the hemisphere
    float phi = TAU * rand.x;
    float cosTheta = fma(1.0 - rand.y, 1.0 + Ve.z, -Ve.z);
    float sinTheta = sqrt(clamp(1.0 - cosTheta * cosTheta, 0.0, 1.0));
    vec3 reflected = vec3(vec2(cos(phi), sin(phi)) * sinTheta, cosTheta);

    // Evaluate halfway direction
    // This gives the normal on the hemisphere
    vec3 halfway = reflected + Ve;

    // Transform the halfway direction back to hemiellispoid configuation
    // This gives the final sampled normal
    return normalize(vec3(rough * halfway.xy, halfway.z));

}




vec3 getDirectionGGXVNDF(vec3 normal, vec3 viewDir,  float roughness, vec2 u) {
        mat3 TBN = constructViewTBN(normal);
        vec3 h = sampleGGXVNDF(normalize(-viewDir) * TBN  , roughness , u);
        if (h.z < 0) h= -h;
            
        return TBN* h;
}


vec3 fresnelSchlick(float HdotL, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(max(1.0 - HdotL, 0.0), 5.0);
}

vec3 fresnelSchlickD(float HdotL, vec3 F0, float F90)
{
    return F0 + (F90 - F0) * pow(max(1.0 - HdotL, 0.0), 5.0);
}


float D_GTR(float roughness, float NoH, float k) {
    float a2 = pow(roughness, 2.);
    return max0(a2) / max(EPS, PI * pow((NoH*NoH)*(a2*a2-1.)+1., k));
}

float smithG(float NDotV, float alphaG)
{
    float a = alphaG * alphaG;
    float b = NDotV * NDotV;
    return max0(2.0 * NDotV) / max(NDotV + sqrt(a + b - a * b), EPS);
}



float lambdaSmith(float NdotX, float alpha)
{    
    float alpha_sqr = alpha * alpha;
    float NdotX_sqr = NdotX * NdotX;
    return (-1.0 + sqrt(alpha_sqr * (1.0 - NdotX_sqr) / NdotX_sqr + 1.0)) * 0.5;
}

//Masking function
float G1Smith(float NdotV, float alpha)
{
    float lambdaV = lambdaSmith(NdotV, alpha);

    return 1.0 / (1.0 + lambdaV);
}

//Height Correlated Masking-shadowing function
float G2Smith(float NdotL, float NdotV, float alpha)
{
    float lambdaV = lambdaSmith(NdotV, alpha);
    float lambdaL = lambdaSmith(NdotL, alpha);

    return 1.0 / (1.0 + lambdaV + lambdaL);
}

float distributionGGX(float NdotH, float roughness)
{
    float a      = roughness;
    float a2     = a*a;
    
    float NdotH2 = NdotH*NdotH;
    
    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
    
    return num / max(EPS, denom);
}

float geometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
    
    return num / max(EPS,denom);
}

float geometrySmith(float NdotV, float NdotL, float roughness)
{
    float ggx2  = geometrySchlickGGX(NdotV, roughness);
    float ggx1  = geometrySchlickGGX(NdotL, roughness);
    
    return ggx1 * ggx2;
}

float GeometryTerm(float NoL, float NoV, float roughness)
{
    float a2 = roughness*roughness;
    float G1 = smithG(NoV, a2);
    float G2 = smithG(NoL, a2);
    return G1*G2;
}

vec3 calculateBRDF(vec3 N, vec3 V, vec3 L, float r, vec3 F, out float pdf) {
    
    vec3 H = normalize(L - V);

    float NdotV = clamp(dot(N, -V), EPS, 1.0);
    float NdotL = clamp(dot(N, L), EPS, 1.0);

    float NdotH  = max(dot(N, H), .99);
    float HdotL = max(dot(H, L), 0.0);
    float VdotH = max(dot(H, -V), 0.0);

    float D = distributionGGX(NdotH, r);

    float G = geometrySmith(NdotV, NdotL, r);

    pdf =   max(D * NdotH /max(EPS, 4.0*VdotH), EPS);

    return (D*F*G) / (4.0 * max(EPS, NdotV * NdotL )) ;
}

vec3 BRDFCookTorrance(vec3 N, vec3 V, vec3 L, float r, vec3 F) {
    
    vec3 H = normalize(L+V);

    float NdotV = clamp(dot(N, V), EPS, 1.0);
    float NdotL = clamp(dot(N, L), 0.0, 1.0);
    float NdotH  = clamp(dot(N, H), 0.0, 0.99);
    float HdotL = clamp(dot(H, L), 0.0, 1.0);
    float VdotH = clamp(dot(H, V), 0.0, 1.0);

    float D = distributionGGX(NdotH, r);
    float G = geometrySmith(NdotV, NdotL, r);

    return (D * F * G)/ max(4.0*(NdotV * NdotH), EPS);
}

float blinnlol(vec3 L, vec3 V, vec3 N, float shininess) {
    vec3 H = normalize(V + L);

    float spec = pow(max(dot(N, H), 0.0001), shininess)  * (shininess + 8.0) / (8.0 * PI);
    return spec;
}

float disneyDiffuseNormalized(float NdotL, float NdotV, float LdotH, float roughness) {
    float energyBias = mix(0.0, 0.5, roughness);
    float energyFactor = mix(1.0, 1.0/1.51, roughness);
    float F90 = energyBias + 2.0 * LdotH*LdotH * roughness;
    vec3 F0 = vec3(1.0);
    float lightScat = fresnelSchlickD(NdotL, F0, F90).r;
    float viewScat = fresnelSchlickD(NdotV, F0, F90).r;

    return lightScat * viewScat * energyFactor;

}

vec3 disneyDiffuse(vec3 albedo, float NoL, float NoV, float LoH, float roughness) {
    float FD90 = 0.5 + 2. * roughness * pow(LoH,2.);
    float a = fresnelSchlickD(NoL, vec3(1.0), FD90).r;
    float b = fresnelSchlickD(NoV, vec3(1.0), FD90).r;
    
    return albedo * (a * b / PI);
}

vec3 disneySpecular(float r, vec3 F, float NoH, float NoV, float NoL) {
    float roughness = pow(r, 2.);
    float D = D_GTR(r, NoH,2.);
    float G = GeometryTerm(NoL, NoV, pow(0.5+r*.5,2.));

    vec3 spec = clamp01(D*F*G / max(4. * NoL * NoV, EPS));
    
    return spec;
}

float GGXVNDFPdf(float NdotH, float NdotV, float roughness)
{
    float D = D_GTR(roughness, NdotH, 2.);
    float G1 = smithG(NdotV, roughness*roughness);
    return max(EPS, (D * G1) / max(EPS, 4.0f * NdotV));
}

vec3 VNDFEstimator(float NdotV, float NdotL, float VdotH, float roughness, vec3 f) {
    float g2 = G2Smith(NdotL, NdotV, roughness);
    float g1 = max(G1Smith(NdotV, roughness),EPS);

    return f * (g2/g1);
}

float henyeyGreenstein(float g, float theta) {
    return (1.0 - g * g) / (4.0 * PI * pow(1.0 + g * g - 2.0 * g * theta, 3.0/2.0));
}

vec3 computeTransmission(material mat, float distThroughMedium, float theta) {
    if (mat.sss <= 1.e-6) return vec3(0.0);
    return exp(-(1.0 - mat.albedo) * distThroughMedium / (mat.sss)) * henyeyGreenstein(0.2, theta );
}