function cllbckShowInformation(handleAxesIndicatorAndGraph, ~, information, handleLabelIndex, handleLineHintOscillator, handleLineHintIndicatorAndGraph)
handleFigure = gcf();
temp = round(handleAxesIndicatorAndGraph.CurrentPoint(1, 1));
if temp < 1
    handleFigure.UserData.currentIndex = 1;
elseif temp > numel(information)
    handleFigure.UserData.currentIndex = numel(information);
else
    handleFigure.UserData.currentIndex = temp;
end
funcInvertInformation(information, handleLabelIndex, handleLineHintOscillator, handleLineHintIndicatorAndGraph);
end