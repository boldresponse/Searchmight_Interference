%Jonathan
%Main MVPA script for the gapclass project; creates inputs for the masterscript and loops them

clear all; close all

% define the subject list.  Just use numbers
s={1 2 3 4};
space={'standard'} %indicate 'native' or 'standard'
run_sel={'gap_runs.mat'};
condnames={'E1','E2','E3','E4','catch'};
regs_sel={'scene_7regs' 'gap_7regs' 'individual_7regs'};
roiname={'r_hippMNI2mm50thr.nii' 'l_hippMNI2mm50thr.nii' 'post_r_hippMNI2mm50thr','ant_r_hippMNI2mm50thr','post_l_hippMNI2mm50thr','ant_l_hippMNI2mm50thr','post_para_MNI2mm50thr'};
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
    
    [ am, pm, extraReturns, volume,meta,roinoext ]=SearchMight_gapclass_func_master(parforloopdata{jj,1},parforloopdata{jj,1},parforloopdata{jj,3},parforloopdata{jj,4},parforloopdata{jj,5},parforloopdata{jj,6},parforloopdata{jj,7},parforloopdata{jj,8}{1},parforloopdata{jj,9}{1});
    
    Searchresults={am pm extraReturns volume meta};
    savefile=sprintf('00%d_reg%s_roi%s_class%s_gnbsearchmight',parforloopdata{jj,1},parforloopdata{jj,5}{1},parforloopdata{jj,8}{1},parforloopdata{jj,9}{1})
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
