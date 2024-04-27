function funcInvertIndicator(handleLabelPrice, indicator, handleTicksIndex, handleTicksPrice)
handleFigure = gcf();
current = handleFigure.UserData.currentIndicator;
if current
    handleLabelPrice.String = sprintf('Indicator: %s%s-%u%s', indicator(current).name, dmmyVectorToList(indicator(current).rule, '%s', ', ', '[]'), indicator(current).foresight, dmmyVectorToList(indicator(current).parameter, '%.3g', ', ', ' ()'));
else
    handleLabelPrice.String = 'Indicator: none';
end
for j = 1:numel(indicator)
    for h = 1:numel(indicator(j).handle)
        indicator(j).handle(h).Visible = 'off';
    end
end
for h = 1:numel(indicator(current).handle)
    indicator(current).handle(h).Visible = 'on';
end
temp = dmmyIf(indicator(current).grid(1), 'on', 'off');
for h = 1:size(handleTicksIndex, 2)
    handleTicksIndex(1, h).Visible = temp;
    handleTicksIndex(2, h).Visible = temp;
    handleTicksIndex(3, h).Visible = temp;
end
temp = dmmyIf(indicator(current).grid(2), 'on', 'off');
for h = 1:size(handleTicksPrice, 2)
    handleTicksPrice(1, h).Visible = temp;
    handleTicksPrice(2, h).Visible = temp;
end
end

