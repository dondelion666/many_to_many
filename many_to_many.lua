engine.name="many_to_many"

PADS=8
BUFFERS=4
current_pad=1
alt=0
toggles={}

function init()
  
for i=1,BUFFERS do

params:add_file("buffer_file"..i,"buffer_file "..i,_path.audio)
params:set_action("buffer_file"..i,function(x) engine.file(i,x) end)

end

for i=1,PADS do
  
  toggles[i]=0
  
  params:add_number("loop_buffer"..i,"loop_buffer "..i,1,4,1)
  params:set_action("loop_buffer"..i,function(x) engine.loop_buffer(i,x) end)
  params:add_control("loop_start"..i,"loop_start "..i,controlspec.new(0,1,'lin',0.01,0,'%',0.01))
  params:set_action("loop_start"..i,function(x) engine.loop_start(i,x) engine.loop_end(i,params:get("loop_length"..i)+x) end)
  params:add_control("loop_length"..i,"loop_length "..i,controlspec.new(0,1,'lin',0.01,0.11,'%',0.01))
  params:set_action("loop_length"..i,function(x) engine.loop_end(i,params:get("loop_start"..i)+x) end)
  params:add_control("rate"..i,"rate "..i,controlspec.new(0,10,'lin',0.01,1,'x',0.01))
  params:set_action("rate"..i,function(x) engine.loop_rate(i,x) end)
  params:add_control("vol"..i,"vol "..i,controlspec.new(0,1,'lin',0.01,1,'',0.01))
  params:set_action("vol"..i,function(x) engine.loop_vol(i,x) end)
  
  params:add_binary("loop_play"..i,"loop_play "..i,"toggle",0)
  params:set_action("loop_play"..i,function(x) engine.loop_play(i,params:get("loop_buffer"..i),x) end)
  
end

end

function key(n,d)
  if n==2 then
    alt=d
  end
end

function enc(n,z)
  if alt==0 then
    if n==1 then
      current_pad=util.clamp(current_pad+z,1,16)
    elseif n==2 then
      params:delta("loop_start"..current_pad,z)
    elseif n==3 then
      params:delta("loop_end"..current_pad,z)
    end
  elseif alt==1 then
    if n==1 then
    elseif n==2 then
      params:delta("loop_rate"..current_pad,z)
    elseif n==3 then
      params:delta("loop_vol"..current_pad,z)
    end
  end
  redraw()
end

function getfilename(path)
  pathname,filename,ext=string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
  return filename
end

g = grid.connect()

g.key = function(x,y,z)
  current_pad=x
  if y==1 and toggles[x]==0 and z==1 then
    params:set("loop_play"..x,1)
    g:led(x,y,15)
    toggles[x]=1
  elseif y==1 and toggles[x]==1 and z==1 then
    params:set("loop_play"..x,0)
    g:led(x,y,0)
    toggles[x]=0
  end
  g:refresh()
  redraw()
end

