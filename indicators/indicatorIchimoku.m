function [line, area] = indicatorIchimoku(firm, ~, ~, foresight, parameter)
displacement = foresight;
lookBackBase = parameter(1);
lookBackConversion = parameter(2);
lookBackLagging = parameter(3);

chikoSupan = [firm.candle.close(displacement+1:end); nan(displacement, 1)];
kijunSen = zeros(firm.total, 1);
for i = 1:firm.total
    kijunSen(i) = mean([min(firm.candle.low(dmmyClip(i-lookBackBase+1, 'Below', 1):i)) max(firm.candle.high(dmmyClip(i-lookBackBase+1, 'Below', 1):i))]);
end
tenkanSen = zeros(firm.total, 1);
for i = 1:firm.total
    tenkanSen(i) = mean([min(firm.candle.low(dmmyClip(i-lookBackConversion+1, 'Below', 1):i)) max(firm.candle.high(dmmyClip(i-lookBackConversion+1, 'Below', 1):i))]);
end
senkuSupanA = [nan(displacement, 1); mean([kijunSen tenkanSen], 2)];
senkuSupanB = zeros(firm.total, 1);
for i = 1:firm.total
    senkuSupanB(i) = mean([min(firm.candle.low(dmmyClip(i-lookBackLagging+1, 'Below', 1):i)) max(firm.candle.high(dmmyClip(i-lookBackLagging+1, 'Below', 1):i))]);
end
senkuSupanB = [nan(displacement, 1); senkuSupanB];

isBullishOld = kijunSen(1) <= tenkanSen(1);
counter = double([isBullishOld ~isBullishOld]);
periodBuy = [ones(firm.total, 1) firm.total*ones(firm.total, 1)];
periodSale = [ones(firm.total, 1) firm.total*ones(firm.total, 1)];
for i = 2:firm.total
    isBullishNew = kijunSen(i) <= tenkanSen(i);
    isCross = xor(isBullishOld, isBullishNew);
    if isCross
        if isBullishNew
            counter(1) = counter(1) + 1;
            periodBuy(counter(1), 1) = i;
            periodSale(counter(2), 2) = i;
        else
            counter(2) = counter(2) + 1;
            periodSale(counter(2), 1) = i;
            periodBuy(counter(1), 2) = i;
        end
    end
    isBullishOld = isBullishNew;
end
periodBuy(counter(1)+1:end, :) = [];
periodSale(counter(2)+1:end, :) = [];

isBullishOld = senkuSupanB(1) <= senkuSupanA(1);
counter = double([isBullishOld ~isBullishOld]);
periodKumoPositive = [ones(firm.total+displacement, 1) (firm.total+displacement)*ones(firm.total+displacement, 1)];
periodKumoNegative = [ones(firm.total+displacement, 1) (firm.total+displacement)*ones(firm.total+displacement, 1)];
for i = 1:firm.total+displacement
    isBullishNew = senkuSupanB(i) <= senkuSupanA(i);
    isCross = xor(isBullishOld, isBullishNew);
    if isCross
        if isBullishNew
            counter(1) = counter(1) + 1;
            periodKumoPositive(counter(1), 1) = i;
            periodKumoNegative(counter(2), 2) = i;
        else
            counter(2) = counter(2) + 1;
            periodKumoNegative(counter(2), 1) = i;
            periodKumoPositive(counter(1), 2) = i;
        end
    end
    isBullishOld = isBullishNew;
end
periodKumoPositive(counter(1)+1:end, :) = [];
periodKumoNegative(counter(2)+1:end, :) = [];

line = struct(...
    'chikoSupan', chikoSupan,...
    'kijunSen', kijunSen,...
    'tenkanSen', tenkanSen,...
    'senkuSupanA', senkuSupanA,...
    'senkuSupanB', senkuSupanB);
area = struct(...
    'periodBuy', periodBuy,...
    'periodSale', periodSale,...
    'periodKumoPositive', periodKumoPositive,...
    'periodKumoNegative', periodKumoNegative,...
    'membershipIndexPeriod', '');
temp = fieldnames(area);
area.membershipIndexPeriod = false(firm.total, numel(temp)-1);
for i = 1:size(area.membershipIndexPeriod, 2)
    for j = 1:size(area.(temp{i}), 1)
        area.membershipIndexPeriod(area.(temp{i})(j, 1):area.(temp{i})(j, 2), i) = true;
    end
end
end