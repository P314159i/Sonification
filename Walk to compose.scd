:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
             WALK to Compose
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


(NdefMixer(s);
s.meter;)

____________________________________________
//34 sec envelope * 10=dur + 15 second fadeout
(
Ndef(\playalong0, { |a = 204, gate = 1, amp = 1|
    var env = Env.new([0,0.07,0.15,0.45,0.5,0.3,0.1,0], [10,4,4,2,4,2], 'lin');
    var envGen = EnvGen.kr(env, gate, timeScale: 10, doneAction: 2);
    var sig = SinOsc.ar(a, phase:4+SinOsc.ar(a/100));
    [0, sig * envGen * amp];
}).play;

Ndef(\playalong1, { |b = 204.5, gate = 1, amp = 2|
    var env = Env.new([0,0.07,0.15,0.45,0.5,0.3,0.1,0], [12,3,7,4,4,4], 'lin');
    var envGen = EnvGen.kr(env, gate, timeScale: 10, doneAction: 2);
	var sig = SinOsc.ar(b, phase: b/100);
    [sig * envGen * amp, 0];
}).play;

Ndef(\playalong0).fadeTime = 15;
Ndef(\playalong1).fadeTime = 15;
Ndef(\playalong0).set(\gate, 1);
Ndef(\playalong1).set(\gate, 1);
)


(Ndef(\playalong0).xset(\a, 203);
Ndef(\playalong1).xset(\b, 210);)


(Ndef(\playalong0).stop(10);
Ndef(\playalong1).stop(4);)

(Ndef(\playalong0).stop(4);
Ndef(\playalong1).stop(10);)


(Ndef(\playalong0).clear(4);
Ndef(\playalong1).clear(4);
Ndef(\playalong0).stop(4);
Ndef(\playalong1).stop(4);)


______________________________________
//160 sec envelooe + 15 sec fadeout
(
Ndef(\fb0, {| freq = 290, feedback=0.001, delay=0.02 ,  q = 0, p = 0, gate = 1, hpf = 1600|
	var sig, input, ch1, ch2, stereo, mod, ampEnv, hpfEnv;

	mod = EnvGen.ar(Env.adsr(100, 1000,5000, 10, curve: 4), gate, doneAction: 2);
	mod = mod * feedback/1000;

	ampEnv = EnvGen.kr(Env([0, 0.1, 0.8, 0.5, 0], [10, 60, 50, 40], [2, 1, 0, -2]), gate, doneAction: 2) * 0.5;
	hpfEnv = EnvGen.kr(Env([0, hpf, hpf, hpf*2, 0], [10, 60, 50, 40], [2, 1, 0, -2]), gate, doneAction: 2) * 0.5;

	sig = PMOsc.ar(freq, freq*2,0.1) + RLPF.ar(PMOsc.ar(freq), XLine.kr(200, 2000, 5), 0.2);


	sig = FBSineC.ar(freq,1.9) + RLPF.ar(PMOsc.ar(freq), XLine.kr(200, 2000, 5), 0.2);


	sig = sig + SinOsc.ar(freq + 10, p);
	sig = sig + SinOsc.ar(freq, q);
	sig = HPF.ar(sig, hpfEnv);

	sig = sig.thresh(SinOsc.ar(GbmanL.ar(3*freq).range(freq,freq*4)));

	ch1 = sig + LocalIn.ar(1, 0);
	ch2 = sig + LocalIn.ar(1, 1);

	ch1 = DelayC.ar(ch1, 1, SinOsc.ar(q, delay).range(delay, delay * 0.2));
	ch2 = DelayC.ar(ch2, 1, SinOsc.ar(p, delay).range(delay * 0.2, delay * 0.5));

	LocalOut.ar([ch1 * feedback * rrand(0.1, 0.999), 0]);
	LocalOut.ar([0, ch2 * feedback * rrand(0.1, 0.99999)]);



	stereo = [ Limiter.ar(FreeVerb.ar(ch1, 0.1, 0.2, 0.3)), Limiter.ar(FreeVerb.ar(ch2, 0.1, 0.5, 0.2)) ];
	LPF.ar(stereo , 2000) * ampEnv;

}).play;

Ndef(\fb0).fadeTime = 15;
Ndef(\fb0).set(\gate, 1);
)

(

Tdef(\asdf, {

	inf.do{

		~freqPlayAlong = rrand(400,800); Ndef(\fb0).xset (\freq, ~freqPlayAlong);

		10.wait;

	}

}).play

)

(

var pat = Pseq([456,890,450], inf).asStream;

var patDur = Pseq([2,5,10], inf).asStream;

Tdef(\asdf, {

	inf.do{

		~freqPlayAlong  = pat.next; Ndef(\fb0).xset (\freq, ~freqPlayAlong);

		patDur.next.postln.wait;

	}

}).play

)



       ////PlayAlong[0-1]
(Ndef(\playalong0).xset(\a, 312);
Ndef(\playalong1).xset(\b, 270);)

Ndef(\fb0).xset (\freq, ~freqPlayAlong);
Ndef(\fb0).xset(\feedback, 0.9);
Ndef(\fb0).xset (\q, 0.02, \p, 0.5);  // [0.02 to 0.35
Ndef(\fb0).xset (\delay, 0.08); // [0.005 to 0.06 ]


(
Ndef(\fb0).xset(\gate, 0);
Ndef(\fb0).clear(8);
)


___________________________________________________________
//31 sec envelope + fade time 8

(
Ndef(\LR, { |freq=270, envDur=#[3,8,2,8,2,8], envCurve=0.2, phase=0, phaseFreq=0.07, amp=0.5|
    var envGen = EnvGen.kr(Env.new([0,0.3,0.6,0.8,0.5,0.3,0.1,0], envDur, envCurve), doneAction: 2);
    var sig = SinOsc.ar(freq, phase: phase + SinOsc.ar(phaseFreq)) / 10;

	Pan2.ar(sig * amp * envGen, SinOsc.kr(amp), Line.kr(0.2, 1, 8)) * 0.8;
}).play;

Ndef(\LR).fadeTime = 8;
)

//fluctuating the freq fast between 100's and 400's to get layers due to fadeTime
Ndef(\LR).xset(\freq, 512, \phase, 0.02 , \envCurve, 0.5, \phaseFreq, 21 , \amp, 0.04);

(Ndef(\LR).clear(10);
Ndef(\LR).stop(10);)

________________________________________________

//12 sec envelope + 7 sec fadeout
(
Ndef(\sweepDrone, { |freq=340, modFreq=5, panf = 2|
    var sig, env, pan;

    sig = SinOsc.ar(freq);
    sig = sig + (SinOsc.ar(freq * 1.5) * 0.3) + (SinOsc.ar(freq * 2) * 0.2);
    sig = RLPF.ar(sig, XLine.kr(200, 2000, 5), 0.2);
	env = EnvGen.kr(Env.new([0,0.2,0.7,0.3,0],[3,3,3,3]), doneAction: 2);
    pan = SinOsc.kr(panf);
    Pan2.ar(sig, pan, 0.01 * env);
}).play;

Ndef(\sweepDrone).fadeTime = 7;
)


(Ndef(\sweepDrone).xset(\freq, 450);
Ndef(\sweepDrone).xset(\panF, 86);)


(Ndef(\sweepDrone).clear(3);
Ndef(\sweepDrone).stop(3);)


___________________________________________________

//16 sec envelpe * duratino + 8 sec fadeout
(
Ndef(\pm, { |freq=420.6, moda=80, amount= 2, dur= 50, amp=0.2, ph = 0, gate = 1|
	var pan = SinOsc.kr(1/dur + rrand(0.04, 0.06) , ph);
	var ampEnv = EnvGen.kr(Env([0, 0.1, 0.9, 0.5, 0], [1, 6, 5, 4], [2, 1, 0, -2]), gate, timeScale: dur, doneAction: 2);
	var mod = Saw.ar(45.432) * 555;
	var osc = PMOsc.ar(freq, moda, amount);
    var snd = osc * ampEnv * amp;
	snd = Limiter.ar(snd, level: 0.59, dur: 0.01);
	Pan2.ar(snd, pan);
}).play;

Ndef(\pm).fadeTime = 8;
Ndef(\pm).set(\gate, 1);


Ndef(\pm2, { |freq=420.6, moda=80, amount= 2, dur= 50, amp=0.75, ph = 0, gate = 1|
	var pan = SinOsc.kr(1/dur + rrand(0.2, 0.8) , ph + 0.3);
	var ampEnv = EnvGen.kr(Env([0, 0.1, 0.9, 0.5, 0], [1, 6, 5, 4], [2, 1, 0, -2]), gate, timeScale: dur, doneAction: 2);
	var mod = Saw.ar(45.432) * 555;
	var osc = PMOsc.ar(freq, moda, amount);
    var snd = osc * ampEnv * amp;
	snd = Limiter.ar(snd, level: 0.59, dur: 0.01);
	Pan2.ar(snd, pan) * 0.2;
}).play;

Ndef(\pm2).fadeTime = 8;
Ndef(\pm2).set(\gate, 1);
)

Ndef(\pm).xset(\freq, 350);
Ndef(\pm).xset(\moda,  25);
Ndef(\pm).xset(\ph, 0.4);
Ndef(\pm).xset(\dur,  25);


Ndef(\pm2).xset(\freq, 480);
Ndef(\pm2).xset(\moda,  45);  // range 0.002 to 1212! higher more interference
Ndef(\pm2).xset(\ph, 0.5);
Ndef(\pm2).xset(\dur,  60);  //dont use cents //any range but 20-50 most interference
//______________________________________

(Ndef(\pm2).clear(5);
Ndef(\pm2).xset(\gate, 0);
Ndef(\pm).clear(5);
Ndef(\pm).xset(\gate, 0);)
_____________________________________________

// 57~49 second envelope + fadetime
(
Ndef(\playalong20, { | imp = 1.6|
    var freq = Demand.kr(Impulse.kr(imp), 0, Dseq([305,306,309,312,309,306,305], inf));
	var env = EnvGen.kr(Env.new([0,0.03,0.07,0.15,0.4,0.3,0.1,0], [7,6,12,8,5,3], 'lin'), doneAction: 2);
    var sig = SinOsc.ar(freq, imp / 10) * env;
    var pan = SinOsc.kr(0.2, phase: imp).range(-1, 1);
	var filter = Limiter.ar(sig, level: 0.99, dur: 0.01);
	sig = Limiter.ar(sig, level: 0.69, dur: 0.01);
    Pan2.ar(sig, pan) * 0.2;
}).play;
Ndef(\playalong20).fadeTime = 8;

Ndef(\playalong21, { |a = 204, ph = 4|
    var env = Env.new([0,0.07,0.15,0.45,0.5,0.3,0.1,0], [10,5,8,4,10,5], 'lin');
    var envGen = EnvGen.kr(env, doneAction: 2);
    var sig = Mix([
        SinOsc.ar(a, phase: ph + SinOsc.ar(3)) * 0.3,
        SinOsc.ar(a * 2, ph) * 0.15,
        SinOsc.ar(a * 1.5, ph) * 0.1,
        SinOsc.ar(a * 1.25, ph) * 0.05
    ]);

    [0, Limiter.ar(sig, level: 0.69, dur: 0.01) * envGen* 0.5];
}).play;

Ndef(\playalong21).fadeTime = 8;


Ndef(\playalong22, { | b = 210.5|
    var env = Env.new([0,0.07,0.15,0.45,0.5,0.3,0.1,0], [12,7,4,7,2,7], 'lin');
    var envGen = EnvGen.kr(env, doneAction: 2);
    var sig = Mix([
        SinOsc.ar(b) * 0.3,
        SinOsc.ar(b * 2) * 0.15,
        SinOsc.ar(b * 1.5) * 0.1,
        SinOsc.ar(b * 1.25) * 0.05
    ]);

    [Limiter.ar(sig, level: 0.69, dur: 0.01) * envGen * 0.5, 0];
}).play;

Ndef(\playalong22).fadeTime = 8;
)


Ndef(\playalong20).xset(\imp, 0.02);
Ndef(\playalong22).xset(\a, 410, \ph, 85); //ph moding for a=b
Ndef(\playalong22).xset(\b, 480);

(Ndef(\playalong20).clear(4);
Ndef(\playalong21).clear(4);
Ndef(\playalong22).clear(4);)

___________________________________________

// ongest envelope 8 sec * 16 dur + 4 sec fadeOut
(
Ndef(\slide, { |freq = 200|
    var ampEnv = EnvGen.kr(Env([0, 0.7, 0.4, 0], [1.5, 5, 1.5], [1.5, -1.5, 1.5]), timeScale: 4, doneAction:2);
    var panEnv = EnvGen.kr(Env([0, 0.7, 1], [4, 4], \sine));
    var freqSlide = EnvGen.kr(Env([freq + 20.8 , freq + 110.56 , freq + 145.5], [3.5, 3.5]), timeScale: 16);
    var osc = SinOsc.ar(freqSlide+0.55);
    var snd = Pan2.ar(osc * ampEnv * 0.1, panEnv);
    snd = snd * EnvGen.kr(Env([1, 0.5], [8], \sine));
    snd * 1.3;
}).play;

)

Ndef(\slide).xset(\freq, 880);

(Ndef(\slide).stop(5);
Ndef(\slide).clear(5);
Ndef(\slide).release(5);)

____________________________________________________

// around 3~4 min envelope + 8 sec fadeTime

(
Ndef(\vmel, { |x = 1335.12, y = 1336.12, z = 1339.12, w = 1323.12, p = 1450.12, q = 1930.12, violin = 0|
	var droneFreqs, violinFreqs, drone, env, sound, reverb;
	droneFreqs = [x.lag(2), y.lag(2)];
	violinFreqs = [z.lag(2), w.lag(2), p.lag(2), q.lag(2)];
	drone = SinOsc.ar(droneFreqs, 0, 0.4)*SinOsc.kr(3.5);
	violin = Mix.new(violinFreqs.collect { |freq| SinOsc.ar([freq, freq * 1.025], 0, 0.05) });
	env = EnvGen.kr(Env.linen(10, 360, 10, 1)) * 0.8;
	sound = (drone + violin) * env;
	reverb = FreeVerb.ar(sound, mix: 0.3, room: 0.9, damp: 0.6) * env * 0.1;
	reverb = reverb + RLPF.ar(reverb, 1300 * SinOsc.ar(1/13).range(1/4,4), \rq.kr(0.5) * LFNoise1.ar(1/13).range(1/4,2)).mean;
}).play;

Ndef(\vmel).fadeTime = 8;
)
                                       ///// onli close frequencies
Ndef(\vmel).set(\x, 1216, \y, 1760, \z, 1200.12, \w, 1215.12, \p, 1280.12, \q, 1244.12);

(Ndef(\vmel).stop(5);
Ndef(\vmel).clear(5);)


___________________________________________________

//8 sec env * timescale 4 + fadetime 10
(
Ndef(\harmonicDrone, { |amp = 0.3, freq = 100, a = 0.5, b = 0.6|
var harmonics = [SinOsc.ar(freq + b), SinOsc.ar(freq + a), SinOsc.ar(516), SinOsc.ar(250.4)];
var lfo = LFNoise1.kr(0.7).range(0.8, 1.5);
var env = EnvGen.kr(Env([0, 0.7, 0.4, 0], [1.5, 5, 1.5], [1.5, -1.5, 1.5]), timeScale: 4);
var sound =  Mix(SinOsc.ar(freq * harmonics, 0, amp * lfo / harmonics.size));
sound = FreeVerb.ar(sound, 0.9, 0.9, 0.5);
sound = Mix( harmonics.collect { |harmonic| SinOsc.ar(freq * harmonic , 0, amp * lfo / harmonics.size) } );
sound = env * sound ! 2;
}).play;

Ndef(\harmonicDrone).fadeTime = 10;
)

Ndef(\harmonicDrone).xset(\freq, 2185, \a, 0.95, \b, 0.01);

(Ndef(\harmonicDrone).release(5);
Ndef(\harmonicDrone).stop(5);
Ndef(\harmonicDrone).clear(5);
)


_____________________________________________________________

// 40 sec envelope + 8 fadeTime
(
Ndef(\noiseDrone, { |freq=200, panF = 123, gate=1|
    var sig, env, pan;
    sig = SinOsc.ar(freq * (1 + (SinOsc.kr(freq*1.123) * 1))) * LFSaw.ar(freq*4/3 * SinOsc.kr(1/12).range(1.1,1));
    sig = RLPF.ar(sig, 3000 * LFNoise1.ar(1/13!4).range(1/4,4), \rq.kr(0.5) * LFNoise1.ar(1/13!4).range(1/4,2)).mean;
	env = EnvGen.kr(Env.new([0,0.7,0.20,0.8,0.3,0.1,0], [2,4,16,8,10]), gate, doneAction: 2);
	pan = LFSaw.ar(panF, panF/100);
	Pan2.ar(sig, pan, 0.005 * env) * 0.5;
}).play;

Ndef(\noiseDrone).fadeTime(8);
)


Ndef(\noiseDrone).xset(\freq, 2230.3, \panF, 134);


(Ndef(\noiseDrone).clear(3);
Ndef(\noiseDrone).stop(3);)



____________________________________________________

//12 sec envelope + fadetime 4
(
Ndef(\jing, { |freq = 392, gate = 1|
	var snd, env, pan = 0.06;
	var smoothFreq = Lag.kr(freq, 3);
	var smoothPan = Lag.kr(pan, 3);
	env = EnvGen.kr(Env.new([0,0.2,0.7,0.2, 0],[3,3,3,3]), doneAction: 2) * 0.3;
	snd = SinOsc.ar(smoothFreq * (LFNoise2.kr(3!2) * 0.3).midiratio * [1, 2, 1, 2, 2, 1, 2, 1], 0);
	snd = BPF.ar(snd, {ExpRand(200, 800)}.dup(snd.size), 0.2) * 0.dbamp;
	snd = Splay.ar(snd, 1, 1, smoothPan);
	snd = snd * env * 0.5;
}).play;

Ndef(\jing).fadeTime = 4;
)


Ndef(\jing).xset(\freq, 863);

(Ndef(\jing).clear(2);
Ndef(\jing).stop(2);)

_______________________________________________________

//40 envelope + fadetime

(
Ndef(\metalAmbient, { |gate = 1|
var drone = { |dur = 5|
var freqs = [60, 62];
var trigger = Impulse.ar(0.5);
TGrains.ar(2, trigger, Buffer.alloc(s, 44100 * dur, 1).sine1, freqs.choose, 0, dur, 0, 0.3, 2);
};
var env = EnvGen.kr(Env.new([0,0.7,0.20,0.8,0.3,0.1,0], [2,4,16,8,10], 'lin'), gate, doneAction: 2);
var metal = { |ringtimes|
var freqs = [590, 700, 1250];
var exciter = PinkNoise.ar(0.01);
DynKlank.ar(`[freqs, nil, ringtimes ? [1, 0.5, 0.25]], exciter);
};
var sound = drone.value() + metal.value();
var reverb = FreeVerb.ar(sound, mix: 0.4, room: 0.9, damp: 0.5);
reverb * env * 0.05;
}).play;

Ndef(\metalAmbient).fadeTime = 8;
Ndef(\metalAmbient).set(\gate, 1);
)


(Ndef(\metalAmbient).xset(\gate, 0);
Ndef(\metalAmbient).stop(5);
Ndef(\metalAmbient).clear;)

_______________________________________________________________


Ndef.clear.all;
NdefMixer(s);



Ndef(\fb0).clear;Ndef(\fb0).stop;
Ndef(\sweepDrone).clear; Ndef(\sweepDrone).stop;
Ndef(\playalong0).clear; Ndef(\playalong1).clear; Ndef(\playalong0).stop;Ndef(\playalong1).stop;
Ndef(\LR).clear;Ndef(\LR).stop;
Ndef(\pm).clear; Ndef(\pm2).clear;Ndef(\pm).stop; Ndef(\pm2).stop;
Ndef(\playalong20).clear;Ndef(\playalong20).stop;  Ndef(\playalong21).clear;Ndef(\playalong21).stop;  Ndef(\playalong22).clear;Ndef(\playalong22).stop;
Ndef(\slide).clear;Ndef(\slidee).stop;
Ndef(\vmel).clear; Ndef(\vmel).stop;
Ndef(\harmonicDrone).clear;Ndef(\harmonicDrone).stop;
Ndef(\metalAmbient).clear;Ndef(\metalAmbient).stop;
Ndef(\noiseDrone).clear;Ndef(\noiseDrone).stop;
Ndef(\jing).clear;Ndef(\jing).stop;
Ndef(\ambi2).clear;Ndef(\ambi2).stop;
