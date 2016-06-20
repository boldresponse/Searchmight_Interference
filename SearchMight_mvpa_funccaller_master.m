%Ed O'Neil
%Main MVPA script for the INTERFERENCE_MVPA project
%test
clear all ; close all
%Pt1 or Pt2
%If Pt 1, what phase?
% define the subject list.  Just use numbers
s =  {2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18};
space={'standard'} %indicate 'native' or 'standard'
run_sel={'conflict_runs.mat'};
scans={'study'}; %indicate 'study or 'test'
condnames={'p','n','m'};
regs_sel={'3wayconflict_regs'}%'2way_13_regs', '2way_12_regs'};
roiname={'r_hippMNI2mm50thr.nii' 'l_hippMNI2mm50thr.nii'};

classifiertype={ 'gnb_searchmight'}



startrun=2;

parforcounter=1
for xxxx=1:length(roiname);
    for xxxxx=1:length(classifiertype)
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
                parforloopdata{parforcounter,10}=classifiertype(xxxxx)
                parforcounter=parforcounter+1;
            end
        end
    end
end
net.trainParam.showWindow = false;

for jj=1:length(parforloopdata);
    
    [ am, pm, extraReturns, volume,meta,roinoext ]=SearchMight_mvpa_func_master(parforloopdata{jj,1},parforloopdata{jj,1},parforloopdata{jj,3},parforloopdata{jj,4},parforloopdata{jj,5},parforloopdata{jj,6},parforloopdata{jj,7}{1},parforloopdata{jj,8},parforloopdata{jj,9}{1},parforloopdata{jj,10}{1})
    
    Searchresults={am pm extraReturns volume meta};
    savefile=sprintf('S%d_reg%s_roi%s_class_%sgnbsearchmight_3waypmperm',parforloopdata{jj,1},parforloopdata{jj,7}{1},roinoext,parforloopdata{jj,10}{1})
    save(savefile,'Searchresults')
    
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
