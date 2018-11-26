source=$(shell ls source/*.MOV)
object=$(patsubst source/%,output/%,$(source:.MOV=.MP4))
trf=$(patsubst source/%,output/%,$(source:.MOV=.trf))

num_threads=10

all: $(trf) $(object)

output/%.trf:source/%.MOV 
	ffmpeg -threads $(num_threads) -i $< -vf vidstabdetect=stepsize=6:shakiness=8:accuracy=9:result=$@ -f null -

output/%.MP4:source/%.MOV output/%.trf
	ffmpeg -threads $(num_threads) -i $< -vf vidstabtransform=input=$(basename $@).trf:zoom=1:smoothing=30,unsharp=5:5:0.8:3:3:0.4 -vcodec libx264 -preset slow -tune film -crf 18 -acodec aac $@

clean: 
	rm -f $(trf) $(object)

