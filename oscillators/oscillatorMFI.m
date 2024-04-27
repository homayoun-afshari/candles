function line = oscillatorMFI(firm, ~, rule, parameter)
method = rule;
lookBack = parameter;

difference = firm.candle.last - [0; firm.candle.last(1:end-1)];
g = firm.candle.last.*firm.candle.volume.*(difference>=0);
l = firm.candle.last.*firm.candle.volume.*(difference<0);
G = zeros(firm.total, 1);
L = zeros(firm.total, 1);
switch method
    case 'weighted'
        for i = 1:firm.total
            if i <= lookBack
                G(i) = 2*((1:i)*g(1:i))/i/(i+1);
                L(i) = 2*((1:i)*l(1:i))/i/(i+1);
            else
                G(i) = 2*((1:lookBack)*g(i-lookBack+1:i))/lookBack/(lookBack+1);
                L(i) = 2*((1:lookBack)*l(i-lookBack+1:i))/lookBack/(lookBack+1);
            end
        end
    case 'exponential'
        alpha = 2/(lookBack+1);
        G(1) = g(1);
        L(1) = l(1);
        for i = 2:firm.total
            G(i) = alpha*g(i) + (1-alpha)*G(i-1);
            L(i) = alpha*l(i) + (1-alpha)*L(i-1);
        end
    case 'wilder'
        alpha = 1/lookBack;
        G(1) = g(1);
        L(1) = l(1);
        for i = 2:firm.total
            G(i) = alpha*g(i) + (1-alpha)*G(i-1);
            L(i) = alpha*l(i) + (1-alpha)*L(i-1);
        end
    otherwise
        G = smoothdata(g, method, [lookBack-1 0]);
        L = smoothdata(l, method, [lookBack-1 0]);
end
mfi = G./(G+L);

line = struct(...
    'overSold', 0.2*ones(firm.total, 1),...
    'overBought', 0.8*ones(firm.total, 1),...
    'mfi', mfi);
end