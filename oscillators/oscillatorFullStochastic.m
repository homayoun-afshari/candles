function line = oscillatorFullStochastic(firm, ~, ~, parameter)
lookBack = parameter(1);
smooth = parameter(2);
windowSize = parameter(3);

lowestLow = zeros(firm.total, 1);
highestLow = zeros(firm.total, 1);
for i = 1:firm.total
    if i < lookBack
        lowestLow(i) = min(firm.candle.low(1:i));
        highestLow(i) = max(firm.candle.high(1:i));
    else
        lowestLow(i) = min(firm.candle.low(i-lookBack+1:i));
        highestLow(i) = max(firm.candle.high(i-lookBack+1:i));
    end
end
fastLine = (firm.candle.close-lowestLow)./(highestLow-lowestLow);
fastLine(isnan(fastLine)) = 0;
kLine = movmean(fastLine, [smooth-1 0]);
dLine = movmean(kLine, [windowSize-1 0]);

line = struct(...
    'overSold', 0.2*ones(firm.total, 1),...
    'overBought', 0.8*ones(firm.total, 1),...
    'kLine', kLine,...
    'dLine', dLine);
end