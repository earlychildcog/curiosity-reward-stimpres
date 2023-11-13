function flagResult = playTrial(xp, idStimInPosition, trialtype)
% idStimInPosition: 2xn array
%% types of trials
framedurRew        = 0.2;   % for reward animation
framedurCol        = 0.05;   % for colouring/revealing
framedur = framedurRew; % QUICK FIX -- NEED TO MAKE IT WORK FOR DIFFERENT DURATIONS
nStimTotal         = xp.settings.nStimTotal;                       % total number of stims
countFirstROI      = 0;

boxTex         = 2;
box_highlight_rect_pad = round([-37 -37 37 37]*0.59)';
box_highlight_rect_pad = 0;
idStimSound    = idStimInPosition;
flagColouringPersist = 0;
% print to command line
fprintf("Trial %d, type %s\n", xp.trial.varValue.trialID, trialtype)

switch trialtype
    % ------ 1. For the real task/the task pilot
    case 'Fam1'          % colouring + animating
        flagAnimation        = true;
        flagBox              = false;
        flagCurtain          = 0;
        flagEndIfLookAway    = false;
        flagExtra            = false;
        flagOnlyAnimateFirst = false;
        idStimInPosition     = idStimInPosition + 2*xp.settings.nStimTotal;
        idStim               = idStimInPosition(2,1:end-flagExtra);
        nStimOnScreen        = length(idStim);                     % how many on screen (experiment phase)
        maxtime              = 30;
        durStimPostTrig      = 15;

        soundfolder     = 6;
        idStimExtra     = idStimInPosition(2,end:end-1+flagExtra); % extra stim(s) in the beginning; put empty array for none
        idStim          = idStim(1:nStimOnScreen);
        idStimColouring = 3 + idStim;
        idStimReward    = idStimColouring + xp.settings.nStimFamTotal;
    case {'Fam2', 'FamRep'}          % visible
        flagAnimation        = true;
        flagBox              = true;
        flagCurtain          = 1;
        flagEndIfLookAway    = false;
        flagExtra            = true;
        flagOnlyAnimateFirst = true;
        idStimInPosition     = idStimInPosition + 2*xp.settings.nStimTotal;
        idStim               = idStimInPosition(2,1:end-flagExtra);
        nStimOnScreen        = length(idStim);                     % how many on screen (experiment phase)
        maxtime              = 30;
        durStimPostTrig      = xp.settings.durMaxTrial;

        soundfolder     = 6;
        idStimExtra     = idStimInPosition(2,end:end-1+flagExtra); % extra stim(s) in the beginning; put empty array for none
        idStim          = idStim(1:nStimOnScreen);
        idStimColouring = 3 + idStim;
        idStimReward    = idStimColouring + xp.settings.nStimFamTotal;
    case 'TestSame'                  % invisible
        flagAnimation        = true;
        flagBox              = true;
        flagCurtain          = 2;
        flagEndIfLookAway    = true;
        flagExtra            = true;
        flagOnlyAnimateFirst = true;
        idStim               = idStimInPosition(2,1:end-flagExtra);
        nStimOnScreen        = length(idStim);                     % how many on screen (experiment phase)
        maxtime              = 30;
        durStimPostTrig      = xp.settings.durMaxTrial;

        soundfolder     = 5;
        idStimExtra     = idStimInPosition(2,end:end-1+flagExtra); % extra stim(s) in the beginning; put empty array for none
        idStim          = idStim(1:nStimOnScreen);
        idStimColouring = 3 + idStim;
        idStimReward    = idStimColouring + nStimTotal;
    case 'TestDiff'                   % invisible
        flagAnimation        = true;
        flagBox              = true;
        flagCurtain          = 2;
        flagEndIfLookAway    = true;
        flagExtra            = true;
        flagOnlyAnimateFirst = true;
        idStim               = idStimInPosition(2,1:end-flagExtra);
        nStimOnScreen        = length(idStim);                     % how many on screen (experiment phase)
        maxtime              = 30;
        durStimPostTrig      = 10;

        soundfolder     = 5;
        idStimExtra     = idStimInPosition(2,end:end-1+flagExtra); % extra stim(s) in the beginning; put empty array for none
        idStim          = idStim(1:nStimOnScreen);
        idStimColouring = 3 + idStim;
        idStimReward    = idStimColouring + nStimTotal;
        % ------ 2. for the stim pilot
    case 'FamStim'           % colouring + animating
        flagAnimation        = true;
        flagBox              = false;
        flagCurtain          = 0;
        flagEndIfLookAway    = false;
        flagExtra            = false;
        flagOnlyAnimateFirst = false;
        idStimInPosition     = idStimInPosition + 2*xp.settings.nStimTotal;
        idStim               = idStimInPosition(2,1:end-flagExtra);
        nStimOnScreen        = length(idStim);                     % how many on screen (experiment phase)
        maxtime              = 30;
        durStimPostTrig      = 15;

        idStimExtra     = idStimInPosition(2,end:end-1+flagExtra); % extra stim(s) in the beginning; put empty array for none
        idStim          = idStim(1:nStimOnScreen);
        idStimColouring = 3 + idStim;
        idStimReward    = idStimColouring + xp.settings.nStimFamTotal;
    case 'TestStim'           % colouring + animating
        flagAnimation        = true;
        flagBox              = false;
        flagCurtain          = 0;
        flagEndIfLookAway    = false;
        flagExtra            = false;
        flagOnlyAnimateFirst = false;
        idStim               = idStimInPosition(2,1:end-flagExtra);
        nStimOnScreen        = length(idStim);                     % how many on screen (experiment phase)
        maxtime              = 30;
        durStimPostTrig      = 15;

        soundfolder     = 6;
        idStimExtra     = idStimInPosition(2,end:end-1+flagExtra); % extra stim(s) in the beginning; put empty array for none
        idStim          = idStim(1:nStimOnScreen);
        idStimColouring = 3 + idStim;
        idStimReward    = idStimColouring + nStimTotal;
    otherwise
        error('wrong trialtype')
end

%% other settings

%%% curtain settings %%%
durCurtain = 1;
timeStep   = 1/30;         % warning: make sure that durCurtain/timeStep is an integer! Best way to ensure that is to set timeStep as durCurtain/n for some n integer
kStep      = 2*timeStep/durCurtain;


iFrameCurtain = 0;
iFrameMovement = 0;

flagResult        = 1;
flagLoop          = true;
flagTrialStep      = 0;
flagEndTrial       = 0;
maxFrameColouring = 4;
maxFrameRewarding = 12;
goodbyeMessage    = 'end:-';
timeLastSound     = GetSecs;
timeOutOfScreenStart = GetSecs;
if xp.eegon
    NetStation('StartRecording');
end

while flagLoop


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start new trial settings
    if flagTrialStep == 0

        timeToTrigger = xp.settings.timeToTrigger;            % time for fixation to trigger
        timeOut       = xp.settings.timeOut;                  % time fixating away to reset fixation timer
        occrect       = xp.settings.occrect;                  %
        if ~flagBox
            occrect   = -2000*[1 1 1 1]';
        end

        % identify stimuli

        iEvent = 0;

        %%% NEEDS BETTER FIXING; we need to throw adjust the identical objects identities, now random movements if same
        % (Note: for now we don't have visible same trials anymore so not
        % changing this unless those trials are reabilitated)
        if sum(sum(idStimInPosition(1,:) == (idStimInPosition(1,:)'))) == size(idStimInPosition, 2)
            posStimInitial = ((idStimInPosition(1,:) == idStimInPosition(2,:)')*(1:nStimOnScreen+flagExtra)')';     % get the initial positions of the stimuli
        else
            posStimInitial = randperm(size(idStimInPosition,2));
        end
        % draw stimuli

        textureArray = xp.image.texture([idStimColouring, 3 + idStimExtra],1);

        % flags››
        flagObjectState    = zeros(1, nStimOnScreen);         % states: 0 - hidden, 1 - partially revealled, 2 - fully revealed, 3 - reward animating
        flagOccluderState  = zeros(1, nStimOnScreen);         % 0: full, 1: done, in between: partial
        stepOccluderReveal = 0.100001;
        roiReward          = 0;
        roiAnimating       = 0;                               % which object currently being animated (0 if none)
        iFrameColouring    = zeros(1, nStimOnScreen);         % which colouring frame we are on
        iFrameRewarding    = zeros(1, nStimOnScreen);         % which reward frame we are on

        timeLastIn = repmat(GetSecs, 1, nStimOnScreen+1);     % timestamp of last visit of ROI (starting with rest of screen roi)
        trigOnset  = NaN;

        %         eventFrameMatrix = zeros(600, 5);           % to store some stuff
        durFixIn   = 0;



        % draw background
        Screen('DrawTexture', xp.screen.win, xp.image.texture{1,1}, [], xp.screen.rect(:,1));
        Screen('DrawTexture', xp.screen.win, xp.image.texture{3,1}, [], xp.screen.rect(:,1) + xp.screen.rect(4,1)*[0 -0.9 0 -0.9]');

        % draw objects
        for iObject = 1:(nStimOnScreen + flagExtra)
            Screen('DrawTexture', xp.screen.win, textureArray{iObject}, [], xp.screen.rect(:,4 + posStimInitial(iObject)), 0, []);
        end

        % draw occluders
        for iObject = 1:nStimOnScreen
            Screen('DrawTexture', xp.screen.win, xp.image.texture{3,boxTex}, [], occrect + xp.screen.rect(:,1 + iObject));
        end

        stimOnset0 = xp.flip;
        stimOnset  = stimOnset0;
        xp.sound.which = xp.sound.data{2,1};
        xp.sound.play;
        xp.eyelink.write('trial start @%.3fsec',stimOnset)
        flagTrialStep = 1;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% first present objects
    elseif flagTrialStep == 1
        if GetSecs - stimOnset > 3
            if flagCurtain > 0
                flagTrialStep = 2;
            else
                flagTrialStep = 3;
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% curtain down and up
    elseif flagTrialStep == 2
        % send event in the beginning
        if iFrameCurtain == 0
            K = -1:kStep:1;
            stimOnset  = GetSecs;
            xp.eyelink.write('curtain start moving @%.3fsec',stimOnset)
        end

        % set current phase of curtain movement
        iFrameCurtain = iFrameCurtain + 1;
        k = K(iFrameCurtain);

        posCurtain = round(xp.screen.rect(:,1) + xp.screen.rect(4,1)*0.9*[0 0-abs(k) 0 -abs(k)]' - xp.screen.rect(4,1)*0.1333*[0 1-abs(k) 0 1-abs(k)]');
        % draw background
        Screen('DrawTexture', xp.screen.win, xp.image.texture{1,1}, [], xp.screen.rect(:,1));
        %                 Screen('DrawTexture', xp.screen.win, xp.image.texture{3,1}, [], xp.screen.rect(:,1) + xp.screen.rect(4,1)*[0 -0.9 0 -0.9]');

        % draw objects
        flagHiddenMovement = k>0 && flagCurtain == 2;
        for iObject = 1:(nStimOnScreen + flagExtra*(~flagHiddenMovement))
            if ~flagHiddenMovement
                Screen('DrawTexture', xp.screen.win, textureArray{iObject}, [], xp.screen.rect(:,1 + 3*(~flagHiddenMovement) + posStimInitial(iObject)), 0, []);
            else
                Screen('DrawTexture', xp.screen.win, textureArray{iObject}, [], xp.screen.rect(:,1 + 3*(~flagHiddenMovement) + iObject), 0, []);
            end
        end
        % draw occluders
        for iObject = 1:nStimOnScreen
            Screen('DrawTexture', xp.screen.win, xp.image.texture{3,boxTex}, [], box_highlight_rect_pad*(boxTex == 3) + occrect + xp.screen.rect(:,1 + iObject));
        end
        % draw curtain
        Screen('DrawTexture', xp.screen.win, xp.image.texture{3,1}, [], posCurtain);

        stimOnset = xp.flip(stimOnset + timeStep);
        xp.eyelink.write('curtain moving @%.3fsec',stimOnset)

        % checks phase of curtain move for waiting in the middle, or end of movement
        if k == 0 && flagCurtain == 2
            xp.sound.play;
            WaitSecs(0.5)         % wait one more second if movement is happening behind scenes
            boxTex = 3;% draw background
            Screen('DrawTexture', xp.screen.win, xp.image.texture{1,1}, [], xp.screen.rect(:,1));
            %                 Screen('DrawTexture', xp.screen.win, xp.image.texture{3,1}, [], xp.screen.rect(:,1) + xp.screen.rect(4,1)*[0 -0.9 0 -0.9]');

            % draw objects
            flagHiddenMovement = k>0 && flagCurtain == 2;
            for iObject = 1:(nStimOnScreen + flagExtra*(~flagHiddenMovement))
                if ~flagHiddenMovement
                    Screen('DrawTexture', xp.screen.win, textureArray{iObject}, [], xp.screen.rect(:,1 + 3*(~flagHiddenMovement) + posStimInitial(iObject)), 0, []);
                else
                    Screen('DrawTexture', xp.screen.win, textureArray{iObject}, [], xp.screen.rect(:,1 + 3*(~flagHiddenMovement) + iObject), 0, []);
                end
            end
            % draw occluders
            for iObject = 1:nStimOnScreen
                Screen('DrawTexture', xp.screen.win, xp.image.texture{3,boxTex}, [], box_highlight_rect_pad*(boxTex == 3) + occrect + xp.screen.rect(:,1 + iObject));
            end
            % draw curtain
            Screen('DrawTexture', xp.screen.win, xp.image.texture{3,1}, [], posCurtain);

            stimOnset = xp.flip(stimOnset + timeStep);
            WaitSecs(0.5)         % wait one more second if movement is happening behind scenes
        elseif k == 1
            xp.eyelink.write('curtain stop moving @%.3fsec',stimOnset)
            if flagCurtain <= 1         % show visible movement in case of visible trial
                flagTrialStep = 3;
            else
                flagTrialStep = 4;      % go to last phase in case of non-visible trial
                timeGazeStart = GetSecs;
                %                 timeOutOfScreenStart = timeFirstIn;
                xp.eyelink.write('start gaze phase @%.3fsec',timeGazeStart)
            end
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% movement phase
    elseif flagTrialStep == 3

        % starting movement phase
        if iFrameMovement == 0
            K = 0:kStep:1;
            stimOnset  = GetSecs;
            xp.eyelink.write('objects start moving @%.3fsec',stimOnset)

            if flagExtra
                rectOut = xp.screen.rect(:,5) - [xp.screen.rect(3,4) 0 xp.screen.rect(3,4) 0]';     % we create a rectangle out of the screen for the extra object
            else
                rectOut = [];
            end
            xp.sound.which = xp.sound.data{2,2};
            xp.sound.play;
        end
        iFrameMovement = iFrameMovement + 1;
        k = K(iFrameMovement);



        rectTraject = round(xp.screen.rect(:,posStimInitial + 4)*(1-k) + k*[xp.screen.rect(:,1 + (1:nStimOnScreen)) rectOut]);

        Screen('DrawTexture', xp.screen.win, xp.image.texture{1,1}, [], xp.screen.rect(:,1));
        Screen('DrawTexture', xp.screen.win, xp.image.texture{3,1}, [], xp.screen.rect(:,1) + xp.screen.rect(4,1)*[0 -0.9 0 -0.9]');

        % draw objects
        for iObject = 1:(nStimOnScreen + flagExtra)
            Screen('DrawTexture', xp.screen.win, textureArray{iObject}, [], rectTraject(:,iObject), 0, []);
        end
        % draw occluders
        for iObject = 1:nStimOnScreen
            Screen('DrawTexture', xp.screen.win, xp.image.texture{3,boxTex}, [], (boxTex == 3)*box_highlight_rect_pad + occrect + xp.screen.rect(:,1 + iObject));
        end
        % draw curtain

        stimOnset = xp.flip(stimOnset + timeStep);
        xp.eyelink.write('objects moving @%.3fsec',stimOnset)

        if k == 1
            xp.eyelink.write('objects stop moving @%.3fsec',stimOnset)
            boxTex = 3;
            rectTraject = round(xp.screen.rect(:,posStimInitial + 4)*(1-k) + k*[xp.screen.rect(:,1 + (1:nStimOnScreen)) rectOut]);

            Screen('DrawTexture', xp.screen.win, xp.image.texture{1,1}, [], xp.screen.rect(:,1));
            Screen('DrawTexture', xp.screen.win, xp.image.texture{3,1}, [], xp.screen.rect(:,1) + xp.screen.rect(4,1)*[0 -0.9 0 -0.9]');

            % draw objects
            for iObject = 1:(nStimOnScreen + flagExtra)
                Screen('DrawTexture', xp.screen.win, textureArray{iObject}, [], rectTraject(:,iObject), 0, []);
            end
            % draw occluders
            for iObject = 1:nStimOnScreen
                Screen('DrawTexture', xp.screen.win, xp.image.texture{3,boxTex}, [], (boxTex == 3)*(boxTex == 3)*box_highlight_rect_pad + occrect + xp.screen.rect(:,1 + iObject));
            end
            % draw curtain


            stimOnset = xp.flip(stimOnset + timeStep);
            flagTrialStep = 4;
            timeGazeStart = GetSecs;
            %             timeOutOfScreenStart = timeFirstIn;
            xp.eyelink.write('start gaze phase @%.3fsec',timeGazeStart)
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interactive phase
    elseif flagTrialStep == 4

        %         %%% checking fixations in boxes
        %         [roiFix, timeFix] = xp.fixCheck([1+(1:nStimOnScreen) 1], true);
        %         if roiFix == 0
        %             if timeOutOfScreenStart == Inf
        %                 timeOutOfScreenStart = timeFix;
        %             end
        %         else
        %             timeOutOfScreenStart = Inf;
        %             if roiFix==nStimOnScreen+1
        %                 roiFix = 0;
        %             end
        %         end

        % OLD STYLE:
        %         % get how long fixation has been going
        %         % if fixation is lost, then timer resets to new roi after $timeOut seconds
        %         if roiFix == roiFixLast
        %             durFixIn               = timeLastIn(roiFix + 1) - timeFirstIn;  % update duration if continuing fixating !!! Need to make sure no rounding errors mess things too much, too many additions? !!!!
        %             timeLastIn(roiFix + 1) = timeFix;
        %         else
        %             durFixOut              = timeFix - timeLastIn(roiFixLast + 1);  % seconds not looking on last roi
        %             timeLastIn(roiFix + 1) = timeFix;
        %             timeFirstIn            = timeFix;
        %             if durFixOut > timeOut
        %                 xp.eyelink.write('roichange: from %d to %d at states %s after %.3fsec @%.3fsec', roiFixLast, roiFix, num2str(flagObjectState), timeLastIn(roiFixLast + 1), timeFix)
        %                 if roiReward > 0 && roiFixLast == roiReward && flagObjectState(roiReward) ~= 2
        %                     countFirstROI  = countFirstROI + durFixIn;
        %                 end
        %                 durFixIn           = min(timeFix - timeLastIn(timeLastIn ~= timeFix));
        %                 roiFixLast         = roiFix;
        %             end
        %         end

        %%% loop control part
        if ((durFixIn > timeToTrigger) && (roiFix > 0) && flagFixIn) || flagColouringPersist > 0       % if fixation has been for long enoung, and we have fixation right now on some object, and that object is stably fixated
            % switch flagObjectState(roiFix)

                % if object partially revealed, continue revealing
            if flagColouringPersist > 0
                if iFrameColouring(flagColouringPersist) < maxFrameColouring
                    roiAnimating = flagColouringPersist;
                else % if fully coloured...
                    % if first to get fully coloured (or if not restricting rewards to first fixated): start reward animation.
                    if (roiReward ==  flagColouringPersist || ~flagOnlyAnimateFirst) && flagAnimation
                        flagObjectState(flagColouringPersist) = 3;
                        roiAnimating            = flagColouringPersist;
                        flagColouringPersist = 0;
                        xp.eyelink.write('trigger reward for %d @%.3fsec',roiAnimating, timeFix)
                        xp.sound.stop;
                        xp.sound.which = xp.sound.data{soundfolder,idStimSound(2,roiAnimating)}; %stimulus related sound
                        xp.sound.play(0,1,0);
                        % if another already in reward: just freeze it fully revealed
                    else
                        flagObjectState(flagColouringPersist) = 2;
                        flagColouringPersist = 0;
                        if roiAnimating > 0
                            xp.eyelink.write('stop animation for %d state %d: finished colouring @%.3fsec',roiAnimating, flagObjectState(roiAnimating), timeFix)
                            roiAnimating = 0;
                        end
                    end
                end
            % if object still hidden, and fixated there long enough: start revealing
            elseif flagObjectState(roiFix) == 0
                if all(flagObjectState == 0)
                    roiReward = roiFix;
                    trigOnset = timeFix;
                    xp.eyelink.write('first trigger colour for %d @%.3fsec',roiFix, timeFix)
                    % if flagBox      % first box opening makes sound
                    %     xp.sound.which = xp.sound.data{2,3};
                    %     xp.sound.play(timeFix+0.5,0);
                    % end
                else    % reward animation is disabled
                    if flagOnlyAnimateFirst
                        flagAnimation = false;
                        if roiReward>0 && flagObjectState(roiReward) == 3
                            flagObjectState(roiReward) = 2;
                        end
                    end
                end
                flagObjectState(roiFix) = 1;
                roiAnimating            = roiFix;
                flagColouringPersist = roiFix;
                xp.eyelink.write('trigger colour for %d @%.3fsec',roiFix, timeFix)


                % if object fully revealed, but not gonna animate reward
            elseif flagObjectState(roiFix) == 2
                if roiAnimating > 0 && flagOnlyAnimateFirst
                    xp.eyelink.write('stop animation for %d state %d: finished colouring @%.3fsec',roiAnimating, flagObjectState(roiAnimating), timeFix)
                    roiAnimating = 0;
                end

                % if object in reward animation phase
            elseif flagObjectState(roiFix) == 3
                if roiAnimating ~= roiFix
                    roiAnimating = roiFix;
                    xp.eyelink.write('start animation for %d state %d: @%.3fsec',roiAnimating, flagObjectState(roiAnimating), timeFix)
                    xp.sound.stop;
                    xp.sound.which = xp.sound.data{soundfolder,idStimSound(2, roiAnimating)}; %stimulus related sound
                    xp.sound.play(0,1,0);
                end
            end
        elseif roiAnimating > 0     % for the case that there are fixations to other ROIs that cummilatively add more than timeToTrigger
            xp.eyelink.write('stop animation for %d state %d: @%.3fsec',roiAnimating, flagObjectState(roiAnimating), timeFix)
            xp.sound.stop;
            roiAnimating = 0;
        end

        %%% draw the new frame to present

        % First decing how fast the frames should play depending on state
        % (colouring -0,1- vs. animating -3- ; NB: 2 = either go to 3 or do nothing)
        if  roiAnimating > 0
            if flagObjectState(roiAnimating) == 1
                framedur = framedurCol;
            elseif flagObjectState(roiAnimating) == 3
                framedur = framedurRew;
            end
        end

        if (roiAnimating > 0) && (GetSecs - stimOnset > framedur-0.01)


            switch flagObjectState(roiAnimating)

                % if colouring animation
                case 1
                    iFrameColouring(roiAnimating)     = iFrameColouring(roiAnimating) + 1;
                    flagOccluderState(roiAnimating)   = flagOccluderState(roiAnimating) + stepOccluderReveal;
                    textureArray{roiAnimating}        = xp.image.texture{idStimColouring(roiAnimating),iFrameColouring(roiAnimating)};
                    % if rewarding animation
                case 3
                    iFrameRewarding(roiAnimating)     = iFrameRewarding(roiAnimating) + 1;
                    if iFrameRewarding(roiAnimating) > maxFrameRewarding
                        iFrameRewarding(roiAnimating) = 1;
                    end
                    textureArray{roiAnimating} = xp.image.texture{idStimReward(roiAnimating),iFrameRewarding(roiAnimating)};
            end

            % draw background
            Screen('DrawTexture', xp.screen.win, xp.image.texture{1,1}, [], xp.screen.rect(:,1));
            Screen('DrawTexture', xp.screen.win, xp.image.texture{3,1}, [], xp.screen.rect(:,1) + xp.screen.rect(4,1)*[0 -0.9 0 -0.9]');

            % draw objects
            for iObject = 1:nStimOnScreen
                Screen('DrawTexture', xp.screen.win, textureArray{iObject}, [], xp.screen.rect(:,1 + iObject), 0, []);
            end

            % draw boxes, for objects still hidden
            if flagBox
                for iObject = 1:nStimOnScreen
                    thisBox   = occrect + xp.screen.rect(:,1 + iObject);
                    thisBox   = thisBox + thisBox(2)*[0 flagOccluderState(iObject) 0 flagOccluderState(iObject)]';
                    Screen('DrawTexture', xp.screen.win, xp.image.texture{3,boxTex}, [], thisBox + (boxTex == 3)*box_highlight_rect_pad);
                end
            end

            stimOnset = Screen('Flip',xp.screen.win,stimOnset + framedur,0);
            xp.eyelink.write('Frame displayed: states %s playing %d state %d @%.3fsec', num2str(flagObjectState), roiAnimating, flagObjectState(roiAnimating), stimOnset)

            iEvent = iEvent + 1;
        end

        % end of trial checks
        %         if flagEndIfLookAway && (timeFix - timeOutOfScreenStart > timeOutOfScreenMax)
        %             goodbyeMessage = 'end: watching away @%.3fsec';
        %             flagEndTrial   = 1;
        %             flagResult     = 2;
        %         end
        if flagBox && all(flagObjectState >= 2)
            endAfter       = timeFix + 1 - GetSecs;   % 1 second after fully revealing second object, end trial
            WaitSecs(endAfter)
            goodbyeMessage = 'end: watching everything @%.3fsec';
            flagEndTrial   = 1;
        end
        if timeFix - trigOnset > durStimPostTrig || timeFix - stimOnset0 > maxtime
            goodbyeMessage = 'end: watching enough @%.3fsec';
            flagEndTrial   = 1;
        end
    end


    %% CHECKS

    % checks
    [roiFix, timeFix] = xp.checkFix([1+(1:nStimOnScreen) 1], 1/30); % added some padding (1/30 * screen height) to make AOIs bigger
    [durFixIn, flagFixIn, timeFirstIn] = xp.checkROI(roiFix, timeFix);
    flagResult = xp.checkKeyboard;
    flagResult = xp.checkEndTrial(flagResult,roiFix);
    %     flagResult = xp.checkEndStep(flagResult, timeStepStart, durMax);
    if flagResult, flagEndTrial = true; end


    %%% checking fixations in boxes
    %     [roiFix, timeFix] = xp.fixCheck([1+(1:nStimOnScreen) 1], true);
    % if roiFix == 0
    %     if timeOutOfScreenStart == Inf
    %         timeOutOfScreenStart = timeFix;
    %     end
    % else
    %     timeOutOfScreenStart = Inf;
    %     if roiFix==nStimOnScreen+1
    %         roiFix = 0;
    %     end
    % end

    %%% keyboard check
    %     [keyIsDown,~,keyCode] = PsychHID('KbCheck', xp.keyboard.index);      %reads key pressed
    %     if keyIsDown
    %         switch find(keyCode,1)
    %             case key.escape
    %                 flagEndTrial = 1;
    %                 flagResult   = 3;
    %             case key.q
    %                 flagResult   = 9;
    %             case key.c
    %                 flagEndTrial = 1;
    %                 flagResult   = -1;         % calibrate
    %             case key.p
    %                 flagResult = -2;
    %                 flagEndTrial = 1;
    %             case key.s                      % plays attention sound
    %                 if GetSecs - timeLastSound > 0.5        % making sure it is not just key staying pressed
    %                     xp.sound.which = xp.sound.data{1,randi(6)};
    %                     timeLastSound = xp.sound.play;
    %                 end
    %         end
    %     end


    % end of trial checks
    if flagEndIfLookAway && roiFix == -6
        goodbyeMessage = 'end: watching away @%.3fsec';
        flagEndTrial   = 1;
        flagResult     = 2;
    end

    if flagEndTrial == 1
        xp.eyelink.write(goodbyeMessage, GetSecs)
        xp.trial.varValue.durFixFirst = countFirstROI;
        fprintf("trial ends with object state %s, and message: %s\n", sprintf("%d ", flagObjectState), goodbyeMessage)
        flagLoop = false;
        xp.erase;
    end
end