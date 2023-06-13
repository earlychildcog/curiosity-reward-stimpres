function toci = timetests(type,N,n)
    if nargin <= 1
        N = 10^5;
    end
    if nargin == 0
        type = 1;
    end
    if nargin < 3
        n = 3;
    end
    toci = 0;
    for k = 1:N
        timeLastIn = rand(n,1);
        [timeFix, roiFix] = max(timeLastIn);
        if type == 1
            tic
            durFix = min(timeFix - timeLastIn(timeLastIn ~= timeFix));
            toci = toci + toc;
        elseif type == 2
            tic
            durFix = min(timeFix - timeLastIn(timeLastIn ~= timeLastIn(roiFix)));
            toci = toci + toc;
        elseif type == 3
            tic
            timeLastIn_ = timeLastIn;
            timeLastIn_(roiFix) = [];
            durFix = min(timeFix - timeLastIn_);
            toci = toci + toc;
        elseif type == 4
            tic
            durFix = helperF(timeLastIn, roiFix, timeFix);
            toci = toci + toc;
        elseif type == 5
            tic
            durFix = min(timeFix - timeLastIn([1:roiFix-1, roiFix+1:end]));
            toci = toci + toc;
        end
    end
    toci = toci/N;
end

function durFix = helperF(timeLastIn, roiFix, timeFix)
    timeLastIn(roiFix) = [];
    durFix = min(timeFix - timeLastIn);
end