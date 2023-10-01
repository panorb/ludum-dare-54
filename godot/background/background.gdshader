shader_type canvas_item;

uniform vec2 u_resolution;
uniform float u_perspective; // 0 to 1, creates fancy perspective effect
uniform sampler2D u_tower; // tower texture

uniform vec2 u_mouse; // unused remove

#define M_PI 3.1415926535897932384

#define NUMSTEPS 128
const float MINHIT = 0.01;
const float MAXDIST = 1000.0;
const float infinity = 1.0 / 0.0;

//TODO return rotations as mat3
mat4 rotationX(float angle)
{
	return mat4(	vec4(1.0,		0,			0,			0),
					vec4(0, 	cos(angle),	-sin(angle),		0),
					vec4(0, 	sin(angle),	 cos(angle),		0),
					vec4(0, 			0,			  0, 		1));
}

mat4 rotationY(float angle)
{
	return mat4(	vec4(cos(angle),		0,		sin(angle),	0),
			 		vec4(		0,		1.0,			 0,	0),
					vec4(-sin(angle),	0,		cos(angle),	0),
					vec4(		0, 		0,				0,	1));
}

mat4 rotationZ(float angle)
{
	return mat4(	vec4(cos(angle),		-sin(angle),	0,	0),
			 		vec4(sin(angle),		cos(angle),		0,	0),
					vec4(		0,				0,		1,	0),
					vec4(		0,				0,		0,	1));
}

float dstSphere(vec2 p, vec2 c, float r)
{
    return length(p-c)-r;
}

float dstCube2(vec2 p, vec2 halfdim)
{
	vec2 dist = abs(p) - (halfdim);
	return length(max(dist,0.0)) + min(max(dist.x,dist.y),0.0);
}

float dstCube3(vec3 p, vec3 halfdim)
{
	vec3 dist = abs(p) - (halfdim);
	return length(max(dist,0.0)) + min(max(dist.x,max(dist.y,dist.z)),0.0);
}

float dstTorus(vec2 p, float diameter, float center)
{
	vec2 q = vec2(length(p.x)-diameter,p.y);
	return length(q)-center;
}

float dstCylinder( vec2 p, float h, float r )
{
	vec2 d = abs(vec2(length(p.x),p.y)) - vec2(h,r);
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

// from https://iquilezles.org/articles/distfunctions/
float sdPlane( vec2 p, vec2 n, float h )
{
  // n must be normalized
  return dot(p,n) + h;
}

vec2 viewIndepUV(vec2 uv) {
	float aspect = u_resolution.x/u_resolution.y;
	uv.x *= aspect;
	uv.x -= (aspect-1.0)*0.5;
	return uv;
}

float distFunc(vec3 ray, inout vec3 gpos) {
	//TODO remove
	//vec2 u_m = vec2(.01);//u_mouse / u_resolution.xy;
	vec2 u_m = vec2(mod(TIME*.01,1.));
	u_m.y *= 25.;
	vec3 u_scalings= vec3(1.*u_m.y,1.*u_m.y,10.);
	//u_scalings = vec3(1.,1.,10.);
	
	float shape = infinity;

	// tower
	{
		vec3 lray = ray;
		lray.x *= .5;
		lray.x = -1.+mod(lray.x,2.);
		lray.x *= 2.;
		
		if (u_m.y < 5.) {
			float zd = .1;
			lray.z *= zd;
			lray.z = -2.+mod(lray.z,2.);
			lray.z /= zd;		
		}
		
		lray.y /= u_scalings.y+1.;
		lray.y -= u_scalings.y*.2;
		float rotAnim = 0.;//u_time*1.1*(u_m.y*.01); //TODO height
		vec3 pos = (rotationY(1.+rotAnim)*vec4(lray,1.0)).xyz;
		
		// fancy twirl
		pos = (rotationY(lray.y*u_scalings.y*.3)*vec4(pos,1.0)).xyz;
		
		shape = min(shape, dstCube3(pos, vec3(1.0, 3.0, 1.0)*.5));
		pos.y /= u_scalings.y;
		
		if (shape < MINHIT*2.) {
			gpos = pos;
			gpos.y *= (u_scalings.y)*(1.+u_scalings.y);
			//gpos.y *= u_scalings.y+1.;
			//gpos.y += u_scalings.y*.3;
			return shape;
		}
	}
	
	// horizontal tower
	{
		vec3 offs = vec3(0.,-40.,0.);
		vec3 pos = (rotationY(TIME*1.1)*rotationZ(M_PI*.3)*vec4(ray+vec3(0.,.0,-2.)+offs,1.0)).xyz;
		
		//pos.y += u_scalings.z; //TODO
		pos.y /= u_scalings.z;
		shape = min(shape, dstCube3(pos, vec3(1.0, 3.0, 1.0)*.5));
		if (shape < MINHIT*2.) {
			gpos = pos;
			gpos.y *= u_scalings.z;
			return shape;
		}
	}
	
	return shape;
}

vec3 normalFunc(vec3 p) {
	vec3 small_step = vec3(0.001,0.0,0.0);
	vec3 gpos;
	
	float gradX = distFunc(p + small_step.xyy,gpos) - distFunc(p - small_step.xyy,gpos);
	float gradY = distFunc(p + small_step.yxy,gpos) - distFunc(p - small_step.yxy,gpos);
	float gradZ = distFunc(p + small_step.yyx,gpos) - distFunc(p - small_step.yyx,gpos);
	
	return normalize(vec3(gradX, gradY, gradZ));
}

vec4 raymarch(vec3 dir, vec3 origin, inout vec3 gnormal, inout bool ghit,inout vec3 gpos) {
	ghit = false;
	gnormal = vec3(0.);
	
	float dist = 0.0;
	for (int i = 0; i < NUMSTEPS; i++) {
			vec3 pos = origin + dist * dir;
			
			float closest = distFunc(pos,gpos);
			
		if (closest < MINHIT) {
			float depth = log(log(length(pos-origin)))*0.5;
			vec3 ambient = vec3(0.3,0.3,0.3);
			//return normalFunc(pos);
			gnormal = normalFunc(pos);
			vec3 light = vec3(-5.0,5.0,0.0);
			vec3 dir_light = normalize(light-pos);
			float diffuse = max(0.0, dot(gnormal, dir_light));
			ghit = true;
			return vec4(ambient + vec3(1.0)*diffuse, depth);
		}
		if (dist > MAXDIST)
			return vec4(0.0,0.0,0.0, infinity);
		
		dist += closest;
	}
	
	return vec4(0.0);
}

vec4 ssWin(vec2 uv) {
	// fetch window 2x 5y
	uv = uv/16.+vec2(1.,4.)/16.;
	return texture(u_tower,uv);
}

// raytraced plane
vec2 explPlane(vec3 pos, vec3 dir, vec3 n, vec3 a) {
	float t = -dot(pos-a,n)/dot(dir,n);
	if (t<0.0) //nohit
		return vec2(0.0,0.0);
	else
		return vec2(1.0,t);
}

// from: https://iquilezles.org/articles/distfunctions2d/
float sdStar5(in vec2 p, in float r, in float rf)
{
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

//from: https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

//from: https://thebookofshaders.com/13/
float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}
// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)),
                    vec2(-sin(0.5), cos(0.50)));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void fragment()
{
	vec3 CAMPOS = vec3(0.0, 0.0, -5.0);
	vec3 CAMDIR = vec3(0.0);
	vec3 gpos = vec3(0.);
	float u_time = TIME;
	
	//vec2 u_m = u_mouse / u_resolution.xy;
	vec2 u_m = vec2(mod(u_time*.01,1.));
	float perspective = u_m.y; // u_perspective;
	perspective = .2;//u_mouse / u_resolution.xy;
	perspective = max(0.01,perspective); // dont clip ground rt
	
	float scale = 4.;
	vec2 uv = UV;
	uv.y = 1.-uv.y;
	vec2 iuv = viewIndepUV(uv);
	vec2 ndc = iuv * 2.0 - vec2(1.0);
	vec2 ondc = ndc;
	float cpy = u_m.y*25.;
	ndc.y += cpy;
	
	// orthogonal projection
	vec3 camdirOrt = vec3(vec2(0.), 1.0);
	vec3 camposOrt = CAMPOS+vec3(ndc*scale,0.);
	
	// perspective projection
	vec3 camdirPro = normalize(vec3(vec2(ndc.xy), 1.0));
	vec3 camposPro = CAMPOS+vec3(0.,0.,1.);
	
	CAMDIR = camdirOrt*vec3(1.-perspective)+(camdirPro)*vec3(perspective);
	//CAMDIR = normalize(CAMDIR+vec3(0.,u_m.y,0.));
	CAMPOS = camposOrt*vec3(1.-perspective)+(camposPro)*vec3(perspective);
	
	//CAMPOS = (rotationY(u_time)*vec4(CAMPOS,.1)).xyz;
	//CAMDIR = (rotationY(u_time)*vec4(CAMDIR,.1)).xyz;
	vec3 gnormal = vec3(0.);
	bool ghit = false;
	vec4 col = raymarch(CAMDIR, CAMPOS,gnormal,ghit,gpos);
	col.w = 1.;
	
	vec4 bgc = vec4(vec3(0.),1.);
	// clouds front
	{
		vec2 lndc = ndc+vec2(23.,94.23);
		float c = fbm(lndc*4.);
		float d = max(0.,fbm(lndc*3.)*2.-1.2);
		bgc = vec4(vec3(c*d),0.);
		col += bgc;
	}
	
	// texture windows
	vec2 locPos = vec2(0.);
	if (ghit) {
		if (length(gpos.yz) < length(gpos.xy)){
			locPos = gpos.yz-.5;
		} else if (length(gpos.yz) > length(gpos.xy)) {
			locPos = gpos.xy-.5;
		}
		col = ssWin(mod(locPos*5.,vec2(1.)));
		col *= .5;
		COLOR = vec4(col.xyz, 1.0);
	} else { // cuz return is not allowed.
	// sky
	{
		vec2 lndc = ondc;
		//TODO sScale max
		float sSmax = 25.;
		float sScale = min(25.,u_m.y*25. * .05); //TODO
		sScale += ndc.y*5.;
		sScale /= sSmax;
		//sScale = 1.;
		
		// color gradient
		vec4 cg1 = vec4(227.,247.,254.,255.)/255.;
		vec4 cg2 = vec4(33.,106.,173.,255.)/255.;
		
		vec4 cg3 = vec4(249.,109.,58.,255.)/255.;
		vec4 cg4 = vec4(72.,112.,173.,255.)/255.;
		
		// lerp 
		vec4 bgc1 = cg2*sScale+cg1*(1.-sScale);
		//TODO unused //lerp2
		//vec4 bgc2 = cg4*sScale+cg3*(1.-sScale);
		//
		////bgc1 = bgc2*sScale+bgc1*(1.-sScale);
		
		col = bgc1;
	}
	
	// stars
	{
		float sScale = min(25.,u_m.y*25.*.025); //TODO
		vec2 ondc = ndc*sScale; //TODO scroll
		float starSize = sScale; //TODO bind
		vec2 uvStarF = mod(ondc*4.,5.)-vec2(.0);
		vec2 cellID = floor(uvStarF);
		uvStarF = mod(ondc*20.,5.)-vec2(2.5);
		uvStarF = (rotationZ(rand(cellID)*M_PI)*vec4(uvStarF,0.,1.)).xy;
		float r1 = rand(cellID);
		float r2 = rand(vec2(r1,cellID.x));
		uvStarF.x += r1;
		uvStarF.y += r2;
		uvStarF *= (r2*.7+.3)*3.;
		bgc.xyz = vec3(floor(1.-sdStar5(uvStarF,.7*starSize,.5)));
		if (bgc.x > 0.1) {
			col = max(vec4(0.),bgc);//rand(cellID);
			//col += rand(cellID); // debug tiles
		}
	}
	
	// clouds back
	{
		vec2 lndc = ndc*.5;
		float c = fbm(lndc*4.);
		float d = max(0.,fbm(lndc*3.)*2.-1.2);
		bgc = vec4(vec3(c*d),1.);
		col += bgc;
	}
	
	// sun
	float ds = dstSphere(ndc*8.,vec2(-6.,cpy*3.+7.),.5);
	if (ds < 1.) {
		iuv = vec2(1.);
		//uv *= (sin(u_time)*.5+.5);
		//vec3 CAMDIR = vec3(1.,1.,0.);
		//float fade = ndc.y*10.+sin(ndc.x*3.+u_time);
		bool even = mod((ndc.x*3.+u_time),2.) < 1.;
		
		float fade = ndc.y*10.+mod((even ? 1. : -1.)*(ndc.x*3.+u_time),1.);
		//iuv *= .1;
		//float lane = max(0.,1.-1000.*0.7/(500.0*10.+1.0)*fade*fade);
		//iuv += lane*lane;
		bgc = vec4(iuv,vec2(0.));
		col = bgc;
	}
	
	// mountain2
	{
		float se = u_time*.5;
		vec2 lndc = ndc;
		bool even = mod((lndc.x*3.+se),2.) < 1.;
		lndc.y -= cpy*.5;
		float fade = lndc.y*10.+mod((even ? 1. : -1.)*(lndc.x*3.+se),1.);
		float lane = max(0.,1.-1000.*0.7/(500.0*10.+1.0)*fade*fade);
		float v = round(lane+.5);
		if (v > .5 || lndc.y < 0.) {
			bgc = vec4(vec3(.2,.2,.2),0.);
			col = bgc;
		}
	}
	
	// mountain
	{
		vec2 lndc = ndc;
		bool even = mod((ndc.x*3.+u_time),2.) < 1.;
		lndc.y -= cpy*.55;
		
		float fade = lndc.y*10.+mod((even ? 1. : -1.)*(lndc.x*3.+u_time),1.);
		float lane = max(0.,1.-1000.*0.7/(500.0*10.+1.0)*fade*fade);
		float v = round(lane-.2);
		if (v > .5 || lndc.y < 0.) {
			bgc = vec4(vec3(.2,.4,.2),0.);
			col = bgc;
		}
	}
	
	// ground
	{
		vec3 n = vec3(0.,1.,0.);
		vec2 p = explPlane(vec3(0.,1.,0.),CAMDIR,n,vec3(0.0,0.0,0.0));
		vec3 pos = vec3(0.,1.,0.)+CAMDIR*p.y;
		if (p.x==1. && !ghit){
			vec3 origin = vec3(0.,1.,0.);
			float depth = log(log(length(pos-origin)))*0.5;
			vec3 ambient = vec3(0.1,0.1,0.1);
			vec3 light = vec3(-5.0,5.0,0.0);
			vec3 dir_light = normalize(light-pos);
			float diffuse = max(0.0, dot(n, dir_light));
			ghit = true;
			bgc = vec4(ambient + vec3(1.0)*diffuse, 1.);
			col = bgc;//vec4(.4,.4,.4,1.);
		}
	}
	
	//col = bgc;
	
	col *= .5;
	
	COLOR = vec4(col.xyz, 1.0);
	}
	uv = uv/16.+vec2(1.,4.)/16.;
	//COLOR = vec4(texture(u_tower,uv).xyz,1.);
	
}
