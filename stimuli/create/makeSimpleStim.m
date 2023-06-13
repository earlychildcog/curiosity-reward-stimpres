




jpgBackground = "background.jpg"
matBackground = strrep(jpgBackground, ".jpg", ".mat")
pngBackground = strrep(jpgBackground, ".jpg", ".png")

I = imread(jpgBackground);

save("background.mat","I")






