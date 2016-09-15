function QD

%% qmr
Tq = '/media/HDPC-UT/qMRI_data/Tamagawa';
subs = {'Ctl-HH-2016-08-15',  'Ctl-SO-2016-08-11','LHON-SS-2016-08-11',...
    'Ctl-RT-2016-08-11',  'LHON-GK-2016-08-21',  'RP-YT-2016-08-11'};

%% dmr

Td = '/media/HDPC-UT/dMRI_data';
subs2 = {'Ctl-HH-20150531','Ctl-SO-20150426','LHON6-SS-20131206-DWI',...
    'Ctl-RT-20150426','LHON4-GK-dMRI-2014-11-25','RP8-YT-2014-03-14-dMRI-Anatomy'};

%% Run AFQ

% Make directory structure for each subject
for ii = 1:length(subs2)
    sub_dirs{ii} = fullfile(Td, subs2{ii},'dwi_1st');
end

% Subject grouping is a little bit funny because afq only takes two groups
% but we have 3. For now we will divide it up this way but we can do more
% later
Pa  = ones(1,length(subs2));
Pa([1,2,4]) =0;

% Now create and afq structure
afq = AFQ_Create('sub_dirs', sub_dirs, 'sub_group', Pa, 'clip2rois', 1);

% afq.params.cutoff=[5 95];
afq.params.outdir = ...
    fullfile('/home/ganka/git/Qmr_Tama');

%% set qmr maps

volmaps ={'SIR_alligned_map.nii.gz','TV_alligned_map.nii.gz','PD_alligned.nii.gz','T1_alligned_map_lin.nii.gz','VIP_alligned_map.nii.gz','t1w_alligned_acpc.nii.gz'};
% volmaps ={'SIR_alligned_map.nii.gz','TV_alligned_map.nii.gz','PD_alligned.nii.gz','T1_alligned_map_lin.nii.gz','VIP_alligned_map.nii.gz','t1w_alligned_acpc.nii.gz'};

for jj = 1:length(volmaps)
    for ii = 1:length(sub_dirs)
        t1Path{ii} = fullfile(Tq,subs{ii}, volmaps{jj});
    end
    
    afq = AFQ_set(afq, 'images', t1Path);
end
%% Run AFQ on these subjects
afq = AFQ_run(sub_dirs, Pa, afq);

%% Add callosal fibers
afq = AFQ_SegmentCallosum(afq);

%% Add new fibers

fgName = 'LOT_MD32';
roi1Name = '85_Optic-Chiasm';
roi2Name = 'Lt-LGN4';
cleanFibers =0;
computeVals =1;
afq.params.clip2rois = 0;
afq = AFQ_AddNewFiberGroup(afq, fgName, roi1Name, roi2Name, cleanFibers);

fgName = 'ROT_MD32';
roi1Name = '85_Optic-Chiasm';
roi2Name = 'Rt-LGN4';
cleanFibers =0;
computeVals =1;
afq.params.clip2rois = 0;
afq = AFQ_AddNewFiberGroup(afq, fgName, roi1Name, roi2Name, cleanFibers);

%%
outname = fullfile(AFQ_get(afq,'outdir'),['afq_' date]);
save(outname,'afq');

