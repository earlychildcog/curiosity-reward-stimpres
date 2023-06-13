function [roiFixated, timeFixated] = fixCheck(xp, whichrect, keyboardDummy, verbose)
% function that checks if there is fixation in any of the rectangles
% we have defined, indicated in $whichrect. If yes, returns which rectangle
% in the above order. If keyboardDummy is true, A and D can be used for 
% 1 and 2 ROI fixation return.
% NOTES:
% We need to check timings. Also, currently all ROIs are supposed to have
% the same y-coordinates (heights wrt screen). If different y-coordinates of boxes
% required, we need to adjust.
% Also, we need to time the "EyeAvailable" thing, in case it take too much
% time we should remove and adjust.


if nargin < 4
    verbose = false;
    if nargin < 3
        keyboardDummy = false;
    end
end

roiFixated = 0;
timeFixated = NaN;

% which eye to use

if xp.eyelink.status == 1 
    while Eyelink( 'NewFloatSampleAvailable') == 0
        disp('waiting for sample...')
    end

    eye_used = Eyelink('EyeAvailable');
    if eye_used == 2
        eye_used = 1;
    end
    % get the sample in the form of an event structure
    evt = Eyelink('NewestFloatSample');
    if eye_used ~= -1 % do we know which eye to use yet?
        % if we do, get current gaze position from sample
        x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
        y = evt.gy(eye_used+1);
        disp([x,y]);
        timeFixated = GetSecs;
        if verbose
            fprintf('%f %f %.4f\n',x, y, GetSecs)
        end
        % do we have valid data and is the pupil visible?
%             fprintf('%.3f: %.0f %.0f',GetSecs - StimulusOnsetTime,x,y);
        if x~=xp.eyelink.settings.MISSING_DATA && y~=xp.eyelink.settings.MISSING_DATA && evt.pa(eye_used+1)>0
            % check if we hit any ROI
            for i = 1:length(whichrect)
                if (y > xp.screen.rect(2,whichrect(i))) && (y < xp.screen.rect(4,whichrect(i)))
                    if (x < xp.screen.rect(3,whichrect(i))) && (x > xp.screen.rect(1,whichrect(i)))
                        roiFixated = i;
                        return
                    end
                end
            end
        end
%             fprintf('\n')
    end
end

if keyboardDummy
    [keyIsDown, timeFixated_ ,keyCode] = PsychHID('KbCheck', xp.keyboard.index);      %reads key pressed
    if isnan(timeFixated)
        timeFixated = timeFixated_;
    end
    if keyIsDown
        switch find(keyCode,1)
            case KbName('leftarrow')
                roiFixated = 1;
            case KbName('rightarrow')
                if length(whichrect) > 1
                    roiFixated = 2;
                end
            case KbName('uparrow')
                if length(whichrect) > 2
                    roiFixated = 3;
                end
                
        end
    end
    if verbose
        fprintf('%d %.4f\n', roiFixated, GetSecs)
    end
end

