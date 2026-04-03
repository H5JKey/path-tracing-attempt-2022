#define MaxDist 500.0

float ID;
float ReID;


float mandDist(vec3 pos, vec4 mandelbumb) {

    pos.x+=mandelbumb.x;
    pos.y+=mandelbumb.y;
    pos.z+=mandelbumb.z;
    
    /*float a=pos.y;
    pos.y=pos.z;      //rotate mandelbumb 
    pos.z=a;*/




    
    pos/=mandelbumb.w;
    
    vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i <20 ; i++) {
		r = length(z);
		if (r>100.) break;
		
        
        float Power=8.0;
		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow( r, Power-1.0)*Power*dr + 1.0;
		
		// scale and rotate the point
		float zr = pow( r,Power);
		theta = theta*Power;
		phi = phi*Power;
		
		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=pos;
	}
	return (0.5*log(r)*r/dr)*mandelbumb.w;
}




float cubeDist(vec3 p,vec4 cube) {
   return max(abs(p.x-cube.x), max(abs(p.y-cube.y), abs(p.z-cube.z)))-cube.w/2.0;
}

float sphDist(vec3 p,vec4 sph) {
    return length(sph.xyz-p)-sph.w;
}

float planeDist(vec3 p) {
   return p.y;
}

float GetDist(vec3 p) {
    vec4 sph1= vec4(-1.0,0.8,0.5,0.8);
    vec4 light1=vec4(0.0,5.0,0.0,4.0);//Свет!!
    light1.y+=(light1.w/2.0);//Для того что бы свет всегда был в потолке
    
    vec4 sph2=vec4(1.0,0.8,-1.5,0.8);
    
    vec4 cube1 = vec4(8.0, 4, 0.0, 8.0);
    vec4 cube2=vec4(-8.0,4,0.0,8.0);
    vec4 cube3=vec4(0.0,4,8.0,8);
    vec4 cube4=vec4(0.0,12,0.0,8);
    vec4 cube5=vec4(0.0,4,-8,8.0);
    
    vec4 mandelbumb=vec4(2.0,-1.0,2.0,1.2);




    float planedist=planeDist(p);
    if (ReID==0.0) planedist=MaxDist*2.0;
    
    float cube1dist=cubeDist(p,cube1);
    if (ReID==1.0) cube1dist=MaxDist*2.0;

    float sph1dist=sphDist(p,sph1);
    if (ReID==2.0) sph1dist=MaxDist*2.0;

    float light1dist=cubeDist(p,light1);
    if (ReID==3.0) light1dist=MaxDist*2.0;
    
    float sph2dist=sphDist(p,sph2);
    if (ReID==4.0) sph2dist=MaxDist*2.0;
        
    float cube2dist=cubeDist(p,cube2);
    if (ReID==5.0) cube2dist=MaxDist*2.0;
    
    float cube3dist=cubeDist(p,cube3);
    if (ReID==6.0) cube3dist=MaxDist*2.0;
    
    float cube4dist=cubeDist(p,cube4);
    if (ReID==7.0) cube4dist=MaxDist*2.0;

    float cube5dist=cubeDist(p,cube5);
    if (ReID==8.0) cube5dist=MaxDist*2.0;
    
    float mandelbumbdist=mandDist(p,mandelbumb);
    if (ReID==9.0) mandelbumbdist=MaxDist*2.0;

    //sph1dist=99999.0;
    //sph2dist=9999.0;
    //cube1dist=9999.0;
    //cube2dist=9999.0;
    //cube3dist=9999.0;
    //cube4dist=9999.0;
    

    float dist=min(mandelbumbdist,min(cube5dist,min(cube4dist,min(cube3dist,min(cube2dist,min(sph1dist,min(min(light1dist,min(sph2dist,cube1dist)),planedist)))))));
    if (dist==cube1dist) ID=1.0;
    else if (dist==sph1dist) ID=2.0;
    else if (dist==light1dist) ID=3.0;
    else if (dist==sph2dist) ID=4.0;
    else if (dist==cube2dist) ID=5.0;
    else if (dist==cube3dist) ID=6.0;
    else if (dist==cube4dist) ID=7.0;
    else if (dist==cube5dist) ID=8.0;
    else if (dist==mandelbumbdist) ID=9.0;
    else if (dist==planeDist(p)) ID=0.0;
    return dist;
}

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));

    return normalize(n);
}



vec4 GetMaterial(vec3 p,vec3 norm) {
  norm=abs(norm);
  switch (int(ID)) {
    case -1: return vec4(0.0);//sky material
    case 0: return vec4(vec3(1.0),1.0);//ground material
    case 1: return vec4(vec3(0.2,1.0,0.2),1.0);
    case 2: return vec4(vec3(1.0),0.0);
    case 3: return vec4(vec3(1.0),1.0);
    
    //case 4: return vec4(vec3(texture(iChannel1,p.xy)*norm.z+texture(iChannel1,p.xz)*norm.y+texture(iChannel1,p.yz)*norm.x),0.9);//with texture
    case 4: return vec4(vec3(1.0,0.4,0.0),1.0);//without texture
    
    case 5: return vec4(vec3(1.0,0.2,0.2),1.0);
    case 6: return vec4(vec3(1.0),1.0);
    case 7: return vec4(vec3(1.0),1.0);
    case 8: return vec4(vec3(1.0),1.0);
    case 9: return vec4(vec3(1.0),0.5);
  }
}


float RayMarch(vec3 ro, vec3 rd, out vec3 p) {
   float dist=0.0;
   for (int i=0; i<100; i++) {
      p=ro+rd*dist;
      float ds=GetDist(p);
      if (ds<0.01) break;
      dist+=ds;
      if (dist>MaxDist) {
         break;
      }
   }
   return dist;
}


float fading;


float fade(float value, float start, float end)
{
    return (clamp(value,start,end)-start)/(end-start);
}

float random(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }
float random(vec2 co){ return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); }
float random(vec3 co){ return random(co.xy+random(co.z)); }






vec3 randomOnSphere(vec3 co){
  vec3 rand= vec3(random(co*(iTime)*2.0),random(co*(iTime)*4.0),random(co*(iTime)));
  
  float theta = rand.x * 2.0 * 3.14159265;
  float v = rand.y;
  float phi = acos (2.0 * v-1.0);
  float r = pow(rand.z,1.0 / 3.0);
  float x=r*sin(phi)*cos (theta);
  float y=r* sin(phi)*sin(theta);
  float z=r*cos(phi);
  return vec3(x, y, z);
}

# define MaxDe 8

 vec3 Trace(vec3 ro, vec3 rd) {
    vec3 p;
    vec3 color=vec3(1.0);
    vec3 f=vec3(1.0);
    
    float dist;

    vec4 material;
    vec3 norm;
    for (int i=0; i<MaxDe;  i++) {
      dist=RayMarch(ro,rd,p);
      
      norm=GetNormal(p);
      material=GetMaterial(p,norm);      
      
      if (dist<MaxDist) {
          color*=f*material.xyz;
          if (ID==3.0) {  //Определение источников света
              return color;
          } else {
             vec3 ideal=reflect(rd,norm);
             vec3 rnd=randomOnSphere(p);
             rnd=normalize(rnd*dot(rnd,norm));
             
             rd=mix(ideal,rnd,material.w);
             
             ro=p;
             ReID=ID;
             
             f*=0.8;


          }
       }
      else {        
        ID=-1.0;
        material=GetMaterial(p,norm);
        
        color*=0.4*f*material.xyz;

        f=vec3(0.0);
        return color;
      }
   }
   return vec3(0.0);
}


mat3 getCam (vec3 ro, vec3 lookAt) {
    vec3 camF = normalize(vec3(lookAt-ro));
    vec3 camR = normalize (cross(vec3(0, 1, 0), camF));
    vec3 camU = cross ( camF, camR);
    return mat3(camR, camU, camF);
}


void pR(inout vec2 p, float a) {
    p=cos(a)*p+sin(a)*vec2(p.y, -p.x);
}



void mouse(inout vec3 ro) {
    vec2 m = iMouse.xy / iResolution.xy;
    pR(ro.yz, m.y*3.14*0.5 - 0.5);
    pR(ro.xz, m.x * 2.0 * 3.14);
}

#define NUM_SAMPLES 1

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    
    fading = (fade(iTime,-2.,4.));
    vec2 uv = (2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
    vec3 ro = vec3(0,3,-3.9);//Наше положение
    vec3 lookAt=vec3(0,0,0);//Куда смотрим
    
   //mouse(ro);
    
   vec3 rd = getCam(ro, lookAt)*normalize(vec3(uv, 1.0));
   //vec3 rd=normalize(vec3(uv,1.0));

    vec3 summ=vec3(0.0);
    
    for (int i=0; i<NUM_SAMPLES; i++)
    {
      ID=-1.0;
      ReID=-1.0;
      vec3 col=Trace(ro,rd);
      summ+=col;
    }
    
    summ/=float(NUM_SAMPLES);
    
    float white = 20.0;
	summ *= white * 16.0;
	summ = (summ * (1.0 + summ / white / white)) / (1.0 + summ);
        
	if (iFrame<=0) {
           fragColor = vec4(summ, 1);
        } else {
           fragColor = vec4(summ, 1) + texelFetch(iChannel0, ivec2(fragCoord), 0);
        }

}



