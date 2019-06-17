function [x] = jacobi_solve(A, b, iters)
% A - matrix
% b - vector or matrix. If b - is a memmapfile, then it should be like "...Data.f"
% iters - scalar

if isnumeric(b)
    AA = A'*A;
    Ab = A'*b;

    L = tril(AA,0);
    U = triu(AA,+1);
    iD = L\U;

    x = zeros(size(A,2),size(b,2));
    x(:,1) = ones(size(A,2),1);

    for n = 1:size(Ab,2)
        for k = 1:iters
            x(:,n) = -iD*x(:,n) + L\Ab(:,n);
        end
    end
elseif isobject(b)
    AA = A'*A;
    
    L = tril(AA,0);
    U = triu(AA,+1);
    iD = L\U;
    
    x = zeros(size(A,2),size(b,2));
    x(:,1) = ones(size(A,2),1);
    
    for n = 1:size(b.Data.f,1)
        Ab = A'*double(b.Data.f(n,:)');
        for k = 1:iters
            x(:,n) = -iD*x(:,n) + L\Ab;
        end
    end
end