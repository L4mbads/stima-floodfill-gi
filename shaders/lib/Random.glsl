uint seed = 185730U * uint(frameCounter) + uint(gl_FragCoord.x + gl_FragCoord.y * resolution.x);


void pcg(inout uint seed) {
    uint state = seed * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    seed = (word >> 22u) ^ word;
}


float randF() { pcg(seed); return float(seed) / float(0xffffffffu); }

float randomValueNormalDistribution() {
    float t = 2 * PI * randF();
    float rho = sqrt(-2 * log(randF()));
    return rho * cos(t);
}

vec3 randomDirection() {
    float x = randomValueNormalDistribution();
    float y = randomValueNormalDistribution();
    float z = randomValueNormalDistribution();
    return normalize(vec3(x,y,z));
}

vec3 randomHemisphereVector(vec3 normal) {
    vec3 dir = randomDirection();
    return dir * sign(dot(normal, dir));
}

vec3 randomCosineWeightedHemispherePoint(vec3 rand, vec3 n) {
  float r = rand.x * 0.5 + 0.5; // [-1..1) -> [0..1)
  float angle = (rand.y + 1.0) * PI; // [-1..1] -> [0..2*PI)
  float sr = sqrt(r);
  vec2 p = vec2(sr * cos(angle), sr * sin(angle));
  /*
   * Unproject disk point up onto hemisphere:
   * 1.0 == sqrt(x*x + y*y + z*z) -> z = sqrt(1.0 - x*x - y*y)
   */
  vec3 ph = vec3(p.xy, sqrt(1.0 - p*p));
  /*
   * Compute some arbitrary tangent space for orienting
   * our hemisphere 'ph' around the normal. We use the camera's up vector
   * to have some fix reference vector over the whole screen.
   */
  vec3 tangent = normalize(rand);
  vec3 bitangent = cross(tangent, n);
  tangent = cross(bitangent, n);
  
  /* Make our hemisphere orient around the normal. */
  return tangent * ph.x + bitangent * ph.y + n * ph.z;
}

vec3 generateUnitVector(vec2 xy) {
    xy.x *= TAU; xy.y = xy.y * 2.0 - 1.0;
    return vec3(vec2(sin(xy.x), cos(xy.x)) * sqrt(1.0 - xy.y * xy.y), xy.y);
}

vec3 generateCosineVector(vec3 normal, vec2 xy) {
    return normalize(normal + generateUnitVector(xy));
}

vec3 uniformSphereSample(vec2 hash) {
    hash.x *= TAU; hash.y = 2.0 * hash.y - 1.0;
    return vec3(vec2(sin(hash.x), cos(hash.x)) * sqrt(1.0 - hash.y * hash.y), hash.y);
}

vec3 uniformHemisphereSample(vec3 vector, vec2 hash) {
    vec3 dir = uniformSphereSample(hash);
    return dot(dir, vector) < 0.0 ? -dir : dir;
}

// https://amietia.com/lambertnotangent.html
vec3 cosineWeightedHemisphereSample(vec3 vector, vec2 hash) {
    vec3 dir = normalize(uniformSphereSample(hash) + vector);
    return dot(dir, vector) < 0.0 ? -dir : dir;
}

float Bayer2(vec2 a) {
    a = floor(a);
    return fract(a.x / 2. + a.y * a.y * .75);
}

#define Bayer4(a)   (Bayer2 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer8(a)   (Bayer4 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer16(a)  (Bayer8 (.5 *(a)) * .25 + Bayer2(a))
#define Bayer32(a)  (Bayer16(.5 *(a)) * .25 + Bayer2(a))
#define Bayer64(a)  (Bayer32(.5 *(a)) * .25 + Bayer2(a))

const vec2 blue_noise_disk[64] = vec2[](
    vec2(0.478712,0.875764),
    vec2(-0.337956,-0.793959),
    vec2(-0.955259,-0.028164),
    vec2(0.864527,0.325689),
    vec2(0.209342,-0.395657),
    vec2(-0.106779,0.672585),
    vec2(0.156213,0.235113),
    vec2(-0.413644,-0.082856),
    vec2(-0.415667,0.323909),
    vec2(0.141896,-0.939980),
    vec2(0.954932,-0.182516),
    vec2(-0.766184,0.410799),
    vec2(-0.434912,-0.458845),
    vec2(0.415242,-0.078724),
    vec2(0.728335,-0.491777),
    vec2(-0.058086,-0.066401),
    vec2(0.202990,0.686837),
    vec2(-0.808362,-0.556402),
    vec2(0.507386,-0.640839),
    vec2(-0.723494,-0.229240),
    vec2(0.489740,0.317826),
    vec2(-0.622663,0.765301),
    vec2(-0.010640,0.929347),
    vec2(0.663146,0.647618),
    vec2(-0.096674,-0.413835),
    vec2(0.525945,-0.321063),
    vec2(-0.122533,0.366019),
    vec2(0.195235,-0.687983),
    vec2(-0.563203,0.098748),
    vec2(0.418563,0.561335),
    vec2(-0.378595,0.800367),
    vec2(0.826922,0.001024),
    vec2(-0.085372,-0.766651),
    vec2(-0.921920,0.183673),
    vec2(-0.590008,-0.721799),
    vec2(0.167751,-0.164393),
    vec2(0.032961,-0.562530),
    vec2(0.632900,-0.107059),
    vec2(-0.464080,0.569669),
    vec2(-0.173676,-0.958758),
    vec2(-0.242648,-0.234303),
    vec2(-0.275362,0.157163),
    vec2(0.382295,-0.795131),
    vec2(0.562955,0.115562),
    vec2(0.190586,0.470121),
    vec2(0.770764,-0.297576),
    vec2(0.237281,0.931050),
    vec2(-0.666642,-0.455871),
    vec2(-0.905649,-0.298379),
    vec2(0.339520,0.157829),
    vec2(0.701438,-0.704100),
    vec2(-0.062758,0.160346),
    vec2(-0.220674,0.957141),
    vec2(0.642692,0.432706),
    vec2(-0.773390,-0.015272),
    vec2(-0.671467,0.246880),
    vec2(0.158051,0.062859),
    vec2(0.806009,0.527232),
    vec2(-0.057620,-0.247071),
    vec2(0.333436,-0.516710),
    vec2(-0.550658,-0.315773),
    vec2(-0.652078,0.589846),
    vec2(0.008818,0.530556),
    vec2(-0.210004,0.519896) 
);

const vec2 circle_blur_polar_16[16] = vec2[](
    vec2(0.1767766952966369, 0),
    vec2(0.30618621784789724, 2.399963229728653),
    vec2(0.39528470752104744, 4.799926459457306),
    vec2(0.46770717334674267, 7.199889689185959),
    vec2(0.5303300858899106, 9.599852918914612),
    vec2(0.5863019699779287, 11.999816148643266),
    vec2(0.6373774391990981, 14.399779378371917),
    vec2(0.6846531968814576, 16.799742608100573),
    vec2(0.7288689868556626, 19.199705837829224),
    vec2(0.770551750371122, 21.599669067557876),
    vec2(0.8100925873009825, 23.99963229728653),
    vec2(0.8477912478906585, 26.399595527015183),
    vec2(0.8838834764831844, 28.799558756743835),
    vec2(0.9185586535436918, 31.19952198647249),
    vec2(0.9519716382329886, 33.599485216201145),
    vec2(0.9842509842514764, 35.999448445929794)
);

const vec2 PoissonDisk2[64] = vec2[64](
vec2(-0.613392, 0.617481),
vec2(0.170019, -0.040254),
vec2(-0.299417, 0.791925),
vec2(0.645680, 0.493210),
vec2(-0.651784, 0.717887),
vec2(0.421003, 0.027070),
vec2(-0.817194, -0.271096),
vec2(-0.705374, -0.668203),
vec2(0.977050, -0.108615),
vec2(0.063326, 0.142369),
vec2(0.203528, 0.214331),
vec2(-0.667531, 0.326090),
vec2(-0.098422, -0.295755),
vec2(-0.885922, 0.215369),
vec2(0.566637, 0.605213),
vec2(0.039766, -0.396100),
vec2(0.751946, 0.453352),
vec2(0.078707, -0.715323),
vec2(-0.075838, -0.529344),
vec2(0.724479, -0.580798),
vec2(0.222999, -0.215125),
vec2(-0.467574, -0.405438),
vec2(-0.248268, -0.814753),
vec2(0.354411, -0.887570),
vec2(0.175817, 0.382366),
vec2(0.487472, -0.063082),
vec2(-0.084078, 0.898312),
vec2(0.488876, -0.783441),
vec2(0.470016, 0.217933),
vec2(-0.696890, -0.549791),
vec2(-0.149693, 0.605762),
vec2(0.034211, 0.979980),
vec2(0.503098, -0.308878),
vec2(-0.016205, -0.872921),
vec2(0.385784, -0.393902),
vec2(-0.146886, -0.859249),
vec2(0.643361, 0.164098),
vec2(0.634388, -0.049471),
vec2(-0.688894, 0.007843),
vec2(0.464034, -0.188818),
vec2(-0.440840, 0.137486),
vec2(0.364483, 0.511704),
vec2(0.034028, 0.325968),
vec2(0.099094, -0.308023),
vec2(0.693960, -0.366253),
vec2(0.678884, -0.204688),
vec2(0.001801, 0.780328),
vec2(0.145177, -0.898984),
vec2(0.062655, -0.611866),
vec2(0.315226, -0.604297),
vec2(-0.780145, 0.486251),
vec2(-0.371868, 0.882138),
vec2(0.200476, 0.494430),
vec2(-0.494552, -0.711051),
vec2(0.612476, 0.705252),
vec2(-0.578845, -0.768792),
vec2(-0.772454, -0.090976),
vec2(0.504440, 0.372295),
vec2(0.155736, 0.065157),
vec2(0.391522, 0.849605),
vec2(-0.620106, -0.328104),
vec2(0.789239, -0.419965),
vec2(-0.545396, 0.538133),
vec2(-0.178564, -0.596057)
);
