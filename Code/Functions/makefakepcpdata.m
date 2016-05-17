
%% Initialize

datadir = [user.maindir 'Data/']; % where data files live
if ~exist(datadir, 'dir'); mkdir(datadir); end

Nproteins = 200; % per replicate
Ninteractions = 20; % pairwise interactions
Ndifferentcomparisons = 5;
x = 1:user.Nfraction;



%% Make fake Chromatograms (chrom) to use as templates

chrom = zeros(Ninteractions,user.Nfraction);
for ii = 1:Ninteractions
  
  % chromatogram, shared between interactors and replicates
  Ngauss = ceil(rand*3);
  C = rand(Ngauss,1)*(user.Nfraction - 10) + 5; % [5 50]
  H = rand(Ngauss,1)*15 + 3; % [3 18]
  W = rand(Ngauss,1)*6 + 2; % [2 8]
  for jj = 1:Ngauss
    chrom(ii,:) = chrom(ii,:) + H(jj)*exp(-((x-C(jj))/W(jj)).^2);
  end
end



%% Copy chrom into each replicate and channel

Chromatograms = cell(length(user.silacratios),1);
Proteins = cell(length(user.silacratios),1);
replicate = cell(length(user.silacratios),1);

for ii = 1:length(user.silacratios)
  Chromatograms{ii} = nan(Nproteins*user.Nreplicate,user.Nfraction);
  replicate{ii} = nan(Nproteins*user.Nreplicate, 1);
  Proteins{ii} = cell(Nproteins,1);
  
  cc = 0; % row counter in Chromatograms
  
  for mm = 1:Ninteractions
    
    compare_multiplier = 1;
    if mm <= Ndifferentcomparisons && ii == 1
      compare_multiplier = 0.5;
    end
    
    % "A" protein
    cc = cc+1;
    for jj = 1:user.Nreplicate
      kk = cc+(jj-1)*Nproteins;
      Proteins{ii}{kk} = ['A' num2str(mm)];
      replicate{ii}(kk) = jj;
      
      Chromatograms{ii}(kk,:) = chrom(mm,:) + rand(size(chrom(mm,:)))*max(chrom(mm,:))*.1;
      Chromatograms{ii}(kk,:) = Chromatograms{ii}(kk,:) * compare_multiplier;
    end
    
    % "B" protein
    cc = cc+1;
    for jj = 1:user.Nreplicate
      kk = cc+(jj-1)*Nproteins;
      Proteins{ii}{kk} = ['B' num2str(mm)];
      replicate{ii}(kk) = jj;
      
      Chromatograms{ii}(kk,:) = chrom(mm,:) + rand(size(chrom(mm,:)))*max(chrom(mm,:))*.1;
      Chromatograms{ii}(kk,:) = Chromatograms{ii}(kk,:) * compare_multiplier;
    end
  end
  
  % Fill the remaining proteins, "Z" proteins
  for nn = cc+1:Nproteins
    for jj = 1:user.Nreplicate
      kk = nn+(jj-1)*Nproteins;
      Proteins{ii}{kk} = ['Z' num2str(ii)];
      replicate{ii}(kk) = jj;
    end
  end
  
end



%% Dirty up the chromatograms

for ii = 1:length(user.silacratios)
  for cc = 1:size(Chromatograms{ii},1)
    
    % add up to 15% nans
    Nnan = floor(rand * user.Nfraction * 0.15);
    I = randsample(user.Nfraction,Nnan);
    Chromatograms{ii}(I) = nan;
    
  end
end



%% Comparison: change some chromatograms in channel 1

ii = 1; % channel

cc = 0; % chromatogram counter
for mm = 1:Ninteractions
  
  compare_multiplier = 1;
  if mm <= Ndifferentcomparisons
    compare_multiplier = 0.5;
  end
  
  % "A" protein
  cc = cc+1;
  for jj = 1:user.Nreplicate
    kk = cc+(jj-1)*Nproteins;
    Chromatograms{ii}(kk,:) = Chromatograms{ii}(kk,:) * compare_multiplier;
  end
  
  % "B" protein
  cc = cc+1;
  for jj = 1:user.Nreplicate
    kk = cc+(jj-1)*Nproteins;
    Chromatograms{ii}(kk,:) = Chromatograms{ii}(kk,:) * compare_multiplier;
  end
  
end



%% Quick visualization

figure
subplot(2,1,1)
imagesc(Chromatograms{1})
subplot(2,1,2)
imagesc(Chromatograms{2})
pause(.001)



%% Write fake data

% Chromatogram file(s)
for jj = 1:length(user.MQfiles)
  chromfile = user.MQfiles{jj};
  chromid = fopen(chromfile,'wt');
  % Write header
  fprintf(chromid,'%s,%s, ', 'Major protein group', 'Replicate');
  for ii = 1:user.Nfraction
    s = ['Ratio M/L ' num2str(ii)];
    fprintf(chromid,'%s, ', s);
  end
  fprintf(chromid,'\n');
  for ii = 1:size(Chromatograms{jj},1)
    fprintf(chromid,'%s, %6.4f,', Proteins{jj}{ii}, replicate{jj}(ii));
    fprintf(chromid,'%6.4g,',Chromatograms{jj}(ii,:)); %Chromatogram information
    fprintf(chromid,'\n');
  end
  fclose(chromid);
end

% Write 1/4 of the interactions in Corum pairwise file
corumfile = user.corumpairwisefile;
corumfile = fopen(corumfile,'wt');
for ii = 1:round(Ninteractions)
  sA = ['A' num2str(ii)];
  sB = ['B' num2str(ii)];
  fprintf(corumfile,'%s,%s, \n', sA, sB);
end
% Write 100 junk/filler interactions
 symbols = ['a':'z' 'A':'Z' '0':'9'];
for ii = 1:100
  s1 = randsample(symbols,8);
  s2 = randsample(symbols,8);
  fprintf(corumfile,'%s,%s, \n', s1, s2);
end
fclose(corumfile);

% Chromatogram file(s)
mpgfile = user.majorproteingroupsfile;
mpgid = fopen(mpgfile,'wt');
% Write header
fprintf(mpgid,'%s,\n', 'Majority protein IDs');
for ii = 1:Nproteins
  fprintf(mpgid,'%s,\n', Proteins{1}{ii});
end
fclose(mpgid);


