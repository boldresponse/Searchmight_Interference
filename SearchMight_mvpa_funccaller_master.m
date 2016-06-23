%Ed O'Neil
%Main MVPA script for the INTERFERENCE_MVPA project
%WedJ22
clear all ; close all
%Pt1 or Pt2
%If Pt 1, what phase?
%classification?

%note meta.mat (searchlight positions) have been preassigned to meta.mat in
%order to reduce waiting time

addpath('/psyhome/u3/oneiledw/matlabtoolboxes/SearchmightToolbox.Linux_x86_64.0.2.5');
setupPathsSearchmightToolbox
% define the subject list.  Just use numbers
s =  {1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18};
space={'standard'}; %indicate 'native' or 'standard';
run_sel={'noresp_runs.mat'};
scans={'study'}; %indicate 'study or 'test''_TestCollapse_tstat9_6mm_bin_27_standard_mask.nii''_sumLocTest196_6mm_Holdstocksub2_PRC_bin_standard_mask.nii';'_TestCollapse_tstat9_6mm_bin_196_standard_mask.nii';;'_TestCollapse_tstat9_6mm_196binxHoldstocksub2_PRC_bin_standard_mask.nii''_Loctstat5_6mm_bin_196_standard_mask.nii';;'_TestCollapse_tstat9_6mm_27binxVVS_bin_standard_mask.nii';'_TestCollapse_tstat9_6mm_27binxHOAtlas_LatOcc_0perc2mm_bin_standard_mask.nii';'_TestCollapse_tstat9_6mm_27binxHOAtlas_TempOccFus_0per2mm_bin_standard_mask.nii';
condnames={'f','c'};
regs_sel={'315_s';'315_t';'315_perc';'315_niint';'315_intper';'315_WWM';'315_RWM'};
roiname={'MNI152_T1_2mm_brain_mask.nii'};


if isequal(scans{1},'study')==1;
    startrun=3;
elseif isequal(scans{1},'test')==1
    startrun=8;
end

classifiertype={ 'gnb_searchmight'}


parforcounter=1;
for xxxx=1:length(roiname);
    for xxxxx=1:length(classifiertype);
        for xxx=1:length(regs_sel);
            for xx=1:length(s);
            subnum=num2str(s{xx},'% 04.f');
                           
                parforloopdata{parforcounter,1}=s{xx};
               
                parforloopdata{parforcounter,2}=subnum;
                parforloopdata{parforcounter,3}=space;
                parforloopdata{parforcounter,4}=run_sel;
                parforloopdata{parforcounter,5}=scans;
                parforloopdata{parforcounter,6}=condnames;
                parforloopdata{parforcounter,7}=regs_sel(xxx);
                parforloopdata{parforcounter,8}=startrun;
                parforloopdata{parforcounter,9}=roiname(xxxx);
                parforloopdata{parforcounter,10}=classifiertype(xxxxx);
                parforcounter=parforcounter+1;
            end
        end
    end
end
net.trainParam.showWindow = false;
parforlist=1:length(parforloopdata);
for jj=64:126
  %  poolobj = gcp;
%addAttachedFiles(poolobj,{'repmat.mexa64','searchmightGNB.mexa64'})
    [ am, pm, extraReturns, volume,meta,roinoext ]=SearchMight_mvpa_func_master(parforloopdata{jj,1},parforloopdata{jj,1},parforloopdata{jj,3},parforloopdata{jj,4},parforloopdata{jj,5},parforloopdata{jj,6},parforloopdata{jj,7}{1},parforloopdata{jj,8},parforloopdata{jj,9}{1},parforloopdata{jj,10}{1});
    
    Searchresults={am pm extraReturns volume meta};
    savefile=sprintf('S%d_reg%s_roi%s_class_%s',parforloopdata{jj,1},parforloopdata{jj,7}{1},roinoext,parforloopdata{jj,10}{1})
    save(savefile,'Searchresults');
    
end

%             %Add prepare data for subject structure
%              for zz=1:length(parforloopdata)
%  srls=Searchresults{zz}{1}
%  acc(zz,:)=srls
%  end
%  avgacc=mean(acc,1)
%
% %summarize
% volume = repmat(NaN,[91 109 91]);
%
% volume(meta.indicesIn3D) = avgacc;
%
% dummy=load_untouch_nii('standard_mask.nii')
% dummy.img=volume
% eval(sprintf('save_untouch_nii(dummy,''2waygnb%s_%s'')',parforloopdata{jj,7}{1},parforloopdata{jj,9}{1}))
