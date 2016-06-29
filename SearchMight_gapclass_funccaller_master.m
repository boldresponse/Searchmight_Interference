%Jonathan
%Main MVPA script for the gapclass project; creates inputs for the masterscript and loops them

clear all; close all
addpath('/Users/leelab/Documents/MATLAB/SearchmightToolbox.Darwin_i386.0.2.5');
setupPathsSearchmightToolbox

% define the subject list.  Just use numbers
s={1 2 3 4};
space={'standard'} %indicate 'native' or 'standard'
run_sel={'gap_runs.mat'};
condnames={'E1','E2','E3','E4','catch'};
regs_sel={'scene_7regs','gap_7regs','individual_7regs'};
roiname={'r_hippMNI2mm50thr.nii','l_hippMNI2mm50thr.nii','post_r_hippMNI2mm50thr','ant_r_hippMNI2mm50thr','post_l_hippMNI2mm50thr','ant_l_hippMNI2mm50thr','post_para_MNI2mm50thr','MNI152_T1_2mm_brain_mask.nii'}; %%note: wholebrain takes significantly longer than rest
classifiertype={'gnb_searchmight'}

startrun=1;
endrun=7;

parforcounter=1
for xxxx=1:length(roiname);
    for xxxxx=1:length(classifiertype);
        for xxx=1:length(regs_sel);
            for xx=1:length(s);
                parforloopdata{parforcounter,1}=s{xx};
                parforloopdata{parforcounter,2}=space;
                parforloopdata{parforcounter,3}=run_sel;
                parforloopdata{parforcounter,4}=condnames;
                parforloopdata{parforcounter,5}=regs_sel(xxx);
                parforloopdata{parforcounter,6}=startrun;
                parforloopdata{parforcounter,7}=endrun;
                parforloopdata{parforcounter,8}=roiname(xxxx);
                parforloopdata{parforcounter,9}=classifiertype(xxxxx)
                parforcounter=parforcounter+1;
            end
        end
    end
end

net.trainParam.showWindow = false;

for jj=1:length(parforloopdata);
    
    %%don't change any names in the []; these are set by the toolbox
    %%am = accuracy map, pm = p-value map
    [am, pm, extraReturns, volume, meta, roinoext]=SearchMight_gapclass_func_master(parforloopdata{jj,1},parforloopdata{jj,1},parforloopdata{jj,3},parforloopdata{jj,4},parforloopdata{jj,5},parforloopdata{jj,6},parforloopdata{jj,7},parforloopdata{jj,8}{1},parforloopdata{jj,9}{1});
    
    Searchresults={am pm extraReturns volume meta};
    savefile=sprintf('00%d_reg%s_roi%s_class%s_gnbsearchmight',parforloopdata{jj,1},parforloopdata{jj,5}{1},parforloopdata{jj,8}{1},parforloopdata{jj,9}{1})
    save(savefile,'Searchresults');
    
end

%this script uses info in the parforloopdata, and you need to reference it
%to make sense of what is going on here.based on output of loops in /Volumes/EDMACPRO_TIMEMACHINE/IRIS/SearchMight_mvpa_funccaller_master.m
for jj=1:size(parforloopdata,1);
    
    %   [ am, pm, extraReturns, volume,meta,roinoext ]=SearchMight_mvpa_func_master(parforloopdata{jj,1},parforloopdata{jj,1},parforloopdata{jj,3},parforloopdata{jj,4},parforloopdata{jj,5},parforloopdata{jj,6},parforloopdata{jj,7}{1},parforloopdata{jj,8},parforloopdata{jj,9}{1},parforloopdata{jj,10}{1})
    [ext,roinoext]=fileparts(parforloopdata{jj,7}{1})
    openfile=sprintf('00%d_reg%s_roi%s_class%s_gnbsearchmight.mat',parforloopdata{jj,1},parforloopdata{jj,5}{1},roinoext,parforloopdata{jj,8}{1})
    filevolume=open(openfile)
    filevolume.Searchresults{4}(filevolume.Searchresults{5}.indicesIn3D) = filevolume.Searchresults{2};
    mastervol(jj,:,:,:)=filevolume.Searchresults{4};
end
%Load up empty mask

dummy=load_nii('Emptyvol.nii')
dummy.img=dummy.img./0
%Average subjects over time (be sure to pull values of the same comparison)

avggnb(:,:,:)=mean(mastervol,1);
gnb1(:,:,:)=squeeze(mastervol(1,:,:,:));
gnb2(:,:,:)=squeeze(mastervol(2,:,:,:));
gnb3(:,:,:)=squeeze(mastervol(3,:,:,:));
gnb4(:,:,:)=squeeze(mastervol(4,:,:,:));

%populate these values into your mask
dummyavg=dummy
dummyavg.img=double(dummy.img)
dummyavg.img=double(dummy.img)

dummyavg.img=1-avggnb

dummy1=dummy
dummy1.img=double(dummy.img)

dummy1.img=1-gnb1

dummy2=dummy
dummy2.img=double(dummy.img)

dummy2.img=1-gnb2

dummy3=dummy
dummy3.img=double(dummy.img)

dummy3.img=1-gnb3

dummy4=dummy
dummy4.img=double(dummy.img)

dummy4.img=1-gnb4

%Save it off
save_nii(dummyavg,'4way_gnbavg_p_perm.nii')
save_nii(dummy1,'4way_gnb1_p_perm.nii')
save_nii(dummy2,'4way_gnb2_p_perm.nii')
save_nii(dummy3,'4way_gnb3_p_perm.nii')
save_nii(dummy4,'4way_gnb4_p_perm.nii')

%fslview usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz /Users/leelab/Documents/HR_gapclass/york/tstat_standards_gnb4_p_perm.nii -l Blue-Lightblue -b 95,100
