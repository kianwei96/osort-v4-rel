%
%plots figures that show the result of clustering
%
function produceFigures(handles, outputpath,outputFormat, thresholdMethod)
paperPosition=[0 0 16 12];

% JD: turn off warning about columns of X linearly dependent which pops up
% in the computeLratio function
warning('off','stats:pca:ColRankDefX'); 

figure(123);
set(gcf,'visible','off');
close(gcf);

colors = defineClusterColors;

rawWaveforms = handles.newSpikesNegative;
 

if isfield(handles,'scalingFactor')
    if ~isnan(handles.scalingFactor)
        rawWaveforms = rawWaveforms .* handles.scalingFactor*1e6; %convert to uV
    end
end

[outputEnding,outputOption] = determineFigExportFormat( outputFormat );

%order of clusters
%first clusters are the biggest clusters
clusters=handles.useNegative;
clusters = flipud( clusters );

%if there are more than we have color definitions,crop.
if length(clusters)>length(colors)
    clusters=clusters(1:length(colors));
end

nrClusters=length(clusters);

%make dir to store the directory
if exist(outputpath)==0
	mkdir(outputpath);
end

for i=1:length(clusters)
    cluNr=clusters(i);
    if sum(handles.assignedClusterNegative == cluNr)==0,
        continue;
    end
    disp(['Figure for cluster nr ' num2str(cluNr)]);
    
    figure(cluNr);
    set(gcf,'visible','off');
    
    %try
        
    plotSingleCluster(rawWaveforms, handles.newSpikesTimestampsNegative, handles.assignedClusterNegative, [handles.label '(-)'],  cluNr, colors{i},handles.includeRange); 
    
    %end
    scaleFigure;
    set(gcf,'PaperUnits','inches','PaperPosition',paperPosition)
    
    fNameOut = [outputpath handles.prefix handles.from '_CL_' num2str(cluNr) '_THM_' num2str(thresholdMethod) outputEnding  ];
    disp(['Writing:' fNameOut]);

    print(gcf,outputOption, fNameOut);
    
    if ~handles.displayFigures
        close(gcf);
    end
end

disp(['figure sorting result all']);

figure(888);
set(gcf,'visible','off');
close(gcf);   % make sure its closed if it already exists
figure(888)
set(gcf,'visible','off');

plotSortingResultRaw(rawWaveforms, [], handles.assignedClusterNegative, [], clusters, [], [handles.label '(-)'], colors )    
scaleFigure;
set(gcf,'PaperUnits','inches','PaperPosition',paperPosition)

fNameOut = [outputpath handles.prefix handles.from '_CL_ALL' '_THM_' num2str(thresholdMethod) outputEnding];
disp(['Writing:' fNameOut]);

print(gcf,outputOption, fNameOut);

if ~handles.displayFigures
    close(gcf);
end

%disp(['figure sorting result noise free spikes']);
%figure(889)
%plotSortingResultRaw(handles.allSpikesCorrFree, [], handles.assignedClusterNegative, [], handles.useNegative, [], [handles.label '(-)'] )        
%scaleFigure;
%set(gcf,'PaperUnits','inches','PaperPosition',paperPosition)
%print(gcf,outputOption,[outputpath handles.prefix handles.from '_CL_ALL_noiseFree' outputEnding  ]);
%close(gcf);

if length(clusters)==0
    return;
end

%--
%---- PCA figure      
figure(123);
set(gcf,'visible','off');
[pc,score,latent,tsquare] = pca(rawWaveforms);

assigned=handles.assignedClusterNegative;

plotInds=[];
allInds=[];
for i=1:length(clusters)
    cluNr=clusters(i);
    plotInds{i} = find( assigned == cluNr );
    allInds=[allInds plotInds{i}];
end
noiseInds=setdiff(1:length(assigned),allInds);

plot( score(noiseInds,1), score(noiseInds,2), '.', 'color', [0.5 0.5 0.5]);
hold on
for i=1:nrClusters
    plot( score(plotInds{i},1), score(plotInds{i},2), '.', 'color', colors{i});
end
hold off

%focus on the data,not the noise; check if first argument<second to avoid
%weird xlim/ylim errors if not ordered (negative numbers)
xlims=[ 0.9*min(score(allInds,1)) 1.1*max(score(allInds,1))];
if xlims(1)<xlims(2)
    xlim(xlims);
end
ylims=[ 0.9*min(score(allInds,2)) 1.1*max(score(allInds,2))];
if ylims(1)<ylims(2)
    ylim(ylims);
end
    

stdWaveforms=mean(std(handles.allSpikesCorrFree));
title(['PC1/PC2, whitened std=' num2str(stdWaveforms)]);
scaleFigure;
set(gcf,'PaperUnits','inches','PaperPosition',paperPosition)
print(gcf, outputOption, [outputpath handles.prefix handles.from '_PCAALL_THM_' num2str(thresholdMethod) outputEnding ]);

if ~handles.displayFigures
    close(gcf);
end



