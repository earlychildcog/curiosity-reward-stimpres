%% Experimental script for the reward task of the curiosity longitudinal study
% Presenting characters behind occluders in a contingent manner
%
% NB: Make sure that development variables are re-sat to proper testing
%     values before starting to test with a participant:
%   - eyetrackingOn = true
%   - xp.debug = false
%


function curiosityR_start(debug)
% debugging keep accepting keyboard/mouse input, else they are disabled
% debug: 0 no debug, 1 debug/eyetracking, 2 debug/no eyetracking
arguments
    debug uint8 {mustBeMember(debug, [0 1 2])} = 0
end
% make sure in case of error that cursor and keyboard are reactivated
    try 
        start_main(debug)                  %run the experiment script
    catch my_error
        ListenChar(0);                  %reactivate keyboard
        ShowCursor();                   %show cursor again
        Screen('CloseAll');             %Close screen window, in case it had opened
        PsychPortAudio('Close');        % turn off sound
        try
            Eyelink('Shutdown');        %close eyetracker
        catch
             warning('Eyelink not connected or not shutting down properly')
        end
        clear ExperimentControlClass
        rethrow(my_error);              %show what happened in case of an error
    end
end


function start_main(debug)
addpath(genpath('src'))

%% settings
eyetrackingOn = true;
xp            = ExperimentControlClass; % main experiment structure

if debug > 0
    xp.debug      = true;                   % true keeps keyboard/mouse input, false disables them
    if debug > 1
        eyetrackingOn = false;
    end
end
if xp.debug
    xp.screen.nr  = min(Screen('Screens'));
else
    xp.screen.nr  = max(Screen('Screens'));
end
xp.getExpName;                          % prompt for experiment name
xp.setSubjNo;                           % prompt for subject/session numbers
xp.init; 

xp.settings.nStimTotal         = 9;
xp.settings.nStimFamTotal      = 3;
xp.settings.timeToTrigger      = 0.35;  % time for fixation to trigger
xp.settings.timeOut            = 0.1;   % time fixating away to reset fixation timer
xp.settings.timeOutOfScreenMax = 5;
if xp.eegon
    NetStationHostName = '10.10.10.42';
    NetStation('Connect',NetStationHostName);
end

% <-:      fake fixation to left ROI
% ->:      fake fixation to right ROI
% ^:       fake fixation to middle ROI
% SPACE:   move to next trial
% Escape:  exit animation loop
% c:       recalibrate
% s:       sound (only works during fixation cross)
% q:       quit experiment (only works during fixation cross)
% b:       take a break (with video)

xp.keyboard.keyStrings = {'q' 'leftarrow' 'rightarrow' 'uparrow' 'space' 'escape' 'c' 's' 'p'};
xp.keyboard.init;
 
yFull = 1024;
xFull = 1280;

xBuff = 0;
yBuff = 100;
xRduc = xFull - xBuff;
yRduc = yFull - yBuff;

W = 1280;
H = 1024;
YB = 2/3;
YT = 1/3;
BoxRadius = 1/7;
xp.settings.occrect = round([0 H 0 H]'*(1/12)); % [20 100 -40 0]';

% box positions in array: [LB RB MB LT RT MT]
rectObj = round(repmat([3/16 YB; 13/16 YB; 1/2 YB; 1/4 YT; 3/4 YT; 1/2 3/16]', 2, 1).*[W H W H]' + [-1 -1 +1 1]'*H*(BoxRadius));

% fixation cross 
rectCentreSmall = round([W/2 H/2 W/2 H/2] + [-H -H H H]*1/20)';
rectCentreBig   = round([W/2 H/2 W/2 H/2] + [-H -H H H]*1/10)';

xp.screen.rect  = [[0 0 W H]' rectObj rectCentreSmall rectCentreBig];


xp.image.load                           % load images from stimuli/images folder
xp.sound.load

if xp.eegon
    NetStation('Synchronize',xp.screen.win);
end

%% Play video at start + calibrate
Screen('DrawTexture', xp.screen.win, xp.image.texture{1,1}, [], xp.screen.rect(:,1));
xp.flip
xp.waitSpace;
% xp.sound.which = xp.sound.data{3,2}; %Mozart mushroom sound
% result = videoPlay(xp, fullfile(pwd, 'stimuli/videos/03-break/mushrooms.avi'), 1, 1);
WaitSecs(0.2);
xp.sound.which = xp.sound.data{3,1};
videoPlay(xp, fullfile(pwd, 'stimuli/videos/03-break/waybuloo.mov'), 1, 1);
  
if eyetrackingOn
    xp.eyelink.init                     % initialise eyelink
     
    xp.eyelink.calibrate                % calibrate eyetracker
    WaitSecs(0.1)   
end

%% trial loop
xp.trial.varNames = {'trialtype' 'trialno' 'positions1' 'positions2' 'result' 'durFixFirst'};
xp.trial.varValue.trialtype   = [];
xp.trial.varValue.trialno     = [];
xp.trial.varValue.positions1  = [];
xp.trial.varValue.positions2  = [];
xp.trial.varValue.result      = [];
xp.trial.varValue.durFixFirst = NaN;


if xp.eegon
    NetStation('StartRecording');
end

fileRando = sprintf('rand/RandomisationTable_Subj%03d_Session_%d.csv',xp.subject,xp.sessionNo);
fileRando = 'RandomisationTable_Subj001_Session_1.csv';     % FOR TEST
% fileRando = sprintf('rand_stim/StimOrderPilotStim_Subj%03d.csv',xp.subject); %FOR STIM PILOT
RandomisationTable = readtable(fileRando);
% nTrial = size(RandomisationTable, 1);
% fam-colour, visible, invisible
% names = {'fam1' 'fam2' 'TestVis' 'TestInvis'}; 
iTrial = 0;
nTrial = size(RandomisationTable, 1); % we may need some better way to end

while iTrial < size(RandomisationTable, 1)
    xp.trial.nTrial = nTrial;
    iTrial = iTrial + 1;
    idStimInPosition = [RandomisationTable{iTrial,2:4}; RandomisationTable{iTrial,5:7}];
    % flagResult:
    %   -2: pause/video
    %   -1: recalibrate
    %    0: nothing
    %    1: done
    %    2: done by looking away
    %    3: skipped trial
    %    9: quit
    flagResult = -10;
    trialtype                    = RandomisationTable.TrialType{iTrial};
    xp.trial.varValue.trialtype  = trialtype;
    xp.trial.varValue.trialno    = iTrial;
    xp.trial.varValue.positions1 = num2str(idStimInPosition(1,:));
    xp.trial.varValue.positions2 = num2str(idStimInPosition(2,:));
    xp.trial.varValue.result     = flagResult;
    flagResultAttget = xp.attgetPart;
    if flagResultAttget == 3 && startsWith(trialtype, 'Test')
        RandomisationTable = [RandomisationTable; RandomisationTable(iTrial,:)]; %#ok<AGROW>
        nTrial = nTrial + 1;
    end
    while flagResultAttget == 1
        flagResultAttget = 0;
        flagResult = xp.playTrial(idStimInPosition, trialtype);
        xp.trial.varValue.result = flagResult;
        xp.eyelink.stoprec
        if flagResult == -2
            xp.sound.which = xp.sound.data{3,1};
            flagResultBreak = xp.videoPlay(fullfile(pwd, 'stimuli/videos/03-break/waybuloo.mov'), 1, 1);
            if flagResultBreak == -1
                xp.eyelink.calibrate;
            elseif flagResultBreak == 9
                break
            end
            flagResultAttget = xp.attgetPart;
        elseif flagResult == 2 && startsWith(trialtype, 'Test')           % choose a flag for this
            RandomisationTable = [RandomisationTable; RandomisationTable(iTrial,:)]; %#ok<AGROW>
            nTrial = nTrial + 1;
        elseif flagResult == 3 && startsWith(trialtype, 'Test')
            RandomisationTable = [RandomisationTable; RandomisationTable(iTrial,:)]; %#ok<AGROW>
            nTrial = nTrial + 1;
            WaitSecs(0.1);
        end
    end
    if flagResult == -1
        xp.eyelink.calibrate;
    elseif flagResult == 9 || flagResultAttget == 9
        break
    end
end

%%

if xp.eegon
    NetStation('StopRecording');
    NetStation('Disconnect');
end
% play video in the end of experiment
WaitSecs(0.2);
xp.sound.which = xp.sound.data{4,1};
videoPlay(xp, fullfile(pwd, 'stimuli/videos/04-end/ClappingEndExpt.mp4'), 1, 1, 0);

xp.finish
%%
end