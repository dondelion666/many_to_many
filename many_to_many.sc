// CroneEngine_one_to_many
Engine_many_to_many2 : CroneEngine {

    var buffers;
    var synths;

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
    
    SynthDef("bufplayer", {
      arg out=0, buf=0, trig=0, start=0, end=1, rate=1, amp=1;
      var env, snd, frames;
      
      frames = BufFrames.kr(buf);
      
	    env=EnvGen.ar(Env.asr(0.01,1,0.01,0),gate:trig,doneAction:0);
      
  	  snd=LoopBuf.ar(
		    numChannels:1,
		    bufnum:buf,
		    rate:rate,
		    gate:trig,
		    startPos:start*frames,
		    startLoop:start*frames,
		    endLoop:end*frames,
	    );
	    
	    snd=snd*env*amp;
	    
  	  Out.ar(out,snd); 
      }).add;
    
    context.server.sync;
    
    synths=Array.fill(32,{Synth("bufplayer",target:context.server);
        });
        
    buffers=Array.fill(4, {Buffer.alloc(context.server,1,1)});
    
    context.server.sync;
    
    this.addCommand("buffer_file", "is", { arg msg;
                    var buf_slot=msg[1]-1;
                    var file_path=msg[2];
                    
                     "buffer_file".postln;
                    msg[1].postln;
                    msg[2].postln;
                    
                    Buffer.read(context.server, file_path, action:{ arg buf;
                    buffers[buf_slot].free;
                    buffers[buf_slot]=buf;
                    });
                    });
         
    this.addCommand("loop_play", "iii", { arg msg;
                    var synth_slot=msg[1]-1;
                    var buf_slot=msg[2]-1;
                    
                    "loop_play".postln;
                    msg[1].postln;
                    msg[2].postln;
                    msg[3].postln;
                    
                    synths[synth_slot].set(\buf,buffers[buf_slot],\trig,msg[3]);
                    });
                    
    this.addCommand("loop_start", "if", {arg msg;
        synths[msg[1]-1].set(\start,msg[2]);
        });
        
    this.addCommand("loop_end", "if", {arg msg;
        synths[msg[1]-1].set(\end,msg[2]);
        });
        
    this.addCommand("loop_rate", "if", {arg msg;
        synths[msg[1]-1].set(\rate,msg[2]);
        });
        
    this.addCommand("loop_vol", "if", {arg msg;
        synths[msg[1]-1].set(\amp,msg[2]);
        });
        
    
    }

    free {
        synths.do({arg item, i; item.free;});
        buffers.do({arg item, i; item.free;});
    }
}
