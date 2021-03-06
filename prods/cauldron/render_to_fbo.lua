-- render_to_fbo.lua

function render_to_fbo(fbo, shader)
  local u = shader.uloc
  local m = mouseinfo
  
  local w = fbo.w
  local h = fbo.h
  local w2 = w*0.5
  local h2 = h*0.5
  local qs = fbo.qs
  
  glViewport(0,0,w,h)
  
  glMatrixModeProjection()
  glLoadIdentity()
  --glPerspective(60.0, 1, 1.0, 100.0)
  --glOrtho(0.0, fbo.w, 0.0, fbo.h, 1.0, 100.0)
  glOrtho(-w2, w2, -h2, h2, 1.0, 100.0)
  
  glMatrixModeModelView()
  glLoadIdentity()
  --glTranslate(-fbo.w*0.5, -fbo.h*0.5, -50)
  glTranslate(0,0, -50)
  
  glBindFramebuffer(fbo.fboId)
  assertgl()

  glClearColor(0, 0, 0, 255)
  glClear()
  
  glUseProgram(shader.prog)
  assertgl()
  
  local mfw = w/qs -- mouse factor for width
  local mfh = h/qs -- mouse factor for height
  
  glUniformf(u.resolution, fbo.w, fbo.h);
  assertgl()
  
  glUniformf(u.mouse, m.pos.x    * mfw, m.pos.y    * mfh,
                      m.clickx() * mfw, m.clicky() * mfh)
  assertgl()
  
  glUniformi(u.frame, shader_frame_num)
  assertgl()
  
  glPushMatrix()
  beginQuadGL()
    colorGL(255, 255, 255, 255)
    vectorGL(  -w2, -h2, 0)
    vectorGL(   w2, -h2, 0)
    vectorGL(   w2,  h2, 0)
    vectorGL(  -w2,  h2, 0)
  endGL()
  glPopMatrix()
  
  glUseProgram(0);
  
  glBindFramebuffer(0);

  --glBindTexture(fbo.texId);
  --glGenerateMipmap();
  glBindTexture(0);
end

function render_to_fbo_with_input(fbo, shader, ...)
  local input = {...}
  
  local u = shader.uloc
  local m = mouseinfo
  
  local w = fbo.w
  local h = fbo.h
  local w2 = w*0.5
  local h2 = h*0.5
  local qs = fbo.qs

  local vps = 1
  
  glBindFramebuffer(fbo.fboId)
  assertgl()

  glViewport(0,0,w,h)

  glMatrixModeProjection()
  glLoadIdentity()
  --glOrtho(-1, 1, -1, 1, 1.0, 100.0)
  glOrtho(-vps, vps, -vps, vps, 1.0, 100.0)
  
  glMatrixModeModelView()
  glLoadIdentity()
  glTranslate(0,0, -50)  

  --if fbo==fbotest then
    glClearColor(0,0,0,255)
    glClear()
  --end
  
  glUseProgram(shader.prog)
  assertgl()
  
  local mfw = w/qs -- mouse factor for width
  local mfh = h/qs -- mouse factor for height
  
  glUniformf(u.resolution, w, h);
  --glUniformf(u.resolution, w, h);
  assertgl()
  
  glUniformf(u.mouse, m.pos.x    * mfw, m.pos.y    * mfh,
                      m.clickx() * mfw, m.clicky() * mfh)
  assertgl()
  
  glUniformi(u.frame, shader_frame_num)
  assertgl()

  -- do u.globaltime here as well
  -- u.globaltime from u.frame
  --glUniformf(u.globaltime, 
  

  for i=1,#input,1 do
    if i>2 then break end
    local tex = input[i]
    glActiveTexture(i-1);
    glBindTexture(tex.texId)
    --glSetTexParams(GL_NEAREST)
    assertgl()
  end
  
  local samplers = {u.sampler1, u.sampler2}

  for i=1,#input,1 do
    if i>2 then break end
    glUniformi(samplers[i], i-1);
    assertgl()
  end
  
  if shader.extrauniforms ~= nil then
    shader.extrauniforms()
  end

  --glBindTexture(fbo.texId);
  
  -- glColor4f
  
  glDisable(GL_BLEND)

  beginQuadGL()
    vectorGL( -vps, -vps,  0)
    vectorGL(  vps, -vps,  0)
    vectorGL(  vps,  vps,  0)
    vectorGL( -vps,  vps,  0)
  endGL()
  
  glEnable(GL_BLEND)
  
  glUseProgram(0);
  glBindFramebuffer(0);

  --glBindTexture(fbo.texId);
  --glGenerateMipmap();
  glBindTexture(0);
end
