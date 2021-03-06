-- mainshader.lua

mainshader = {}
mainshader.uloc = {}

function gather_shader_uniforms(shader)
  if shader.uloc == nil then
    shader.uloc = {}
  end

  glGetError()

  local u = shader.uloc

  u.frame       = glGetUniformLocation(shader.prog, "iFrame")        assertgl()
  u.resolution  = glGetUniformLocation(shader.prog, "iResolution")   assertgl()
  u.mouse       = glGetUniformLocation(shader.prog, "iMouse")        assertgl()
  u.sampler     = glGetUniformLocation(shader.prog, "iChannel0")     assertgl()
  u.sampler1    = glGetUniformLocation(shader.prog, "iChannel0")     assertgl()
  u.sampler2    = glGetUniformLocation(shader.prog, "iChannel1")     assertgl()
  u.globaltime  = glGetUniformLocation(shader.prog, "iGlobalTime")   assertgl()
end

shaderheader = [[
uniform vec2       iResolution;           // viewport resolution (in pixels)
uniform int        iFrame;                // shader playback frame
uniform vec4       iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform sampler2D  iChannel0;             // input channel. XX = 2D/Cube
uniform sampler2D  iChannel1;             // input channel. XX = 2D/Cube
uniform float      iGlobalTime;           // global time

]]

shaderfooter = [[

void main()
{
    mainImage(gl_FragColor, gl_FragCoord.xy );
}
]]

shaderpassthruvertex = [[
void main(void)
{ 
    gl_Position = gl_Vertex;
    gl_Position.w = 1.0;
}
]]

shadermvpvertex = [[
void main(void)
{ 
    // normal MVP transform
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
]]

function assembleshadersource(file)
  local s = shaderheader .. readFile(file) .. shaderfooter
  return s
end

mainshader.prog,shadres = glCreateProgram(

[[
varying vec3 N, V;

void main(void)
{ 
    // normal MVP transform
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    
    // map object-space position onto unit sphere
    V = gl_Vertex.xyz;

    // eye-space normal
    N = gl_NormalMatrix * gl_Normal;
}
]],

[[
uniform vec2      iResolution;           // viewport resolution (in pixels)
uniform int       iFrame;                // shader playback frame
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform sampler2D iChannel0;             // input channel

varying vec3 V; // object-space position
varying vec3 N; // eye-space normal

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    fragColor = texture2D(iChannel0, fragCoord/iResolution.xy);
}

void main()
{
    mainImage(gl_FragColor, V.xz * 5.12 );
    //mainImage(gl_FragColor, V.xz * vec2(10.24,5.12) );
}
]])

assertglshader(shadres)

gather_shader_uniforms(mainshader)

function use_shader(shader)
  local u = shader.uloc
  local m = mouseinfo
  local t = fbotest
  local w = t.w
  local h = t.h
  local qs = t.qs
  
  glUseProgram(shader.prog)
  
  local mfw = w/qs -- mouse factor for width
  local mfh = h/qs -- mouse factor for height
  
  glUniformf(u.resolution, w, h);
  assertgl()
  
  glUniformf(u.mouse, m.pos.x    * mfw, m.pos.y    * mfh,
                      m.clickx() * mfw, m.clicky() * mfh)
  assertgl()
  
  glUniformi(u.frame, shader_frame_num)
  assertgl()

  -- do u.globaltime here as well

  --enableTexturing()
  glActiveTexture(0);
  glBindTexture(t.texId)
  glUniformi(u.sampler, 0);
  assertgl()
end

shader_frame_num = 0

function render()
  local h = 4.5
  local t = fbotest
  
  use_shader(mainshader)

  beginQuadGL()
    colorGL(255,255,255,255)
    vectorGL(    0, h,    0)
    vectorGL( t.qs, h,    0)
    vectorGL( t.qs, h, t.qs)
    vectorGL(    0, h, t.qs)
  endGL()
  
  glUseProgram(0)
  
  trace2()
  
  WidgetLib.renderAll()
  
  shader_frame_num = shader_frame_num + 1
end
