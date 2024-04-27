function [line, area] = indicatorLevels(firm, interval, rule, ~, parameter)
method = rule{1};
mapping = eval(rule{2});
depth = parameter(1);
total = parameter(2);
closeness = parameter(3);
preference = parameter(4);

fractal = funcFindFractals(firm.candle.low, firm.candle.high, depth);
idx = find(~isnan(fractal));
base = [nan(idx(1)-1, 1); interp1(idx, fractal(idx), (idx(1):idx(end)).', method); nan(firm.total-idx(end)+1, 1)];

maxDistance = closeness*mean(mapping(firm.candle.high(interval(1):interval(2)))-mapping(firm.candle.low(interval(1):interval(2))));
temp = fractal(interval(1):interval(2));
temp = mapping(temp(~isnan(temp)));
[~, ~, ~, distance] = kmedoids(temp, total, 'Distance', 'sqeuclidean');
distance(distance>maxDistance) = nan;
aim = [sum(~isnan(distance), 1); mean(distance, 1, 'omitnan')];
[~, idx] = sort(sum([preference; 1-preference].*aim./max(aim, [], 2), 1), 'descend');
level = zeros(total, 1);
for i = 1:total
    level(i) = mean(temp(~isnan(distance(:, idx(i)))));
end

line = struct(...
    'base', base,...
    'fractal', fractal,...
    'level', level);
area = '';
end