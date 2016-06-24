function [ am, pm, extraReturns, volume,meta,roinoext ] = Searchlight_mvpa_func_master(s,space,run_sel,condnames,regs_sel,startrun,endrun,roiname,classtype)
confmatx={};
subjectCode = num2str(s);%init subj
roi={'01'}%, '02', '03', '04','05' ,'06'}%, '07', '08', '09', '10', '14', '15' ,'16'}

[ext,roinoext]=fileparts(roiname)

% start by creating an empty subj structure
subj = init_subj('gapclass','subj');

%%% create the mask that will be used when loading in the data
subj = load_spm_mask(subj,roinoext,roiname);

% now, read and set up the actual data. load_AFNI_pattern reads in the
% EPI data from a BRIK file, keeping only the voxels active in the
% mask (see above)
for i=startrun:endrun
    raw_filenames{i} = sprintf('/Users/leelab/Documents/HR_gapclass/york/tstat_standard/00%d_gap%d_tstat_allcond_standard.nii',s,i);
end
subj = load_spm_pattern(subj,'epi',roinoext,raw_filenames);

% initialize the regressors object in the subj structure, load in the
% contents from a file, set the contents into the object and add a
% cell array of condnames to the object for future reference
subj = init_object(subj,'regressors','conds');
eval(sprintf('load(''/Users/leelab/Documents/HR_gapclass/york/tstat_standard/%s'')',regs_sel));
subj = set_mat(subj,'regressors','conds',regs);
subj = set_objfield(subj,'regressors','conds','condnames',condnames);

% store the names of the regressor conditions
% initialize the selectors object, then read in the contents
% for it from a file, and set them into the object
subj = init_object(subj,'selector','runs');
eval(sprintf('load(''/Users/leelab/Documents/HR_gapclass/york/tstat_standard/%s'')',run_sel{1}));



subj = set_mat(subj,'selector','runs',gap_runs);


%  condnames          1x8                   566  cell                
%  raw_filenames      1x10                  882  cell                
%  regs               8x1210              77440  double              
%  runs               1x1210               9680  double              
%  subj               1x1               7237645  struct    

% get data into a #TRs x #voxels matrix, and also mask

TRdata = subj.patterns{1}.mat';
[nTRs,nVoxels] = size(TRdata);

mask = subj.masks{1}.mat;
[dimx,dimy,dimz] = size(mask);

% create labels for each TR (column vectors)

TRlabels      = sum(regs .* repmat((1:3)',1,nTRs),1)'; %%REPMAT(1:number of conditions)
TRlabelsGroup = gap_runs';

%
% turn each block into an example, and convert labels
%%%%%%%%%%%%
%%%%%%%%%%%% THIS IS CODE TO AVERAGE ACTIVITY WITIN A BLOCK FOR
%%%%%%%%%%%% CLASSIFICATION, IT IS FROM THE DEMO SCRIPT
% % % binary mask for beginning and end of blocks (task or fixation)
% % TRmaskBlockBegins = ([1;diff(TRlabels)] ~= 0); 
% % TRmaskBlockEnds   = ([diff(TRlabels);1] ~= 0);
% % 
% % % average blocks (we will get rid of 0-blocks afterwards)
% % % (silly average of all images, without thinking of haemodynamic response)
% % % to convert them into examples (and create labels and group labels)
% % 
% % % figure out how many blocks and what TRs they begin and end at
% % nBlocks = sum(TRmaskBlockBegins);
% % blockBegins = find(TRmaskBlockBegins);
% % blockEnds   = find(TRmaskBlockEnds);
% % 
% % % create one example per block and corresponding labels
% % labels      = zeros(nBlocks,1); % condition
% % labelsGroup = zeros(nBlocks,1); % group (usually run)
% % examples    = zeros(nBlocks,nVoxels); % per-block examples
% % 
% % for ib = 1:nBlocks
% %   range = blockBegins(ib):blockEnds(ib);
% %   examples(ib,:)  = mean(TRdata(range,:),1);
% %   labels(ib)      = TRlabels(blockBegins(ib));
% %   labelsGroup(ib) = TRlabelsGroup(blockBegins(ib));
% % end
% % 
% % % nuke examples with label 0
labels=TRlabels;
labelsGroup=TRlabelsGroup;
examples=TRdata;
indicesToNuke = find(labels == 0);
 examples(indicesToNuke,:)  = [];
 labels(indicesToNuke)      = [];
 labelsGroup(indicesToNuke) = [];
% % 


% create a meta structure (see README.datapreparation.txt and demo.m for more details about this)
meta = createMetaFromMask(mask);

%
% run a fast classifier (see demo.m for more details about computeInformationMap)
%
classifier = classtype;


%classifier = 'gnb_pooled'; % fast GNB

[am,pm,extraReturns] = computeInformationMap(examples,labels,labelsGroup,classifier, ...
                                             'searchlight',meta.voxelsToNeighbours,meta.numberOfNeighbours,'testToUse','accuracyOneSided_permutation',1000,'storeLocalConfusionMatrices');

%
% quick plot of the results
%

clf; nrows = ceil(sqrt(dimz)); ncols = nrows;

volume = repmat(NaN,[dimx dimy dimz]);
% place accuracy map in a 3D volume, using the vectorized indices of the mask in meta
volume(meta.indicesIn3D) = pm;

% for iz = 1:dimz
%   subplot(nrows,ncols,iz);
%   imagesc(volume(:,:,iz)',[0 0.5]); axis square;
%   set(gca,'XTick',[]); set(gca,'YTick',[]);
%   if iz == 1; hc=title('accuracy map for mask'); set(hc,'FontSize',8); end
%   if iz == dimz; hc=colorbar('vert'); set(hc,'FontSize',8); end
% end



