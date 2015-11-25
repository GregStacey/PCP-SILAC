function clean_chromatogram = cleanChromatogram(rawchrom)

% This function takes a 'raw' chromatogram, i.e. one row from the Excel tables produced by MQ, and
% pre-processes it. The pre-processing steps include:
%   1. Impute (fill in) single missing values (nans) by linear interpolation;
%   2. Fill in first and last fractions with a 0 if they're missing;
%   3. Replace values <0.2 with nan;
%   4. If a value is not part of 5 consecutive values, replace it with 0.05;
%   5. Add 5 nans to either side of the chromatogram;
%   6. Smooth whole chromatogram with a boxcar filter (moving average).
%
% Input: nx1 vector, where n is the number of fractions.
% Output: nx1 vector.
%
% Adapted from Nichollas Scott's Gaus_build_24_1.m.
% Made by Greg Stacey on Nov 25 2015.



%% 0. Initialize

if nargin~=1
  error('Input must be a single variable, i.e. one chromatogram.')
end

[n1,n2] = size(rawchrom);
if n1~=1 && n2~=1 || (n1==1 && n2==1)
  error('Input must be a 1-dimensional vector, i.e. a single chromatogram.')
end

% transform into row vector if necessary
if n1>n2
  rawchrom = rawchrom';
end

tmpchrom = rawchrom; % dummy variable


%% 1. Replace single missing values with mean of neighbours
tmp = [1 0 1]; % look for a single nan flanked by real values, i.e. [1 0 1]
tmp2 = strfind(~isnan(tmpchrom),tmp); % find where [1 0 1] occurs in the chromatogram
for ii = 1:length(tmp2)
  I = tmp2(ii) + 1;
  tmpchrom(I) = mean(tmpchrom([I-1 I+1]));
end


% 2. Fill in first and last fractions
if isnan(tmpchrom(1))
  tmpchrom(1)=0;
end

if isnan(tmpchrom(end))
  tmpchrom(end)=0;
end


% 3. Replace values <0.2 with nan
tmpchrom(tmpchrom<0.2) = nan;


% 4. Consecutive numbers, if less then 5 consecutive number removes chromogram and replace with 0.05
%tmpchrom=[nan(1,10) tmpchrom nan(1,10)];
Nminconsecutive = 5; % minimum number of consecutive non-nan values
tmp = ones(1,Nminconsecutive); % the pattern to look for: [1 1 1 1 1]
tmp2 = strfind(~isnan(tmpchrom),tmp); % find the pattern
tmpchrom2 = ones(size(tmpchrom))*0.05; % dummy variable
for ii = 1:length(tmp2)
  I = tmp2(ii) : tmp2(ii) + Nminconsecutive-1;
  tmpchrom2(I) = tmpchrom(I);
end
tmpchrom = tmpchrom2;


% 5. Add 5 nans to either side of the chromatogram
tmpchrom = [nan(1,5) tmpchrom nan(1,5)];


% 6. Smooth whole chromatogram with a boxcar filter (moving average).
tmpchrom= smooth(tmpchrom,4);


clean_chromatogram = tmpchrom;


