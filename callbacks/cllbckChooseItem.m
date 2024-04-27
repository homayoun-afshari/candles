function cllbckChooseItem(handleSource, ~, handleLabel, object, handleTicksIndex, handleTicksVertical, information, handleLabelIndex, handleLineHintOscillator, handleLineHintIndicatorAndGraph)
handleFigure = gcf();
handleFigure.UserData.(['current' handleLabel.UserData.menuType]) = handleSource.UserData.code;
feval(['funcInvert' handleLabel.UserData.menuType], handleLabel, object, handleTicksIndex, handleTicksVertical);
funcInvertInformation(information, handleLabelIndex, handleLineHintOscillator, handleLineHintIndicatorAndGraph);
end