function [VV, FF] = CCsub(V, F, iter)  
    % Catmull_Clark subdivision  
    if ~exist('iter','var')  
        iter = 1;  
    end  
    VV = V;  
    FF = F;  
      
    for i = 1:iter
        
        nv = size(VV,1);  
        nf = size(FF,1);  
                 
        original = 1:nv;  
        boundary = [];  
        interior = original(~ismember(original, boundary)); 
          
        no = length(original);   
        ni = length(interior);  
  
        %% Sv  
        Etmp = sort([FF(:,1) FF(:,2);FF(:,2) FF(:,3);FF(:,3) FF(:,4);FF(:,4) FF(:,1)],2);  
        [E, ~, idx] = unique(Etmp, 'rows');  
          
        Aeven = sparse([E(:,1) E(:,2)], [E(:,2) E(:,1)], 1, no, no);  
        Aodd = sparse([FF(:,1) FF(:,2)], [FF(:,3) FF(:,4)], 1, no, no);  
        Aodd = Aodd + Aodd';  
          
        val_even = sum(Aeven,2);  
        beta = 3./(2*val_even);  
          
        val_odd = sum(Aodd,2);  
        gamma = 1./(4*val_odd);  
          
        alpha = 1 - beta - gamma;  
          
        Sv = sparse(no,no);  
        Sv(interior,:) = ...  
            sparse(1:ni, interior, alpha(interior), ni, no) + ...  
            bsxfun(@times, Aeven(interior,:), beta(interior)./val_even(interior)) + ...  
            bsxfun(@times, Aodd(interior,:), gamma(interior)./val_odd(interior));  
          
        %% Sf  
        Sf = 1/4 .* sparse(repmat((1:nf)',1 ,4), FF, 1);  
        i0 = no + (1:nf)';  
          
        %% Se  
        flaps = sparse([idx;idx], ...  
                       [FF(:,3) FF(:,4);FF(:,4) FF(:,1);FF(:,1) FF(:,2);FF(:,2) FF(:,3)], ...  
                       1);  
        onboundary = (sum(flaps,2) == 2);  
        flaps(onboundary,:) = 0;  
          
        ne = size(E,1);  
        Se = sparse( ...  
                [1:ne 1:ne]', ...  
                [E(:,1); E(:,2)], ...  
                [onboundary;onboundary].*1/2 + ~[onboundary;onboundary].*3/8, ...  
                ne, ...  
                no) + ...  
                flaps*1/16;  
          
        %% new faces & new vertices  
        i1 = no +   nf + (1:nf)';  
        i2 = no + 2*nf + (1:nf)';  
        i3 = no + 3*nf + (1:nf)';  
        i4 = no + 4*nf + (1:nf)';  
          
        FFtmp = [i0 i4 FF(:,1) i1; ...  
                 i0 i1 FF(:,2) i2; ...  
                 i0 i2 FF(:,3) i3; ...  
                 i0 i3 FF(:,4) i4];  
  
        reidx = [(1:no)'; no+(1:nf)'; no+nf+idx];  
        FF = reidx(FFtmp);  
          
        S = [Sv; Sf; Se];  
        VV = S*VV;  
    end  
 end  
