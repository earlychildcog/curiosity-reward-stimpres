function fRenameFiles(folder)
arguments
    folder string {mustBeFolder} = "."
end
fRenameStr = @(c)regexprep(c,'-(\d+)-','${sprintf("-%.4d-",str2double($1))}');
arrayfun(@(x)movefile(fullfile(x.folder, x.name), fullfile(x.folder, fRenameStr(x.name))), dir(fullfile(folder, "*.bmp"))










