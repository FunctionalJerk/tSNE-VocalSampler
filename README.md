# tSNE-VocalSampler

A software sampler programmed in [SuperCollider](https://github.com/supercollider/supercollider) playing a tSNE-Scatterplot.  
Visit the project on [my website](https://functionaljerk.github.io/projects/VocalSampler/) to get general information and a video-demo of my sampler. 

This projects builds upon a series of projects, where I created a sample library of vocal interjections and extracted their F0-data. 
This data would later serve different projects in art and artistic research, this being one of them.  

My application was strongly inspired by -and dependent on ml4a's [AudioTSNEViewer](https://ml4a.github.io/guides/AudioTSNEViewer/). 

A more elaborate documentation will follow shortly!  
Meanwhile (and if you can read German), please refer to `doc/Vocal-Sampler_Projektdokumentation.PDF` and/or study the code to understand what's going on here 
(and why there's little use in a detailed *how-to*).

I also considered providing my very own sample library in order to provide easy reproducibility,
but I really can't do that yet, as it's just so very private.  

## Very shortly: 
You basically cannot directly recreate this project without creating your own sample library and putting it into `data/Wave/*`.
Audio-files found in this directory have to follow my very secret file-naming conventions. 

Once that's done, use ml4a's [python-script](https://github.com/ml4a/ml4a-ofx/blob/master/scripts/tSNE-audio.py) to create your own version of `data/audiotsne.json`.
After that you can run `tsne2dict.scd` on that file to complete it by the nesseccary data (Emotion & Expression), 
thus creating your own version of `data/vocalmap.json`.

With a method of your choice, analyze these audio-files for F0-data and put that into `data/CSV/*`, mirroring the folder structure and naming conventions of `data/Wave/*`.

Now you should be able to run `vocal_sampler.scd`.

## ToDo

- [ ] upload an example folder for `data/CSV/*` and `data/Wave/*`
- [ ] change paths of these files to relative - not absolute.
- [ ] upload the documentation for preceding projects
