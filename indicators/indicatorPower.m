function [line, area] = indicatorPower(firm, ~, ~, ~, ~)
power = firm.candle.extra(:, 1, 2).*firm.candle.extra(:, 1, 3)./firm.candle.extra(:, 1, 1) - firm.candle.extra(:, 3, 2).*firm.candle.extra(:, 3, 3)./firm.candle.extra(:, 3, 1);
volumized = power.*firm.candle.volume/max(firm.candle.volume);
balance = nan(firm.total, 1);
temp = 0;
for i = 1:firm.total
    balance(i) = temp + power(i);
    if ~isnan(balance(i))
        temp = balance(i);
    end
end

line = struct(...
    'power', power,...
    'volumized', volumized,...
    'balance', balance);
area = '';
end