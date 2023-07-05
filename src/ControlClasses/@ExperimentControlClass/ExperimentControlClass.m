classdef ExperimentControlClass < ExperimentControlClassBase
    % Some description
    properties    
        eegon = false
    end
    
    methods
        function xp = ExperimentControlClass(status)
            
            xp.image    = ImageControlClass;
            xp.screen   = ScreenControlClass;
            xp.eyelink  = EyelinkControlClass;
            xp.sound    = SoundControlClass;
            xp.keyboard = KeyControlClass;
            xp.trial    = TrialControlClass;
            xp.log      = LogControlClass;
            xp.name = 'curR';   % set experiment name
            if nargin == 0 || ~status
                return
            else
                xp.init
            end
        end
    end
end