function [x] = gauss_seidel(A, b, iters)
% A - matrix
% b - vector or matrix. If b - is a memmapfile, then it should be like "...Data.f"
% iters - scalar

if isnumeric(b)
    AA = A'*A;
    Ab = A'*b;
    
    L = tril(AA,-1);
    U = triu(AA,+1);
    LU = L + U; % то есть исключаем главную диагональ
    
    x = zeros(size(Ab));
    for n = 1:size(Ab,2)
        for k = 1:iters
            for m = 1:size(Ab,1)
                x(m,n) = (Ab(m,n) - LU(m,:)*x(:,n))./AA(m,m);
            end
        end
    end
    
%     L = tril(AA,0);
%     U = triu(AA,+1);
% 
%     x = zeros(size(A,2),size(b,2));
%     x(:,1) = ones(size(A,2),1);
% 
%     for n = 1:size(Ab,2)
%         for k = 1:iters
%             for m = 1:size(Ab,1)
%                 x(m,n) = (-U(m,:)*x(:,n) + Ab(m,n) - L(m,1:m-1)*x(1:m-1,n))./L(m,m);
%             end
%         end
%     end
elseif isobject(b)
    AA = A'*A;

    L = tril(AA,0);
    U = triu(AA,+1);

    x = zeros(size(A,2),size(b.Data.f,1));
    x(:,1) = ones(size(A,2),1);

    for n = 1:size(b.Data.f,1)
        Ab = A'*double(b.Data.f(n,:)');
        for k = 1:iters
            for m = 1:size(Ab,1)
                x(m,n) = (-U(m,:)*x(:,n) + Ab(m) - L(m,1:m-1)*x(1:m-1,n))./L(m,m);
            end
        end
    end
end