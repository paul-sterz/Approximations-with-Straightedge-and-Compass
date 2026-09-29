%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CASE COMPASS AND RULER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Testing only compass run

mainOnlyCompass(7, 6);

%% Testing Constructions for sqrt(pi)
clc,clearvars, close all;
load('FilePath')

[~,bestIdx] = min(errors);
data = constructions{bestIdx};
idxA = find(ismember(data.P, data.pointA, 'rows'));
idxB = find(ismember(data.P, data.pointB, 'rows'));

visualizeConstructionFinal(data.P, data.C, idxA, idxB, 1)


%% Testing Constructions for cube root of 2

clc,clearvars, close all;
load('FilePath')

[~,bestIdx] = min(errors);
data = constructions{bestIdx};
idxA = find(ismember(data.P, data.pointA, 'rows'));
idxB = find(ismember(data.P, data.pointB, 'rows'));

visualizeConstructionFinal(data.P, data.C, idxA, idxB, 2)

%% Testing Constructions for heptagon

clc,clearvars, close all;
load('FilePath')


[~,bestIdx] = min(errors);
data = constructions{bestIdx};
idxA = find(ismember(data.P, data.pointA, 'rows'));
idxB = find(ismember(data.P, data.pointB, 'rows'));

visualizeConstructionFinal(data.P, data.C, idxA, idxB, 3)

%% Evaluating only compass run

load('/Users/paulsterz/Documents/MATLAB/Seminar/8_Step_OnlyCompass/Branch 1/best_branch1_sqrtpi_2026_06_07_10_36_56.mat')

results  = evaluateTop50Symbolic(constructions,1);
solfilename = "exactComp_branch5_sqrt(pi).mat";
solutionfolder = fullfile(pwd,"solutions");
solfilepath = fullfile(solutionfolder, solfilename);    
save(solfilepath,"results");

data = results(1);
idxA = find(ismember(data.P, data.pointA, 'rows'));
idxB = find(ismember(data.P, data.pointB, 'rows'));

visualizeConstructionFinal(double(vpa(data.P,25)), data.C, idxA, idxB, 1)
disp("Visualization took: " + toc);

%% Last Test
load('/Users/paulsterz/Documents/MATLAB/Seminar/8_Step_OnlyCompass/Branch 6/best_branch6_sqrtpi_2026_06_06_18_23_28.mat')
tic
[data,V] = symbolic_construction(constructions{1});
idxA = find(ismember(data.P, data.pointA, 'rows'));
idxB = find(ismember(data.P, data.pointB, 'rows'));

visualizeConstructionFinal(double(vpa(data.P,25)), data.C, idxA, idxB, 1);
disp(toc);


tic
[data,V] = symbolic_constructionTEST(constructions{1});
idxA = find(ismember(data.P, data.pointA, 'rows'));
idxB = find(ismember(data.P, data.pointB, 'rows'));

visualizeConstructionFinal(vpa(data.P,25), data.C, idxA, idxB, 1);
disp(toc);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CASE COMPASS AND RULER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Testing compas & ruler run

    mainCompassRuler(6,3);


%% Testing constructions compass & ruler for 6 Steps

clc,clearvars close all;
%Branch 1: 
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 1/best_branch1_sqrtpi_2026_06_11_12_13_52.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 1/best_branch1_cuberoot2_2026_06_11_12_13_52.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 1/best_branch1_heptagon_2026_06_11_12_13_52.mat')
%Branch 2:
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 2/best_branch2_cuberoot2_2026_06_11_12_14_25.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 2/best_branch2_sqrtpi_2026_06_11_12_14_25.mat')
%Branch 3:
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 3/best_branch3_cuberoot2_2026_06_14_13_58_55.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 3/best_branch3_sqrtpi_2026_06_14_13_58_55.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 3/best_branch3_heptagon_2026_06_14_13_58_55.mat')
%Branch 4: 
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 4/best_branch4_cuberoot2_2026_06_11_12_16_57.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 4/best_branch4_sqrtpi_2026_06_11_12_16_57.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 4/best_branch4_heptagon_2026_06_11_12_16_57.mat')
%Branch 5: 
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 5/best_branch5_cuberoot2_2026_06_11_12_17_56.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 5/best_branch5_sqrtpi_2026_06_11_12_17_56.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 5/best_branch5_heptagon_2026_06_11_12_17_56.mat')
%Branch 6: 
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 6/best_branch6_cuberoot2_2026_06_11_12_18_07.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 6/best_branch6_sqrtpi_2026_06_11_12_18_07.mat')
load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 6/best_branch6_heptagon_2026_06_11_12_18_07.mat')
%Branch 7:
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 7/best_branch7_cuberoot2_2026_06_11_12_19_33.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 7/best_branch7_sqrtpi_2026_06_11_12_19_33.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 7/best_branch7_heptagon_2026_06_11_12_19_33.mat')
%Branch 8: 
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 8/best_branch8_cuberoot2_2026_06_11_12_19_56.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 8/best_branch8_sqrtpi_2026_06_11_12_19_56.mat')
%load('/Users/paulsterz/Documents/MATLAB/Seminar/6_Step_CompassRuler/Branch 8/best_branch8_heptagon_2026_06_11_12_19_56.mat')

[~,bestIdx] = min(errors);
data = constructions{bestIdx};
idxA = find(ismember(data.P, data.pointA, 'rows'));
idxB = find(ismember(data.P, data.pointB, 'rows'));

visualizeConstructionCompassRuler(data.P, data.C, data.LNormalForm, idxA, idxB, 3);

%% Testing randomized run

parDeepRun2(100);
