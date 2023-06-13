function [flagResult, time] = attgetPart(xp)
flagResult = -10;
xp.eyelink.startrec;
while flagResult < 0
    [flagResult, time] = xp.playPretrial;
    if flagResult == -1     % recalibrate
        xp.trial.varValue.result = flagResult;
        xp.eyelink.stoprec;
        xp.eyelink.calibrate;
        xp.eyelink.startrec;
    elseif flagResult == -2 % play video
        xp.trial.varValue.result = flagResult;
        xp.eyelink.stoprec;
        xp.sound.which = xp.sound.data{3,1};
        xp.videoPlay(fullfile(pwd, 'stimuli/videos/03-break/waybuloo.mov'), 1, 1);
        xp.eyelink.startrec;
    elseif flagResult == 3 % skip trial; get a small break first, though
        xp.trial.varValue.result = flagResult;
        xp.eyelink.stoprec;
        xp.erase
        WaitSecs(0.1);
    end
end
end