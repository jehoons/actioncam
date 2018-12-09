ffmpeg_exec=ffmpeg2
ext=MP4
source=$(shell ls source/*.$(ext))
object=$(patsubst source/%,output/%,$(source:.$(ext)=.MP4))
trf=$(patsubst source/%,output/%,$(source:.$(ext)=.trf))
comparison=$(patsubst source/%,comparison/%,$(source:.$(ext)=.MP4))

num_threads=10

output_files=$(trf) $(object) $(comparison) 

all: $(output_files)

output/%.trf:source/%.$(ext)
	$(ffmpeg_exec) -threads $(num_threads) -i $< -vf vidstabdetect=stepsize=6:shakiness=10:accuracy=15:result=$@ -f null -

output/%.MP4:source/%.$(ext) output/%.trf
	$(ffmpeg_exec) -threads $(num_threads) -i $< -vf vidstabtransform=input=$(basename $@).trf:optzoom=2:zoom=0:smoothing=10,unsharp=5:5:0.8:3:3:0.4 -vcodec libx264 -preset slow -tune film -crf 18 -acodec aac $@

comparison/%.MP4:source/%.$(ext) output/%.MP4
	$(ffmpeg_exec) -threads $(num_threads) -i $(word 1,$^) -i $(word 2,$^) -filter_complex "[0:v:0]pad=iw*2:ih[bg]; [bg][1:v:0]overlay=w" $@

clean: 
	rm -f $(output_files) 

