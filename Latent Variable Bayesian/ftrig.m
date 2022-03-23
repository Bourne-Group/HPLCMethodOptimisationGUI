function y = ftrig(X)
    x = X(:,1);
    s = X(:,2);
    y = zeros(size(X,1),1);
    for i = 1:size(X,1)
        if s(i) == 1
            y(i) = sin(6*(x(i)^2 - 0.25)) + 1;
        else
            y(i) = sin(x(i))*tan(x(i)) + 0.1;
        end
    end
end