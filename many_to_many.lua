engine.name="many_to_many2"

PADS=8
BUFFERS=4
current_pad=1
alt=0
toggles={}

function init()
  
  params:add_separator("many_sep","many to many")
  
  params:add_group("buffer_group","buffers",4)
  
for i=1,BUFFERS do

params:add_file("buffer_file"..i,"buffer_file "..i,_path.audio)
params:set_action("buffer_file"..i,function(x) print("buffer "..i.."file "..x) engine.buffer_file(i,x) end)

end

for i=0,BUFFERS-1 do
for j=1,PADS do
  
  local pad_number=(i*PADS)+j
  print("pad number "..pad_number)
  toggles[pad_number]=0

   params:add_group("loop_group"..pad_number,"loop "..pad_number,5)
  
  params:add_separator("loop_sep"..pad_number,"loop "..pad_number)
  params:add_number("loop_buffer"..pad_number,"loop_buffer "..pad_number,1,4,i+1)
  params:set_action("loop_buffer"..pad_number,function(x) print("loaded buffer "..x) engine.loop_buffer(pad_number,x) end)
  params:add_control("loop_start"..pad_number,"loop_start "..pad_number,controlspec.new(0,1,'lin',0.01,0,'%',0.01))
  params:set_action("loop_start"..pad_number,
    function(x) engine.loop_start(pad_number,x) engine.loop_end(pad_number,params:get("loop_length"..pad_number)+x) end)
  params:add_control("loop_length"..pad_number,"loop_length "..pad_number,controlspec.new(0,1,'lin',0.01,0.11,'%',0.01))
  params:set_action("loop_length"..pad_number,function(x) engine.loop_end(pad_number,params:get("loop_start"..pad_number)+x) end)
  params:add_control("loop_rate"..pad_number,"loop_rate "..pad_number,controlspec.new(0,10,'lin',0.01,1,'x',0.01))
  params:set_action("loop_rate"..pad_number,function(x) engine.loop_rate(pad_number,x) end)
  params:add_control("loop_vol"..pad_number,"loop_vol "..pad_number,controlspec.new(0,1,'lin',0.01,1,'',0.01))
  params:set_action("loop-vol"..pad_number,function(x) engine.loop_vol(pad_number,x) end)
  
  params:add_binary("loop_play"..pad_number,"loop_play "..pad_number,"toggle",0)
  params:set_action("loop_play"..pad_number,function(x)  engine.loop_play(pad_number,params:get("loop_buffer"..pad_number),x) end)
  
end
end

end

function getfilename(path)
  pathname,filename,ext=string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
  return filename
end

g = grid.connect()

g.key = function(x,y,z)
  local pad_pressed=((y-1)*PADS)+x
  print("pad "..pad_pressed)
  current_pad=x
  if x<=8 and toggles[pad_pressed]==0 and z==1 then
    params:set("loop_play"..pad_pressed,1)
    g:led(x,y,15)
    toggles[pad_pressed]=1
  elseif x<=8 and toggles[pad_pressed]==1 and z==1 then
    params:set("loop_play"..pad_pressed,0)
    g:led(x,y,0)
    toggles[pad_pressed]=0
  end
  g:refresh()
  redraw()
end

