
folder = "~/Downloads/GIF2";
files = arrayfun(@(x)string(x.name), dir(fullfile(folder, "*.gif")));
folderForFrames = fullfile(folder, "frames");
mkdir(folderForFrames);


for k = 1:length(files)
    fileIn = files(k);
    name = extractBefore(fileIn, ".gif");
    folderOut = fullfile(folderForFrames, name);
    mkdir(folderOut)
    
    command = sprintf("ffmpeg -i %s -fps_mode passthrough %s/%s-%%2d.png", fullfile(folder, fileIn), folderOut, name);
    system(command)
end











