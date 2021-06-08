function R = mergeK2Table(tb_ls)
R = tb_ls{1};
n = length(tb_ls);
for i=2:n
    Rs = R.sample;
    T = tb_ls{i};
    Ts = T.sample;
    if length(R.sample)~=length(T.sample)
        disp('Error!!!!!!!!');
        break
    end
    Rtb = R.tab;
    Ttb = T.tab;
    Rid = R.taxid;
    Tid = T.taxid;
    Rtax = R.taxname;
    Ttax = T.taxname;
    
    id0 = AlignID(Rs,Ts);
    Ttb_sorted = Ttb(:,id0);

    

    set2 = setdiff(Tid,Rid);
    

    id1 = AlignID(Rid,Tid);
    tab1 = Rtb;
    tab1(id1~=0,:) = tab1(id1~=0,:)+Ttb_sorted(id1(id1~=0),:);
    
    id2 = AlignID(set2,Tid);
    tab_set2 = Ttb_sorted(id2,:);
    
    taxid = [Rid(:);set2(:)];
    taxname = [Rtax;Ttax(id2)];
    tab = [tab1;tab_set2];

    check = sum(abs(sum(tab,1)-sum(Rtb,1)-sum(Ttb_sorted,1)));
    if check~=0
        disp('Error!!!!!!!!');
    end
    
    F.taxid = taxid;
    F.taxname = taxname;
    F.tab = tab;
    F.sample = Rs;
    R = F;
end
end