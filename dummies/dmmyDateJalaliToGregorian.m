function dateGregorian = dmmyDateJalaliToGregorian(dateJalali)
baseGregorian = [2020 08 29];
baseJalali = [1399 06 08];
leapYear = [1280 1284 1288 1292 1296 1300 1304 1308 1313 1317 1321 1325 1329 1333 1337 1341 1346 1350 1354 1358 1362 1366 1370 1375 1379 1383 1387 1391 1395 1399 1403];
daysOfmonth = [31 31 31 31 31 31 30 30 30 30 30 29; 31 31 31 31 31 31 30 30 30 30 30 30];
total = size(dateJalali, 1);
dateGregorian = zeros(total, 3);
for i = 1:total
    difference = 0;
    if dateJalali(i, 1) < baseJalali(1)
        difference = 365*(dateJalali(i, 1)-baseJalali(1)) - sum((dateJalali(i, 1)<=leapYear)&(leapYear<baseJalali(1)));
    elseif dateJalali(i, 1) > baseJalali(1)
        difference = 365*(dateJalali(i, 1)-baseJalali(1)) + sum((baseJalali(1)<=leapYear)&(leapYear<dateJalali(i, 1)));
    end
    if dateJalali(i, 2) < baseJalali(2)
        difference = difference - sum(daysOfmonth(1, dateJalali(i, 2):baseJalali(2)-1));
    elseif dateJalali(i, 2) > baseJalali(2)
        difference = difference + sum(daysOfmonth(1, baseJalali(2):dateJalali(i, 2)-1));
    end
    if dateJalali(i, 3) < baseJalali(3)
        difference = difference - (baseJalali(3)-dateJalali(i, 3));
    elseif dateJalali(i, 3) > baseJalali(3)
        difference = difference + (dateJalali(i, 3)-baseJalali(3));
    end
    temp = datevec(datenum(baseGregorian)+difference);
    dateGregorian(i, :) = temp(1:3);
end
end