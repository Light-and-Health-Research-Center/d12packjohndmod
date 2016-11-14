function [IS,IV] = isiv(ActivityIndex,epoch)
% ISIV Calculates interdaily stability (IS) and intradaily variability (IV)
%	Returns the interdaily stability and the intradaily variability 
%   statistic for time series dataArray.
%	dataArray is a column vector and must be in equal time increments
%	given by epoch an object of class samplingrate.
%	Converts data to hourly increments before calculating metric.
%
% EXAMPLE:
%   [IS,IV] = isiv.isiv(dataArray,epoch);
%
% See also SAMPLINGRATE.

IS = [];
IV = [];

n1 = numel(ActivityIndex);
if (n1 < 24 || n1*hours(epoch) < 24)
    warning('Cannot compute statistic because time series is less than 24 hours');
    return
end

if hours(epoch) > 1
    warning('Cannot compute statistic becasue time increment is larger than one hour');
    return
end

if (rem(1/hours(epoch),1) > eps)
    warning('epoch does not divide into an hour without a remainder');
end

% Make sure dataArray spans whole days, remove excess from end
nDay = floor(n1*minutes(epoch)/1440);
n2 = floor(nDay*1440/minutes(epoch));
ActivityIndex = ActivityIndex(1:n2);

% Resample data to hourly increments
X_i = resample(ActivityIndex,epoch,60);
% Number of samples
n = numel(X_i);
% Number of samples per day
p = 24;
% Average of samples at each time of day
Xmat = reshape(X_i,[p,nDay]);
Xbar_h = mean(Xmat,2);
% Average of all samples
Xbar = mean(X_i);

% Calculate Interdaily Stability
IS = (n*sum((Xbar_h - Xbar).^2))/(p*sum((X_i - Xbar).^2));
% Calculate Intradail Variability
IV = (n*sum(diff(X_i).^2))/((n-1)*sum((X_i-Xbar).^2));

end

function resampledDataArray = resample(dataArray,epoch,range)
%RESAMPLE Summary of this function goes here
%   dataArrya
%   epoch is object of class samplingrate
%   range is in minutes
%
% See also SAMPLINGRATE.

n = numel(dataArray);
sampleSize = floor(range/minutes(epoch)); % Number of data points within a range
nSamples = floor(n/sampleSize); % Number of whole sample ranges of data
% Remove extra data from end
dataArray = dataArray(1:nSamples*sampleSize);
% Reshape data into a matrix
dataMatrix = reshape(dataArray,[sampleSize,nSamples])';
% Take mean to resample data
resampledDataArray = mean(dataMatrix,2);

end

function mNoNan = nonanmean(dataArray)
%NONANMEAN Removes NaN elements before taking mean

nanIdx = isnan(dataArray);
noNanDataArray = dataArray(~nanIdx);
mNoNan = mean(noNanDataArray);

end

function amplitudeArray = enright(dataArray,testPeriodArray)
% ENRIGHT Calculates the Enright periodogram on column vector
%   dataArray using range of periods given by testPeriodArray. Formulation 
%   taken from Philip G. Sokolove adn Wayne N. Bushell, The Chi Square 
%   Periodogram: Its Utility for Analysis of Circadian Rhythms, J. Theor. 
%   Biol. (1978) Vol 72, pp 131-160.

n = numel(dataArray);
nPeriods = numel(testPeriodArray);
amplitudeArray = zeros(nPeriods,1);
for i1 = 1:nPeriods
    P = testPeriodArray(i1); % true as long as p is an integer, i.e. no fractional periods (for now)
    K = floor(n/P);
    dataArraySubset = dataArray(1:K*P);
    M = (reshape(dataArraySubset,P,K))';
    if n/P > K
        % fill empty cells with mean taken along 1st dimension
        partialRow = [(dataArray(K*P+1:end))' mean(M(:,n-K*P+1:P),1)];
        M = [M;partialRow];
    end
    Xmean = mean(M); % column means
    Xp = mean(Xmean);
    amplitudeArray(i1) = sqrt(1/P*sum((Xmean-Xp).^2));
end

end


