function FLIRT

% The simplest usage of flirt is to register two images together as:
%
%
%
%

%% first, Should be in the subject directory 


invol   = fullfile(pwd, 't1w_acpc.nii.gz');
% invol   = fullfile(pwd, 'T1_map_lin.nii.gz');
refvol  = fullfile(pwd, 't1.nii.gz');
outvol  = fullfile(pwd, 't1_alligned.nii.gz');

cmd = sprintf('!flirt -in %s -ref %s -out %s -omat invol2refvol.mat -dof 6',invol,refvol,outvol);

eval(cmd)
%%
newvols = {'SIR_map.nii.gz','TV_map.nii.gz','PD.nii.gz','T1_map_lin.nii.gz','VIP_map.nii.gz','t1w_acpc.nii.gz'};
newoutvols ={'SIR_alligned_map.nii.gz','TV_alligned_map.nii.gz','PD_alligned.nii.gz','T1_alligned_map_lin.nii.gz','VIP_alligned_map.nii.gz','t1w_alligned_acpc.nii.gz'};

refvol  = fullfile(pwd, 't1.nii.gz');

% mkdir 'alligned'

for ii = 1:length(newvols)
    invol   = fullfile(pwd, newvols{ii});
    outvol  = fullfile(pwd, newoutvols{ii});
    
    cmd2 = sprintf('!flirt -in %s -ref %s -out %s -init invol2refvol.mat -applyxfm',invol,refvol,outvol);
    eval(cmd2)
end
