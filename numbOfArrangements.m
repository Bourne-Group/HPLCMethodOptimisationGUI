% Given a number, this function will find all the combinations of pairs
% from 1 to the number stated. e.g. if you pass 4 as the argument, it will
% return [1,2;1,3,1,4;2,3;2,4;3,4] where the first column represents peak 1
% and the second represents peak 2. Repeats e.g. 1,2 and 2,1 are removed as
% these will give the same resoultion values in the spectra.

function arrange = numbOfArrangements(x)
    
    a=fliplr(fullfact([x x]));
    a(~diff(a')',:)=[];
    arrange = unique(sort(a,2),"rows");

end