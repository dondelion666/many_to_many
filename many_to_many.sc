// CroneEngine_one_to_many
Engine_many_to_many : CroneEngine {

    var buffers;
    var synths;

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
    
    SynthDef("bufplayer", {
      arg out=0, buf, rate=1, start=0, end=1, trig=0, amp=1;
      var env, snd, pos, frames;
      
      // rate is modified by BufRateScale to convert between sampling rates
	    rate = rate*BufRateScale.kr(buf);
	    // frames is the number of frames
	    frames = BufFrames.kr(buf);
	    
	    // Phasor is a ramp
	    pos=Phasor.ar(
	      trig:trig,
		    rate:rate,
		    start:start*frames,
		    end:end*frames,
		    resetPos:start*frames,
	    );
	    
	    env=EnvGen.ar(Env.asr(0.01,1,0.01,0),gate:trig,doneAction:0);
      
  	  snd=BufRd.ar(
		    numChannels:1,
		    bufnum:buf,
		    phase:pos,
		    loop: 1,
		    interpolation:4,
	    );
	    
	    snd=snd*env*amp;
	    
  	  Out.ar(out,snd); 
      }).add;
    
    context.server.sync;
    
   
    synths=Array.fill(16,{arg i;
        Synth("bufplayer",target:context.server);
        });
        
    buffers=Array.newClear(4);
    
    this.addCommand("file", "is", { arg msg;

                  var slot = msg[1];

                  var path = msg[2];

                  var newbuf;

                  var oldbuf;

                  if(slot < 4 && slot >= 0, {

                        newbuf = Buffer.read(context.server, path);

                        // we should free the existing buf if there is one

                        if(buffers[slot].notNil, {

                              oldbuf = buffers[slot];

                              buffers[slot] = newbuf;

                              oldbuf.free;

                        }, {

                              buffers[slot] = newbuf;

                        });

                  });

            }); 
         
    this.addCommand("loop_play", "iii", { arg msg;
        synths[msg[1]-1].set(\buf,buffers[msg[2]],\trig,msg[3]);
        });
    
    this.addCommand("loop_buffer", "if", {arg msg;
        synths[msg[1]-1].set(\buf,buffers[msg[2]]);
        });
        
    this.addCommand("loop_start", "if", {arg msg;
        synths[msg[1]-1].set(\start,msg[2]);
        });
        
    this.addCommand("loop_end", "if", {arg msg;
        synths[msg[1]-1].set(\end,msg[2]);
        });
        
    this.addCommand("loop", "ii", {arg msg;
        synths[msg[1]-1].set(\loop,msg[2]);
        });
        
    this.addCommand("loop_rate", "if", {arg msg;
        synths[msg[1]-1].set(\rate,msg[2]);
        });
    
    this.addCommand("loop_vol", "if", {arg msg;
        synths[msg[1]-1].set(\amp,msg[2]);
        });
        

      
    
    }

    free {
        synths.free;
        buffers.free;
    }
}
