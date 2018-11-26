ffmpeg_exec=ffmpeg

source=$(shell ls source/*.MOV)
object=$(patsubst source/%,output/%,$(source:.MOV=.MP4))
trf=$(patsubst source/%,output/%,$(source:.MOV=.trf))
comparison=$(patsubst source/%,comparison/%,$(source:.MOV=.MP4))

num_threads=10

all: $(trf) $(object) $(comparison)

output/%.trf:source/%.MOV 
	$(ffmpeg_exec) -threads $(num_threads) -i $< -vf vidstabdetect=stepsize=6:shakiness=8:accuracy=9:result=$@ -f null -

output/%.MP4:source/%.MOV output/%.trf
	$(ffmpeg_exec) -threads $(num_threads) -i $< -vf vidstabtransform=input=$(basename $@).trf:zoom=1:smoothing=30,unsharp=5:5:0.8:3:3:0.4 -vcodec libx264 -preset slow -tune film -crf 18 -acodec aac $@

comparison/%.MP4:source/%.MOV output/%.MP4
	$(ffmpeg_exec) -i $(word 1,$^) -i $(word 2,$^) \
			-filter_complex "[0:v:0]pad=iw*2:ih[bg]; [bg][1:v:0]overlay=w" $@

clean: 
	rm -f $(trf) $(object)

