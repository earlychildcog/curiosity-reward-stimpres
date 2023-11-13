%% Pseudorandomise the presentation for the curiosity reward (last) task:
%
% 1/ Familiarisation trials (N = 5):
%    Randomise where each object appears both at the top and bottom of the
%    screen such that eahc of the 3 objects is twice in each position (then
%    delete the first trials because there are only 5 and not 6 fam trials:
%    2 colouring fam and 3 revelaing fam)
%
% 2/ Test trials (N = 9):
%    Randomise where each object appears both at the top and bottom of the
%    screen such that each of the 9 objects is once in each position
%
% This is done once per subject (N = 999) and per session (N = 3) i.e. 3000
% times.
%


%% Define the parameters
clear all
PoolFam        = 1:3;
PoolTest       = 1:9;
NBoxFamTrials1 = 3;
NBoxFamTrials  = NBoxFamTrials1 + 36/6 -1;
NColFamTrials  = 1;
NTestTrials    = 36;


for iSession = 1:3
    for iSubj = 1:999
        %% Get the familiarisation trials

        % 1st obj
        Obj1Fam = [];
        for iShuffle = 1:(NBoxFamTrials+NColFamTrials)/3
            Obj1Fam  = [Obj1Fam,Shuffle(PoolFam)];
        end
        Obj1Fam  = Obj1Fam(1:NBoxFamTrials+NColFamTrials);

        iTrial = 1; % Initialise trial loop

        while iTrial <= NBoxFamTrials + NColFamTrials

            % Calculate how many trials passed compared to pool size
            trialRem = rem(iTrial, size(PoolFam,2));  % trials passed sinced whole pool was (re-)sat
            trialDiv = floor((iTrial-1)/size(PoolFam,2));  % times the whole pool was already used (using itrial-1 so still 0 wen reaches pool size, then 1 for next trial when pool resets)

            % Set pools
            if trialRem == 1
                % Set/reset to whole pool if first trial or whole pool was already used
                PoolFam2 = PoolFam;
                PoolFam3 = PoolFam;
            else
                % Else, exclude former obj2/obj3 values from obj2/obj3 pool
                PoolFam2 = setdiff(PoolFam,Obj2Fam(trialDiv*width(PoolFam)+1:iTrial-1));
                PoolFam3 = setdiff(PoolFam,Obj3Fam(trialDiv*width(PoolFam)+1:iTrial-1));
            end

            % 2nd obj
            PoolFam2 = setdiff(PoolFam2,Obj1Fam(iTrial)); % Exclude current obj1 value
            if isempty(PoolFam2)
                % Start over if the draw is impossible
                iTrial   = 0;
                Obj2Fam  = [];           Obj3Fam  = [];
                PoolFam2 = PoolFam;      PoolFam3 = PoolFam;
            elseif size(PoolFam2,2) == 1
                % Pick that last value that's left if only 1 left
                Obj2Fam(iTrial) = PoolFam2;
            else
                % Randomly pick a value that's left if more than 1 left
                Obj2Fam(iTrial) = randsample(PoolFam2,1);
            end

            % 3rd obj
            if iTrial > 0
                PoolFam3 = setdiff(PoolFam3,[Obj1Fam(iTrial),Obj2Fam(iTrial)]); % Exclude current obj1 and obj2 values
                if isempty(PoolFam3)  % Start over if the draw is impossible
                    iTrial   = 0;
                    Obj2Fam  = [];        Obj3Fam  = [];
                    PoolFam2 = PoolFam;   PoolFam3 = PoolFam;
                elseif size(PoolFam3,2) == 1
                    Obj3Fam(iTrial) = PoolFam3; % Pick that last value that's left
                else
                    Obj3Fam(iTrial) = randsample(PoolFam3,1); % Randomly pick a value that's left
                end
            end

            % Increment trial loop run
            iTrial = iTrial + 1;
        end

        % Get a copy of the 3 matrices shuffled into another matrix (this will
        % be the top positions, former values are more controlled: used for the
        % bottom positions)
        ObjBottomFam = [Obj1Fam',Obj2Fam',Obj3Fam'];
        ObjTopFam    = ObjBottomFam;
        for iTrial = 1:size(ObjTopFam,1)
            ObjTopFam(iTrial,:) = Shuffle(ObjTopFam(iTrial,:));
        end

        %     % Save another variable that gives the obj identities
        %     % (here it's always the same: 1-2-3)
        % %     ObjIDFam = repmat(1:3,NFamTrials,1);
        %     ObjIDFam  = ObjBottomFam;
        %     ObjBottomFam = ;
        %     ObjTopFam = ;

        %% Get the test trials

        % 1st obj
        Obj1Test = [];
        for iShuffle = 1:(NTestTrials/2)/3 %using N/2 because half of trials are 'same' with only 1 obj in them
            Obj1Test  = [Obj1Test,Shuffle(PoolFam)];
        end
        Obj1Test  = Obj1Test(1:NTestTrials/2);

        iTrial = 1; % Initialise trial loop

        while iTrial <= NTestTrials/2

            % Calculate how many trials passed compared to pool size
            trialRem = rem(iTrial, size(PoolTest,2));  % trials left until whole pool used
            trialDiv = floor((iTrial-1)/size(PoolTest,2));  % times the whole pool was already used

            % Set pools
            if trialRem == 1
                % Set/reset to whole pool if first trial or whole pool was already used
                PoolTest2 = PoolTest;
                PoolTest3 = PoolTest;
            else
                % Else, exclude former obj2/obj3 values from obj2/obj3 pool
                PoolTest2 = setdiff(PoolTest,Obj2Test(trialDiv*width(PoolTest)+1:iTrial-1));
                PoolTest3 = setdiff(PoolTest,Obj3Test(trialDiv*width(PoolTest)+1:iTrial-1));
            end

            % 2nd obj
            PoolTest2 = setdiff(PoolTest2,Obj1Test(iTrial)); % Exclude current obj1 value
            if isempty(PoolTest2)
                % Start over if the draw is impossible
                iTrial    = 0;
                Obj2Test  = [];           Obj3Test  = [];
                PoolTest2 = PoolTest;     PoolTest3 = PoolTest;
            elseif size(PoolTest2,2) == 1
                % Pick that last value that's left if only 1 left
                Obj2Test(iTrial) = PoolTest2;
            else
                % Randomly pick a value that's left if more than 1 left
                Obj2Test(iTrial) = randsample(PoolTest2,1);
            end

            % 3rd obj
            if iTrial > 0
                PoolTest3 = setdiff(PoolTest3,[Obj1Test(iTrial),Obj2Test(iTrial)]); % Exclude current obj1 and obj2 values
                if isempty(PoolTest3)  % Start over if the draw is impossible
                    iTrial   = 0;
                    Obj2Test  = [];        Obj3Test  = [];
                    PoolTest2 = PoolTest;  PoolTest3 = PoolTest;
                elseif size(PoolTest3,2) == 1
                    Obj3Test(iTrial) = PoolTest3; % Pick that last value that's left
                else
                    Obj3Test(iTrial) = randsample(PoolTest3,1); % Randomly pick a value that's left
                end
            end

            % Increment trial loop run
            iTrial = iTrial + 1;
        end

        % Get a copy of the 3 matrices shuffled into another matrix (this will
        % be the top positions, former values are more controlled: used for the
        % bottom positions)
        ObjBottomTest = [Obj1Test',Obj2Test',Obj3Test'];
        ObjTopTest    = ObjBottomTest;
        for iTrial = 1:size(ObjTopTest,1)
            ObjTopTest(iTrial,:) = Shuffle(ObjTopTest(iTrial,:));
        end

        %     % Save another variable that gives the obj identities
        %     % (here it's always the same: 1-2-3)
        % %     ObjIDTest = repmat(1:3,NTestTrials,1);
        %     ObjIDTest  = ObjBottomTest;
        %     ObjBottomTest = ;
        %     ObjTopTest = ;


        %% Now randomise when trials that are the same will appear
        iEvenOrOdd     = randsample(repmat([0 1],1,ceil(NTestTrials/2)),ceil(NTestTrials/2)); %choose even/odd number
        iItem          = 1:ceil(NTestTrials/2);
        iTrialSame     = iItem*2 - iEvenOrOdd;
        iTrialDiff     = iItem*2 - ~iEvenOrOdd;
        % And randomise whether they are visible
        itemIDSame = [];
        for iShuffle = 1:ceil((NTestTrials/2)/length(PoolTest)) %using N/2 because half of trials are 'different'
            itemIDSame  = [itemIDSame,Shuffle(PoolTest)];
        end

%         itemIDSame     = Shuffle(iItem);
        ObjTopTestOG   = ObjTopTest;
        for iLoop = 1:NTestTrials/2
            iTrial = iTrialSame(iLoop);
            ObjTopTest = [ObjTopTest(1:iTrial-1,:); repmat(itemIDSame(iLoop),1,3); ObjTopTest(iTrial:end,:)];
            Obj1Test   = [Obj1Test(1:iTrial-1), itemIDSame(iLoop), Obj1Test(iTrial:end)];
            Obj2Test   = [Obj2Test(1:iTrial-1), itemIDSame(iLoop), Obj2Test(iTrial:end)];
            Obj3Test   = [Obj3Test(1:iTrial-1), itemIDSame(iLoop), Obj3Test(iTrial:end)];
        end


        %% Concatenate variables together in the order the trials should appear
        % Concatenate ObjOrder: 6 columns (3 for ObjTop, 3 for ObjBottom)
        % and 1 line per trial, starting with Fam1 and Fam2 trials, then
        % Test trials, and will insert FamRep trials later
        ObjOrder = [[ObjTopFam(1:NColFamTrials+NBoxFamTrials1,:), Obj1Fam(1:NColFamTrials+NBoxFamTrials1)', Obj2Fam(1:NColFamTrials+NBoxFamTrials1)', Obj3Fam(1:NColFamTrials+NBoxFamTrials1)']; ...
            [ObjTopTest, Obj1Test', Obj2Test', Obj3Test']];
        % Create a TrialType var
        TrialType(1:NColFamTrials)                              = {'Fam1'};
        TrialType(NColFamTrials+1:NBoxFamTrials1+NColFamTrials) = {'Fam2'};
        TrialType(iTrialDiff + NBoxFamTrials1 + NColFamTrials)  = {'TestDiff'};
        TrialType(iTrialSame + NBoxFamTrials1 + NColFamTrials)  = {'TestSame'};
        % Insert 'FamRep' trials every 6 trials
        for iBoxFamTrialRepLoop = 1:NBoxFamTrials-NBoxFamTrials1
            iBoxFamTrialRep = NColFamTrials+NBoxFamTrials1 + iBoxFamTrialRepLoop*6 +iBoxFamTrialRepLoop;
            % Concatenate trial type
            TrialType = cat(2, TrialType(1:iBoxFamTrialRep-1), {'FamRep'}, TrialType(iBoxFamTrialRep:end));
            ObjOrder  = [ObjOrder(1:iBoxFamTrialRep-1,:); ...
               [ObjTopFam(iBoxFamTrialRepLoop+NColFamTrials+NBoxFamTrials1,:), ...
               Obj1Fam(iBoxFamTrialRepLoop+NColFamTrials+NBoxFamTrials1)', Obj2Fam(iBoxFamTrialRepLoop+NColFamTrials+NBoxFamTrials1)', Obj3Fam(iBoxFamTrialRepLoop+NColFamTrials+NBoxFamTrials1)'];...
               ObjOrder(iBoxFamTrialRep:end,:)];
        end


        %% Save into a table
        % Create a table
        RandomisationTable = table(TrialType',ObjOrder(:,1),ObjOrder(:,2),ObjOrder(:,3),ObjOrder(:,4),ObjOrder(:,5),ObjOrder(:,6));
        RandomisationTable.Properties.VariableNames = {'TrialType','ObjTop1','ObjTop2','ObjTop3','ObjBottom1','ObjBottom2','ObjBottom3'};

        % Save to a CSV file
        writetable(RandomisationTable,sprintf('Stim order/StimOrder_Subj%03d_Session%d.csv',iSubj,iSession));

        % Clear before moving on to next participant/session
        clearvars -except iSession iSubj NBoxFamTrials1 NBoxFamTrials NColFamTrials NTestTrials PoolFam PoolTest coloursStim

    end
end

