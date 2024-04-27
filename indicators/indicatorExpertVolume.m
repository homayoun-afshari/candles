function [line, area] = indicatorExpertVolume(firm, ~, ~, ~, ~)
line = struct(...
    'volume', firm.candle.extra(:, :, 2));
area = '';
end