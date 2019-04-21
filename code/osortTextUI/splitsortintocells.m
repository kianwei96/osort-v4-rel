function [hmmsort] = splitsortintocells(sortfile)

h = load(sortfile);
sortfilepath = pwd;
rplhighpasspath = sortfilepath(1:strfind(sortfilepath,'/oSort')-1);
% [rplhighpassfile,rplhighpasspath,~] = uigetfile('rplhighpass*.mat');
cd(rplhighpasspath);
rplhighpass = load('rplhighpass.mat');
rplhighpass = rplhighpass.rh.data;

% Initialise variables from oSort file
useNegative = h.useNegativePostMerge;
assignedNegative = h.assignedNegativePostMerge;
allSpikeInds = h.allSpikeInds;
newSpikesNegative = h.newSpikesNegative;

% Initialise hmmsort
hmmsort.cinv = 0.0220;
hmmsort.ll = -8.0360e+07;
hmmsort.samplingRate = 30000;
useNegative = reshape(useNegative,length(useNegative),1);
hmmsort.mlseq = zeros(size(useNegative,1),size(rplhighpass.analogTime,1));
hmmsort.spikeForms = NaN(size(useNegative,1),1,45);

for ii = 1:size(useNegative,1)
    
    clust = useNegative(ii);
    spikesforclust = assignedNegative == clust;
    
    timestampInds = allSpikeInds(spikesforclust);
    timestamps = rplhighpass.analogTime(timestampInds);
    
    spikeform = mean(newSpikesNegative(spikesforclust',:),1);
    % downsample spike waveform from 256 points back to 64 (artifact of
    % upsampling in OSort
    spikeform = downsample(spikeform,4,2); % downsamples with a phase offset to capture 95th point which is where peak is realigned to 
    spikeform = spikeform(1:45); % now peak is at point 24 of 45
%     spikeform = [spikeform(1),spikeform(1),spikeform(1:43)]; % translates the peak which is now at point 24 of 64, to point 26 of 64, and then truncates it at 45
    
%     % save output
%     mkdir(horzcat('cell',num2str(clust)));
%     cd(horzcat('cell',num2str(clust)));
%     save('spiketrain.mat','timestamps','spikeform');
%     cd(homedir);
    
    % save hmmsort
    hmmsort.mlseq(ii,timestampInds) = 26;
    hmmsort.spikeForms(ii,1,:) = spikeform;
    
    % Store hmmsort
    cd(rplhighpasspath);
    filenameInd1 = strfind(sortfilepath,'/detect');
    findnameInd2 = strfind(sortfilepath,'/sort');
    filename = sortfilepath(filenameInd1+1:findnameInd2-1);
    save(['osort' '_' filename '.mat'],'-v7.3','-struct','hmmsort','cinv','ll','samplingRate','mlseq','spikeForms');
end