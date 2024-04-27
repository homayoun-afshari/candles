function dateJalali = dmmyDateGregorianToJalali(dateGregorian)
baseGregorian = [2020 08 29];
baseJalali = [1399 06 08];
leapYear = [1280 1284 1288 1292 1296 1300 1304 1308 1313 1317 1321 1325 1329 1333 1337 1341 1346 1350 1354 1358 1362 1366 1370 1375 1379 1383 1387 1391 1395 1399 1403];
daysOfmonth = [31 31 31 31 31 31 30 30 30 30 30 29; 31 31 31 31 31 31 30 30 30 30 30 30];
total = size(dateGregorian, 1);
dateJalali = repmat(baseJalali, total, 1);
for i = 1:total
    difference = days(datetime(dateGregorian(i, 1:3))-datetime(baseGregorian));
    leap = any(dateJalali(i, 1)==leapYear);
    if difference <= 0
        difference = -difference;
        temp = dateJalali(i, 3);
        while true
            if temp <= difference
                dateJalali(i, 2) = dateJalali(i, 2) - 1;
                if dateJalali(i, 2) == 0
                    dateJalali(i, 2) = 12;
                    dateJalali(i, 1) = dateJalali(i, 1) - 1;
                    leap = any(dateJalali(i, 1)==leapYear);
                end
                temp = temp + daysOfmonth(1+leap, dateJalali(i, 2));
            else
                dateJalali(i, 3) = temp - difference;
                break;
            end
        end
    else
        temp = dateJalali(i, 3) + difference;
        while true
            if temp > daysOfmonth(1+leap, dateJalali(i, 2))
                temp = temp - daysOfmonth(1+leap, dateJalali(i, 2));
                dateJalali(i, 2) = dateJalali(i, 2) + 1;
                if dateJalali(i, 2) == 13
                    dateJalali(i, 2) = 1;
                    dateJalali(i, 1) = dateJalali(i, 1) + 1;
                    leap = any(dateJalali(i, 1)==leapYear);
                end
            else
                dateJalali(i, 3) = temp;
                break;
            end
        end
    end
end
end