function s = parseraw(obj,varargin)
%PARSERAW Summary of this function goes here
%   Detailed explanation goes here

s = obj.parseloginfo;

data_log = obj.data_log;

% seperate data into raw R,G,B,A
n = floor(numel(data_log)/4)*4;
data_log = data_log(1:n);
d = double((reshape(data_log,4,n/4))');
RedCounts = d(:,1);
GreenCounts = d(:,2);
BlueCounts = d(:,3);
ActivityIndexCounts = d(:,4);

% remove resets (value = 65278) and unwritten (value = 65535)
OriginalResets = RedCounts == 65278;
unwritten = RedCounts == 65535;
q = ~(OriginalResets | unwritten);

s.RedCounts = RedCounts(q);
s.GreenCounts = GreenCounts(q);
s.BlueCounts = BlueCounts(q);
s.ActivityIndexCounts = ActivityIndexCounts(q);

% Apply range change
% ActivityIndexCounts is odd other values high x10 (flag = true)
% ActivityIndexCounts is even other values low x1 (flag = false)
flag = mod(s.ActivityIndexCounts,2) == 1;
s.RedCounts(flag)   = s.RedCounts(flag)*10;
s.GreenCounts(flag) = s.GreenCounts(flag)*10;
s.BlueCounts(flag)  = s.BlueCounts(flag)*10;
s.ActivityIndexCounts(flag) = s.ActivityIndexCounts(flag)-1;

% Summarize resets
OriginalResets2 = [false;OriginalResets(~unwritten)];
CumulativeResets = [cumsum(OriginalResets);0];
Resets = CumulativeResets(~OriginalResets2);
s.Resets = Resets(1:end-1);

% create a time array
nEntries = numel(s.RedCounts);
RelativeTime = s.Epoch*(0:nEntries-1)';
s.Time = s.Start + RelativeTime;

end

