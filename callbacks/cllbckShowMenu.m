function cllbckShowMenu(handleSource, ~, handleMenu, handleItem)
totalItem = numel(handleItem);
if totalItem == 1
    return;
end
handleFigure = gcf();
temp = handleFigure.UserData.(['current' handleSource.UserData.menuType]);
handleMenu.Visible = 'on';
for j = 1:totalItem
    handleItem(j).Visible = 'on';
    if j == temp
        handleItem(j).FontWeight = 'bold';
    else
        handleItem(j).FontWeight = 'normal';
    end
end
end