function [area, signal] = strategyMiner(firmWeekly, firmDaily)
area = struct(...
    'periodBuy', '',...
    'periodSale', '',...
    'membershipIndexPeriod', '');
signal = struct(...
    'total', '',...
    'isBuy', '',...
    'index', '',...
    'percentage', '',...
    'converterIndexCounter', '');

oscillator.line = oscillatorFullStochastic(firmWeekly, [], '', [14 3 3]);
isBullishOld = oscillator.line.dLine(1) <= oscillator.line.kLine(1);
counter = double([isBullishOld ~isBullishOld]);
area.periodBuy = [ones(firmWeekly.total, 1) firmDaily.total*ones(firmWeekly.total, 1)];
area.periodSale = [ones(firmWeekly.total, 1) firmDaily.total*ones(firmWeekly.total, 1)];
for i = 2:firmWeekly.total
    isBullishNew = oscillator.line.dLine(i) <= oscillator.line.kLine(i);
    isCross = xor(isBullishOld, isBullishNew);
    if isCross
        if isBullishNew
            isOverBought = min([oscillator.line.dLine(i) oscillator.line.dLine(i)]) > oscillator.line.overBought(i);
            if ~isOverBought
                counter(1) = counter(1) + 1;
                area.periodBuy(counter(1), 1) = firmWeekly.candle.IndexDay(i);
            end
            if area.periodSale(counter(2), 2) == area.periodSale(end, 2)
                area.periodSale(counter(2), 2) = firmWeekly.candle.IndexDay(i) - (area.periodSale(counter(1), 1)<firmWeekly.candle.IndexDay(i));
            end
        else
            isOverSold = max([oscillator.line.dLine(i) oscillator.line.dLine(i)]) < oscillator.line.overSold(i);
            if ~isOverSold
                counter(2) = counter(2) + 1;
                area.periodSale(counter(2), 1) = firmWeekly.candle.IndexDay(i);
            end
            if area.periodBuy(counter(1), 2) == area.periodBuy(end, 2)
                area.periodBuy(counter(1), 2) = firmWeekly.candle.IndexDay(i) - (area.periodBuy(counter(1), 1)<firmWeekly.candle.IndexDay(i));
            end
        end
    end
    isBullishOld = isBullishNew;
end
area.periodBuy(counter(1)+1:end, :) = [];
area.periodSale(counter(2)+1:end, :) = [];
temp = fieldnames(area);
area.membershipIndexPeriod = false(firmDaily.total, numel(temp)-1);
for i = 1:size(area.membershipIndexPeriod, 2)
    for j = 1:size(area.(temp{i}), 1)
        area.membershipIndexPeriod(area.(temp{i})(j, 1):area.(temp{i})(j, 2), i) = true;
    end
end

oscillator.line = oscillatorFullStochastic(firmDaily, [], '', [14 3 3]);
membershipIndexPeriodOld = area.membershipIndexPeriod(1, :);
isBullishOld = oscillator.line.dLine(1) <= oscillator.line.kLine(1);
counter = 0;
signal.isBuy = false(firmDaily.total, 1);
signal.index = zeros(firmDaily.total, 1);
signal.percentage = zeros(firmDaily.total, 1);
for i = 1:firmDaily.total
    membershipIndexPeriodNew = area.membershipIndexPeriod(i, :);
    isNewArea = any(xor(membershipIndexPeriodOld, membershipIndexPeriodNew));
    isBullishNew = oscillator.line.dLine(i) < oscillator.line.kLine(i);
    isCross = xor(isBullishOld, isBullishNew);
    if isNewArea || isCross
        if isBullishNew
            isOverBought = min([oscillator.line.dLine(i) oscillator.line.dLine(i)]) > oscillator.line.overBought(i);
            if ~isOverBought && membershipIndexPeriodNew(1)
                counter = counter + 1;
                signal.isBuy(counter) = true;
                signal.index(counter) = i;
                signal.percentage(counter) = mean([oscillator.line.dLine(i) oscillator.line.kLine(i)]);
            end
        else
            isOverSold = max([oscillator.line.dLine(i) oscillator.line.dLine(i)]) < oscillator.line.overSold(i);
            if ~isOverSold && membershipIndexPeriodNew(2)
                counter = counter + 1;
                signal.isBuy(counter) = false;
                signal.index(counter) = i;
                signal.percentage(counter) = mean([oscillator.line.dLine(i) oscillator.line.kLine(i)]);
            end
        end
    end
    isBullishOld = isBullishNew;
    membershipIndexPeriodOld = membershipIndexPeriodNew;
end
signal.total = counter;
signal.isBuy(counter+1:end) = [];
signal.index(counter+1:end) = [];
signal.percentage(counter+1:end) = [];
signal.converterIndexCounter = nan(firmDaily.total, 1);
signal.converterIndexCounter(signal.index) = 1:counter;
end