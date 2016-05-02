function user_new = cleanuser(user)
% This little function does a couple things.
% First, it checks that the user structure in pcpsilac_master.m is formatted correctly.
%   1. Does user.maindir end in a forward slash?
%   2. Do the data files exist? If not, are there similarly-named data files?
% Second, it adds user.maindir/Code and user.maindr/Code/Functions to path

user_new = user;


%% Check that files exist

% check that user.maindir ends in a forward slash
if user.maindir(end) ~= '/'
  user_new.maindir = [user.maindir '/'];
end

% do the data files exist?
% user.MQfiles
for ii = 1:length(user.MQfiles)
  if ~exist(user.MQfiles{ii},'file')
    error('\n The following file could not be found: \n %s', user.MQfiles{ii})
  end
end
% user.majorproteingroupsfile
if ~exist(user.majorproteingroupsfile,'file')
  error('\n The following file could not be found: \n %s', user.majorproteingroupsfile)
end
% user.mastergaussian
% user.fastafile
% user.omimfile
% user.corumfile
if ~exist(user.corumfile,'file')
  error('\n The following file could not be found: \n %s', user.corumfile)
end

% Make user.corumpairwisefile
fn_corumpair = [user.maindir '/Data/Corum_pairwise.csv'];
if ~exist(fn_corumpair,'file')
  disp('cleanuser: Making Corum_pairwise.csv.')
  try
    corum2pairwise(user)
  catch
    error('cleanuser: Failed to make Corum_pairwise.csv. Aborting!')
  end
end
user_new.corumpairwisefile = fn_corumpair;

% Make user.corumcomplexfile
fn_corumcomplex = [user.maindir '/Data/Corum_complex.csv'];
try
  corumextractcomplex(user)
catch
  error('cleanuser: Failed to make Corum_complex.csv. Aborting!')
end
user_new.corumcomplexfile = fn_corumcomplex;



%% Check that user is formatted correctly

% ensure that user.silacratios is a cell, not a string. this is a problem when Nchannels=1.
if ischar(user.silacratios)
  user_new.silacratios = {user.silacratios};
end

% ensure that fractions are between 0 and 1, not 0% and 100%

% ensure that user.Dilution_factor exists

% ensure that the silac ratios in user.MQfiles and user.silacratios are the same order

% ensure that treatmentcondition is part of every comparisonpairs



%% Add user.maindir/Code and user.maindr/Code/Functions to path

f1 = [user.maindir 'Code'];
f2 = [user.maindir 'Code/Functions'];
if ~exist(f1, 'dir'); mkdir(f1); end
if ~exist(f2, 'dir'); mkdir(f2); end

addpath(f1,f2)

