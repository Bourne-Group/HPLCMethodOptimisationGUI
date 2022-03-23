%Startup script for TS-EMO Algorithm

disp ('executing TS-EMO startup script...')
mydir = fileparts (mfilename ("C:\Users\cmtmd\OneDrive - University of Leeds\PhD project infomation\Data\Code\MATLAB\HPLC files and code\HPLC GUI optimise versions\V1.3\TS-EMO HPLC optimise")); % where am I located
addpath (mydir)
folders = {'Test_functions', 'NGPM_v1.4', 'Mex_files/hypervolume', 'Mex_files/invchol', 'Mex_files/pareto front', 'Direct'}; 
for d = folders, addpath (fullfile (mydir, d{1})), end
