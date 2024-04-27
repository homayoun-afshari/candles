function [line, area] = indicatorTransfer(firm, ~, ~, ~, ~)
transfer = firm.candle.extra(:, 1, 2).*firm.candle.extra(:, 1, 3) - firm.candle.extra(:, 3, 2).*firm.candle.extra(:, 3, 3);
volumized = transfer.*firm.candle.volume/max(firm.candle.volume);
balance = nan(firm.total, 1);
temp = 0;
for i = 1:firm.total
    balance(i) = temp + transfer(i);
    if ~isnan(balance(i))
        temp = balance(i);
    end
end

line = struct(...
    'transfer', transfer,...
    'volumized', volumized,...
    'balance', balance);
area = '';
end