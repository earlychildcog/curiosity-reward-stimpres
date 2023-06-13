

folderOld = "frames";   % all images should be in subfolders inside this folder
folderNew = folderOld + "-new";     % here is where new subfolders will be automatically put
newdims = [200 200];    % set new dimensions of stimuli

% checks
assert(exist(folderOld,"file") == 7, "set folderOld to valid folder?")

subfolders = arrayfun(@(x)string(x.name),dir(folderOld));
subfolders(contains(subfolders,'.')) = [];

assert(~isempty(subfolders), "folderOld empty?")

mkdir(folderNew)
for s = 1:length(subfolders)
    thisSubfolder = subfolders(s);
    mkdir(fullfile(folderNew,thisSubfolder))
    theseImages = arrayfun(@(x)string(x.name), dir(fullfile(folderOld, thisSubfolder, "*.png")));
    for i = 1:length(theseImages)
        thisImage = theseImages(i);
        [a, b, c] = imread(fullfile(folderOld, thisSubfolder, thisImage));
        [a_] = imresize(a, newdims);
        c_ = imresize(c, newdims);
        imwrite(a_,fullfile(folderNew, thisSubfolder, thisImage), 'png','Alpha',c_)
    end
end










