@echo off
setlocal EnableDelayedExpansion
title Fastboot Flasher Begonia

if exist !PROGRAMFILES(X86)! set bitness=64 || set bitness=32

:Admin_permissions
>nul 2>&1 %SYSTEMROOT%\system32\icacls.exe %SYSTEMROOT%\system32\WDI
if %errorlevel% EQU 0 cd /d %~dp0 && goto :Moving_script
echo.Запрос прав администратора...
echo.Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo.UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %bitness:"=""%", "", "runas", 1 >> %temp%\getadmin.vbs
%temp%\getadmin.vbs
del /f /q %temp%\getadmin.vbs
exit

:Moving_script
echo.%~dp0 | find "Flasher"
if %errorlevel% EQU 0 goto :Variables
mkdir Flasher
>nul copy flasher.bat Flasher
Flasher\flasher.bat
exit

:Variables
cd..
if exist flasher.bat del /f /q flasher.bat
cd /d %~dp0
mode con cols=114 lines=30
for /f "tokens=1-10 delims=. " %%a in ('date /t') do set date=%%c%%b%%a
set curl="%~dp0Tools\curl.exe"
set fastboot="%~dp0Tools\fastboot.exe"
set adb="%~dp0Tools\adb.exe"
set zip="%~dp0Tools\7z.exe"
set gdrive="%~dp0Tools\gdrive.exe"
set pshdownload=$p = [Enum]::ToObject([System.Net.SecurityProtocolType], 3072) ^

[System.Net.ServicePointManager]::SecurityProtocol = $p ^

(New-Object Net.WebClient).DownloadFile(
if %bitness%==64 (set gdrive_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/gdrive_64.exe
set 7z_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/7za_64.exe
set curl_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/curl_64.zip)
if %bitness%==32 (set gdrive_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/gdrive_32.exe
set 7z_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/7za_32.exe
set curl_link=https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/curl_32.zip)
if exist Tools\ok.txt (set first_run=0) else (set first_run=1)
if %first_run%==1 powershell -Command "& {!pshdownload!'https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/dummy','%temp%\dummy')}" && del /f /q %temp%\dummy
set ver_script=1.2
set g_assist=0
set dfe=0
set date_downloaded=0
set upd_script=2
set upd_miui=2
set upd_custom=2
set upd_gapps=2
set clear_flash_custom=2
set disc2_trigger=0
set flashing_gapps=0
set downloading_custom=0
set downloading_miui=0
set flashing_custom=0
set flashing_miui=0
set rebooting_miui=0
set "echo=echo.&&echo."
set error_flash=echo.Ошибка прошивки
set error_download=echo.Ошибка скачивания
set error_unpack=echo.Ошибка распаковки
set error_reboot=echo.Ошибка перезагрузки
set error_erase=echo.Ошибка очистки
set error_format=echo.Ошибка форматирования
set error_check=echo.Ошибка проверки

:Disclaimer
%echo%ПРОШИВАЛЬЩИК ПРЕДНАЗНАЧЕН ИСКЛЮЧИТЕЛЬНО ДЛЯ REDMI NOTE 8 PRO^^!
%echo%ТАКЖЕ ВАШ ЗАГРУЗЧИК ДОЛЖЕН БЫТЬ РАЗБЛОКИРОВАН^^!
echo.
pause
if %first_run%==0 goto :Script_update

:Tools
CLS
if exist Tools rmdir /s /q Tools
mkdir Tools
%echo%Скачивание утилит...
echo.
powershell -Command "& {Invoke-WebRequest !curl_link! -outfile Tools\curl.zip}" || %error_download% curl && pause>nul && goto Tools
powershell -Command "& {Invoke-WebRequest !7z_link! -outfile Tools\7z.exe}"     || %error_download% 7zip && pause>nul && goto :Tools
%zip% e "Tools\curl.zip" -o"Tools\">nul || %error_unpack% curl && pause>nul && goto :Tools
%curl% -o Tools\gdrive.exe !gdrive_link! || %error_download% gdrive_tool && pause>nul && goto Tools
%curl% -o Tools\platform_tools.zip https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/tools/platfrorm_tools.zip || %error_download% Platform Tools && pause>nul && goto Tools
%zip% e "Tools\platform_tools.zip" -o"Tools\">nul || %error_unpack% Platform Tools && pause>nul && goto :Tools
del /f /q Tools\platform_tools.zip
del /f /q Tools\curl.zip
echo Che smotrish?>Tools\ok.txt
%echo%Успешно.
if %rebooting_miui%==1 goto :Reboot_MIUI
if %downloading_custom%==1 goto :Download_Custom
if %downloading_miui%==1 goto :Download_MIUI
if %flashing_custom%==1 goto :Flash_Custom
if %flashing_miui%==1 goto :Flash_MIUI

:Script_update
if exist versions.txt del /f /q versions.txt
if exist update.bat del /f /q update.bat
ping -n 2 127.0.0.1 >nul
powershell -Command "& {Invoke-WebRequest 'https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/versions.txt' -outfile versions.txt}">nul
if not exist versions.txt %error_download% списка версий && pause>nul && exit /b /1
for /f "tokens=2 delims= " %%a in ('find /i "script" versions.txt') do set new_ver_script=%%a
if not %new_ver_script% GTR %ver_script% goto :Adaptation
:Question1
CLS
%echo%Доступна новая версия Flasher, скачать?
echo.(текущая - %ver_script%; актуальная - %new_ver_script%)
echo.
echo.1) Да
echo.2) Нет
%echo%Чейнджлог:
echo.
%curl% https://raw.githubusercontent.com/Gsset/Fastboot-Flasher-For-Begonia/main/last_changelog
echo.
set /p upd_script="Ваш выбор: "
if %upd_script% NEQ 1 if %upd_script% NEQ 2 goto :Question1
if %upd_script%==2 goto :Adaptation
echo.@echo off^

title Flasher updater^

echo.^

echo.Обновление...^

del /f /q flasher.bat^

"%~dp0Tools/gdrive.exe" download --path "%CD%" 1aph-zom1uNnqbLB-eQOZ7g0kpPU6L-de^>nul^

flasher.bat^

exit>update.bat
CLS
update.bat
exit

:Adaptation
if exist crDroid_GSI (set ex_crdroid_gsi=последующей) else (set ex_crdroid_gsi=последующим скачиванием и)
if exist Lineage     (set ex_lineage=последующей)     else (set ex_lineage=последующим скачиванием и)
if exist crDroid6    (set ex_crdroid6=последующей)    else (set ex_crdroid6=последующим скачиванием и)
if exist PPUI        (set ex_ppui=последующей)        else (set ex_ppui=последующим скачиванием и)
if exist MIUI12.5    (set ex_miui=У)                  else (set ex_miui=Скачать и у)
if exist MIUI12      (set ex_miui12=У)                else (set ex_miui12=Скачать и у)
REM if exist crDroid7    (set ex_crdroid7=последующей)    else (set ex_crdroid7=последующим скачиванием и)
REM if exist RR          (set ex_rr=последующей)          else (set ex_rr=последующим скачиванием и)
REM if exist crDroid8    (set ex_crdroid8=последующей)    else (set ex_crdroid8=последующим скачиванием и)

:Choice
CLS
echo. 
echo. %ex_miui%становить MIUI 12.5
echo.1) с %ex_crdroid_gsi% установкой crDroid GSI Mod 7.xx
echo.2) с %ex_lineage% установкой LineageOS 18.1 by bugreporter
echo.3) с %ex_ppui% установкой PPUI A12
REM echo.3) с %ex_crdroid8% установкой crDroid 8.x Non-CFW
echo.4) c последующей перезагрузкой в TWRP
echo.
echo. %ex_miui12%становить MIUI 12
echo.5) с %ex_crdroid6% установкой crDroid 6.25 Non-CFW
REM echo.6) с %ex_rr% установкой Resurrection Remix OS Q
echo.6) c последующей перезагрузкой в TWRP
echo.
echo.7) Обновить уже установленный кастом
echo.
set /p param="Ваш выбор: "
if %param% GTR 7 goto :Choice
if %param% LSS 1 goto :Choice
if %param%==7 (goto :Choice2) else (goto :Params)
:Choice2
CLS
echo.
echo.1) crDroid GSI Mod 7.xx 
echo.2) LineageOS 18.1 by bugreporter
echo.3) PPUI A12
echo.4) crDroid 6.x Non-CFW
REM echo.5) Resurrection Remix OS Q 
REM echo.5) crDroid 8.x Non-CFW
echo.5) Назад
echo.
set /p param="Ваш выбор: "
if %param% GTR 5 goto :Choice2
if %param% LSS 1 goto :Choice2
if %param%==5 goto :Choice
if %param%==1 set rom=crDroid_GSI
if %param%==2 set rom=Lineage
if %param%==3 set rom=PPUI
if %param%==4 set rom=crDroid6
REM if %param%==5 set rom=RR
REM if %param%==5 set rom=crDroid8
set disc2_trigger=1
goto :ROMs_params
:Params
if %param%==1 set rom=crDroid_GSI
if %param%==2 set rom=Lineage
if %param%==3 set rom=PPUI
REM if %param%==3 set rom=crDroid8
if %param%==4 set rom=MIUI
if %param%==4 set android_ver=11
if %param%==5 set rom=crDroid6
REM if %param%==6 set rom=RR
if %param%==6 set rom=MIUI
if %param%==6 set android_ver=10
:ROMs_params
if %rom%==crDroid_GSI (set display_rom=crDroid GSI Mod 7.xx
set "post_link=https://4pda.to/forum/index.php?showtopic=974421&st=12040#entry110287291"
set id_rom=1A-geSFg-51HrHyXBaKsUW4GqxSwcsG_H
set android_ver=11)
if %rom%==Lineage (set display_rom=LineageOS 18.1 by bugreporter
set "post_link=https://4pda.to/forum/index.php?showtopic=974421&st=9040#entry106451290"
set id_rom=1tPh-APvr4ZKf9_IAy0JMRjK7oB_b1Mf1
set android_ver=11)
if %rom%==PPUI (set display_rom=PPUI A12
set "post_link=https://t.me/ppui_begonia/884"
set id_rom=1GlNd-60boDxtIFzmP_vCA9wPeXOE6dbt
set android_ver=12)
if %rom%==crDroid6 (set display_rom=crDroid 6.25 Non-CFW
set "post_link=https://4pda.to/forum/index.php?showtopic=974421&st=1480#entry97822397"
set id_rom=1L6UN-keNGc_etgyzUez1mztr2NcV5qhi
set android_ver=10)
REM if %rom%==crDroid7 (set display_rom=crDroid 7.x Non-CFW
REM set "post_link=0"
REM set id_rom=1LwFO4Ncu7GesrHC-a0lU6Ey8kxYhaIPx
REM set android_ver=11)
REM if %rom%==crDroid8 (set display_rom=crDroid 8.x Non-CFW
REM set "post_link=https://forum.xda-developers.com/t/rom-official-begonia-12-0-crdroidandroid-v8-x.4386913"
REM set id_rom=1u9PFrjVlxpl5sIxIpseZzendN9l9R1vK
REM set android_ver=12)
REM if %rom%==RR (set display_rom=Resurrection Remix OS Q
REM set "post_link=https://4pda.to/forum/index.php?showtopic=974421&st=5580#entry102565322"
REM set id_rom=1E_LkTuivR17XGwGt9pp6MiGY5x1wG63u
REM set android_ver=10)
if %android_ver% GTR 10 (set miui_ver=12.5&& set miui_link=1sAYZMdpLdxtl2rgcPLhLo7mI48fRTGvI) else (set miui_ver=12&& set miui_link=1oFHKe3ML038JKDDQLwd_1WtzETp1fDoe)
if %disc2_trigger%==1 goto :Disclaimer2

:Authorisation
CLS
if exist %AppData%\.gdrive\token_v2.json goto :MIUI_update
%echo%Для скачивания файлов с Google Drive требуется аутентификация
%echo%Войдите в свой аккаунт в открывшемся окне браузера, разрешите доступ и вставьте код аутентификации:
echo.%gdrive% download --path %temp%\ 1I-sJEVyMfHHYrpqvxEyyZJQ_-EEy4IY5^>verification.txt>gdrive.bat
powershell -Command "& {Start-Process %~dp0gdrive.bat -WindowStyle Hidden}"
ping -n 2 127.0.0.1 >nul
powershell -Command "& {Stop-Process -Name "gdrive"}"
for /f "delims=" %%a in ('type verification.txt ^| find /i "https"') do set auth_link=%%a
powershell -Command "& {Start-Process '!auth_link!'}"
echo.
>nul %gdrive% download --path %~dp0Tools 1I-sJEVyMfHHYrpqvxEyyZJQ_-EEy4IY5
if %errorlevel% NEQ 0 goto :Authorisation
del /f /q verification.txt && del /f /q gdrive.bat && del /f /q %temp%\dummyg

:MIUI_update
if not exist MIUI%miui_ver%\version.txt if %clear_flash_custom%==2 if not %rom%==MIUI goto :Custom_update
if %clear_flash_custom%==1 goto :Custom_update
if not exist MIUI%miui_ver%\version.txt if %rom%==MIUI goto :Download_MIUI
set /p ver_miui=<MIUI%miui_ver%\version.txt || %error_check% скачанной версии MIUI %miui_ver% && pause>nul && goto :Tools
for /f "tokens=2 delims= " %%a in ('find /i "MIUI%miui_ver%" versions.txt') do set new_ver_miui=%%a
if not %new_ver_miui% GTR %ver_miui% if not %rom%==MIUI goto :Custom_update
if not %new_ver_miui% GTR %ver_miui% if %rom%==MIUI goto :Download_MIUI
:Question2
CLS
%echo%Доступна новая версия MIUI %miui_ver%, скачать?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p upd_miui="Ваш выбор: "
if %upd_miui% NEQ 1 if %upd_miui% NEQ 2 CLS && goto :Question2

:Custom_update
if not exist %rom%\version.txt goto :GApps_update
set /p ver_custom=<%rom%\version.txt || %error_check% скачанной версии %display_rom% && pause>nul && goto :GApps_update
for /f "tokens=2 delims= " %%a in ('find /i "%rom%" versions.txt') do set new_ver_custom=%%a
if not %new_ver_custom% GTR %ver_custom% goto :GApps_update
:Question3
CLS
%echo%Доступна новая версия %display_rom%, скачать?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p upd_custom="Ваш выбор: "
if %upd_custom% NEQ 1 if %upd_custom% NEQ 2 CLS && goto :Question3

:GApps_update
if %rom%==PPUI if %clear_flash_custom%==2 goto :Download_MIUI
if %rom%==PPUI if %clear_flash_custom%==1 goto :Download_Custom
if not exist GApps/gapps_a%android_ver%_*.zip if %clear_flash_custom%==2 goto :Download_MIUI
if not exist GApps/gapps_a%android_ver%_*.zip if %clear_flash_custom%==1 goto :Download_Custom
for /f "delims=" %%a in ('dir %~dp0GApps /s /b gapps_a%android_ver%_*.zip') do set "name=%%~na"
for /f "tokens=1-22 delims=_" %%a in ('echo.!name!') do set gapps_ver=%%c
for /f "tokens=1-22 delims=_" %%a in ('echo.!name!') do set date_downloaded=%%d
set pshcommand=$a = Get-Content %~dp0GApps\opengapps^

$a -match 'https://downloads\.sourceforge\.net/project/opengapps/arm64/......../open_gapps-arm64-%android_ver%\.0-%gapps_ver%-........\.zip' ^| Out-Null^

$Matches.0
if %android_ver% NEQ 12 (powershell -Command "& {Invoke-WebRequest 'https://api.opengapps.org/list' -outfile %~dp0GApps\opengapps}"
powershell -Command "^& ^{!pshcommand!^}^">%~dp0GApps\link.txt
ping -n 2 127.0.0.1 >nul
for /f "usebackq delims=" %%a in (%~dp0GApps\link.txt) do set date_download=%%a
set date_download=!date_download:~58,8!)
if %android_ver%==12 (for /f "tokens=2 delims= " %%a in ('find /i "GAppsA12" versions.txt') do set date_download=%%a)
if !date_download! GTR !date_downloaded! goto :Question4
if %clear_flash_custom%==1 goto :Download_Custom
if %clear_flash_custom%==2 goto :Download_MIUI
:Question4
CLS
%echo%Доступно обновление GApps, скачать?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p upd_gapps="Ваш выбор: "
if %upd_gapps% NEQ 1 if %upd_gapps% NEQ 2 CLS && goto :Question4
if %upd_gapps%==1 del /f /q GApps\gapps_a%android_ver%_%gapps_ver%_%date_downloaded%.zip&& goto :GApps_Download
if %clear_flash_custom%==1 goto :Download_Custom

:Download_MIUI
if exist MIUI%miui_ver% if %upd_miui%==2 goto :Unpack_MIUI
if exist MIUI%miui_ver% rmdir /s /q MIUI%miui_ver%
mkdir MIUI%miui_ver%
CLS
%echo%Скачивание MIUI %miui_ver%...
echo.
set downloading_miui=1
%gdrive% download --path "MIUI%miui_ver%" %miui_link% || %error_download% MIUI %miui_ver% && pause>nul && rmdir /s /q "%~dp0MIUI%miui_ver%" && goto :Tools
%echo%Успешно.
set downloading_miui=0

:Unpack_MIUI
if exist MIUI%miui_ver%\version.txt if not %rom%==MIUI goto :Download_Custom
if exist MIUI%miui_ver%\version.txt goto :Flash_MIUI
CLS
%echo%Распаковка MIUI %miui_ver%...
%zip% e %~dp0MIUI%miui_ver%\MIUI%miui_ver%.7z -o%~dp0MIUI%miui_ver%\ || %error_unpack% MIUI %miui_ver% && pause>nul && rmdir /s /q "%~dp0MIUI%miui_ver%" && goto :Download_MIUI
%echo%Успешно.
if %rom%==MIUI goto :Flash_MIUI

:Download_Custom
if exist %rom% if %upd_custom%==2 goto :Unpack_Custom
if exist %rom% rmdir /s /q %rom%
mkdir %rom%
CLS
%echo%Скачивание %display_rom%...
echo.
set downloading_custom=1
%gdrive% download --path "%rom%" %id_rom% || %error_download% %rom% && pause>nul && rmdir /s /q %rom% && goto :Tools
%echo%Успешно.
set downloading_custom=0

:Unpack_Custom
if exist %rom%\version.txt if %clear_flash_custom%==1 goto :Flash_custom
if exist %rom%\version.txt if %clear_flash_custom%==2 goto :Flash_MIUI
CLS
%echo%Распаковка %display_rom%...
%zip% e %~dp0%rom%\%rom%.7z -o%~dp0%rom%\ || %error_unpack% %rom% && pause>nul && rmdir /s /q %rom% && goto :Download_Custom
%echo%Успешно.
if %flashing_custom%==1 goto :Flash_Custom
if %clear_flash_custom%==1 goto :Flash_Custom

:Flash_MIUI
CLS
%echo%Проверка модели вашего смартфона и статуса блокировки загрузчика...
%echo%Переведите ваш смартфон в режим fastboot и подключите к компьютеру
%fastboot% getvar product  2>&1 | findstr /r /c:"^product: *begonia" || echo.Неподходящее устройство && rmdir /s /q %~dp0 && pause>nul && exit /B 1
%fastboot% getvar unlocked 2>&1 | findstr /r /c:"^unlocked: *yes"    || echo.Загрузчик заблокирован  && rmdir /s /q %~dp0 && pause>nul && exit /B 1
CLS
%echo%Установка MIUI %miui_ver%...
echo.
set flashing_miui=1
REM goto skip1
%fastboot% erase boot     || %error_erase% boot     && pause>nul && goto :Tools
%fastboot% erase expdb    || %error_erase% expdb    && pause>nul && goto :Tools
%fastboot% erase metadata || %error_erase% metadata && pause>nul && goto :Tools
%fastboot% flash crclist       %~dp0MIUI%miui_ver%\crclist.txt           || %error_flash% crclist       && goto :Error_flashing_miui
%fastboot% flash sparsecrclist %~dp0MIUI%miui_ver%\sparsecrclist.txt     || %error_flash% sparsecrclist && goto :Error_flashing_miui
%fastboot% flash audio_dsp     %~dp0MIUI%miui_ver%\audio_dsp.img         || %error_flash% audio_dsp     && goto :Error_flashing_miui
%fastboot% flash boot          %~dp0MIUI%miui_ver%\boot.img              || %error_flash% boot          && goto :Error_flashing_miui
%fastboot% flash cam_vpu1      %~dp0MIUI%miui_ver%\cam_vpu1.img          || %error_flash% cam_vpu1      && goto :Error_flashing_miui
%fastboot% flash cam_vpu2      %~dp0MIUI%miui_ver%\cam_vpu2.img          || %error_flash% cam_vpu2      && goto :Error_flashing_miui
%fastboot% flash cam_vpu3      %~dp0MIUI%miui_ver%\cam_vpu3.img          || %error_flash% cam_vpu3      && goto :Error_flashing_miui
%fastboot% flash cust          %~dp0MIUI%miui_ver%\cust.img              || %error_flash% cust          && goto :Error_flashing_miui
%fastboot% flash dtbo          %~dp0MIUI%miui_ver%\dtbo.img              || %error_flash% dtbo          && goto :Error_flashing_miui
%fastboot% flash efuse         %~dp0MIUI%miui_ver%\efuse.img             || %error_flash% efuse         && goto :Error_flashing_miui
%fastboot% flash exaid         %~dp0MIUI%miui_ver%\exaid.img             || %error_flash% exaid         && goto :Error_flashing_miui
%fastboot% flash gsort         %~dp0MIUI%miui_ver%\gsort.img             || %error_flash% gsort         && goto :Error_flashing_miui
%fastboot% flash gz1           %~dp0MIUI%miui_ver%\gz.img                || %error_flash% gz1           && goto :Error_flashing_miui
%fastboot% flash gz2           %~dp0MIUI%miui_ver%\gz.img                || %error_flash% gz2           && goto :Error_flashing_miui
%fastboot% flash lk            %~dp0MIUI%miui_ver%\lk.img                || %error_flash% lk            && goto :Error_flashing_miui
%fastboot% flash lk2           %~dp0MIUI%miui_ver%\lk.img                || %error_flash% lk2           && goto :Error_flashing_miui
%fastboot% flash logo          %~dp0MIUI%miui_ver%\logo.bin              || %error_flash% logo          && goto :Error_flashing_miui
%fastboot% flash md1img        %~dp0MIUI%miui_ver%\md1img.img            || %error_flash% md1img        && goto :Error_flashing_miui
%fastboot% flash oem_misc1     %~dp0MIUI%miui_ver%\oem_misc1.img         || %error_flash% oem_misc1     && goto :Error_flashing_miui
%fastboot% flash preloader     %~dp0MIUI%miui_ver%\preloader_begonia.bin || %error_flash% preloader     && goto :Error_flashing_miui
%fastboot% flash recovery      %~dp0MIUI%miui_ver%\recovery.img          || %error_flash% recovery      && goto :Error_flashing_miui
%fastboot% flash scp1          %~dp0MIUI%miui_ver%\scp.img               || %error_flash% scp1          && goto :Error_flashing_miui
%fastboot% flash scp2          %~dp0MIUI%miui_ver%\scp.img               || %error_flash% scp2          && goto :Error_flashing_miui
%fastboot% flash sspm_1        %~dp0MIUI%miui_ver%\sspm.img              || %error_flash% sspm_1        && goto :Error_flashing_miui
%fastboot% flash sspm_2        %~dp0MIUI%miui_ver%\sspm.img              || %error_flash% sspm_2        && goto :Error_flashing_miui
%fastboot% flash spmfw         %~dp0MIUI%miui_ver%\spmfw.img             || %error_flash% spmfw         && goto :Error_flashing_miui
%fastboot% flash system        %~dp0MIUI%miui_ver%\system.img            || %error_flash% system        && goto :Error_flashing_miui
%fastboot% flash tee1          %~dp0MIUI%miui_ver%\tee.img               || %error_flash% tee1          && goto :Error_flashing_miui
%fastboot% flash tee2          %~dp0MIUI%miui_ver%\tee.img               || %error_flash% tee2          && goto :Error_flashing_miui
%fastboot% flash vbmeta        %~dp0MIUI%miui_ver%\vbmeta.img            || %error_flash% vbmeta        && goto :Error_flashing_miui
%fastboot% flash vendor        %~dp0MIUI%miui_ver%\vendor.img            || %error_flash% vendor        && goto :Error_flashing_miui
:skip1
%echo%Успешно.
set flashing_miui=0
if exist %~dp0MIUI%miui_ver%\MIUI%miui_ver%.7z del /f /q %~dp0MIUI%miui_ver%\MIUI%miui_ver%.7z
if %rom%==MIUI goto :Reboot_MIUI

:Flash_Custom
CLS
%echo%Установка %display_rom%...
set flashing_custom=1
%fastboot% reboot bootloader || %error_reboot% в bootloader>nul && pause>nul && goto :Tools
ping -n 2 127.0.0.1 >nul
REM goto skip2
%fastboot% erase system  || %error_erase% system  && pause>nul && goto :Tools
%fastboot% erase vendor  || %error_erase% vendor  && pause>nul && goto :Tools
REM %fastboot% flash sparsecrclist %~dp0%rom%\sparsecrclist.txt || %error_flash% sparsecrclist && pause>nul && del /f /q %~dp0%rom%\*.img && goto :Unpack_Custom
%fastboot% flash system %~dp0%rom%\system.img || %error_flash% system && goto :Error_flashing_custom
%fastboot% flash vendor %~dp0%rom%\vendor.img || %error_flash% vendor && goto :Error_flashing_custom
if %rom%==PPUI %fastboot% flash boot %~dp0%rom%\boot.img         || %error_flash% boot     && goto :Error_flashing_custom
if %rom%==PPUI %fastboot% flash dtbo %~dp0%rom%\dtbo.img         || %error_flash% dtbo     && goto :Error_flashing_custom
if %rom%==PPUI %fastboot% flash recovery %~dp0%rom%\recovery.img || %error_flash% recovery && goto :Error_flashing_custom
REM if %rom%==crDroid8 %fastboot% flash boot %~dp0%rom%\boot.img || %error_flash% boot && goto :Error_flashing_custom
REM if %rom%==crDroid8 %fastboot% flash dtbo %~dp0%rom%\dtbo.img || %error_flash% dtbo && goto :Error_flashing_custom
REM if %rom%==RR %fastboot% flash boot %~dp0%rom%\boot.img || %error_flash% boot && goto :Error_flashing_custom
if not %rom%==crDroid6 goto :Clearing
:Advanced_flashing
%fastboot% flash audio_dsp %~dp0%rom%\audio_dsp.img || %error_flash% audio_dsp && goto :Error_flashing_custom
%fastboot% flash boot %~dp0%rom%\boot.img           || %error_flash% boot      && goto :Error_flashing_custom
%fastboot% flash cam_vpu1 %~dp0%rom%\cam_vpu1.img   || %error_flash% cam_vpu1  && goto :Error_flashing_custom
%fastboot% flash cam_vpu2 %~dp0%rom%\cam_vpu2.img   || %error_flash% cam_vpu2  && goto :Error_flashing_custom
%fastboot% flash cam_vpu3 %~dp0%rom%\cam_vpu3.img   || %error_flash% cam_vpu3  && goto :Error_flashing_custom
%fastboot% flash dtbo %~dp0%rom%\dtbo.img           || %error_flash% dtbo      && goto :Error_flashing_custom
%fastboot% flash gz1 %~dp0%rom%\gz.img              || %error_flash% gz1       && goto :Error_flashing_custom
%fastboot% flash gz2 %~dp0%rom%\gz.img              || %error_flash% gz2       && goto :Error_flashing_custom
%fastboot% flash lk %~dp0%rom%\lk.img               || %error_flash% lk        && goto :Error_flashing_custom
%fastboot% flash lk2 %~dp0%rom%\lk.img              || %error_flash% lk2       && goto :Error_flashing_custom
%fastboot% flash logo %~dp0%rom%\logo.bin           || %error_flash% logo      && goto :Error_flashing_custom
%fastboot% flash md1img %~dp0%rom%\md1img.img       || %error_flash% md1img    && goto :Error_flashing_custom
%fastboot% flash preloader %~dp0%rom%\preloader.bin || %error_flash% preloader && goto :Error_flashing_custom
%fastboot% flash scp1 %~dp0%rom%\scp.img            || %error_flash% scp1      && goto :Error_flashing_custom
%fastboot% flash scp2 %~dp0%rom%\scp.img            || %error_flash% scp2      && goto :Error_flashing_custom
%fastboot% flash spmfw %~dp0%rom%\spmfw.img         || %error_flash% spmfw     && goto :Error_flashing_custom
%fastboot% flash tee1 %~dp0%rom%\tee.img            || %error_flash% tee1      && goto :Error_flashing_custom
%fastboot% flash tee2 %~dp0%rom%\tee.img            || %error_flash% tee2      && goto :Error_flashing_custom
%fastboot% flash sspm_1 %~dp0%rom%\sspm.img         || %error_flash% sspm_1    && goto :Error_flashing_custom
%fastboot% flash sspm_2 %~dp0%rom%\sspm.img         || %error_flash% sspm_2    && goto :Error_flashing_custom
:Clearing
if %clear_flash_custom%==2 %fastboot% -w || %error_format% data && pause>nul && goto :Tools
if %clear_flash_custom%==1 %fastboot% erase cache || %error_erase% cache && pause>nul && goto :Tools
:skip2
%fastboot% reboot recovery || %error_reboot% в recovery && pause>nul && goto :Tools
%echo%Успешно.
set flashing_custom=0
del /f /s /q %~dp0%rom%\*.7z
:DFE
if %android_ver%==12 (CLS
%echo%Скачать и установить DFE?
if %clear_flash_custom%==1 %echo%Требуется только в случае, если он был установлен ранее^^!
echo.
echo.1^) Да
echo.2^) Нет
echo.
set /p dfe="Ваш выбор: "
if %dfe% NEQ 1 if %dfe% NEQ 2 goto :DFE
if %dfe%==1 if not exist %rom%/DFE.zip %gdrive% download --path %rom% 163o-zQcBXDGS6sMlU9XOVCqX2nezYDME >nul || %error_download% DFE && pause>nul && goto :DFE
if %dfe%==2 goto :Next
CLS
%echo%Убедитесь, что вы загрузились в рекавери, ввели пароль, если требовалось, и перевели телефон в режим adb sideload
echo.
pause
CLS
%echo%Установка DFE...
%adb% sideload %~dp0%rom%\DFE.zip || %error_flash% DFE && del /f /q %~dp0%rom%\DFE.zip&& pause>nul && goto :DFE)
:Next
if %rom%==PPUI ping -n 15 127.0.0.1 >nul && %adb% reboot
if %rom%==PPUI goto :Open_post
if not exist %~dp0GApps\gapps_a%android_ver%_*.zip goto :GApps_Question
if exist %~dp0GApps\gapps_a%android_ver%_*.zip goto :GApps_Flash

:Reboot_MIUI
CLS
%echo%Перезагрузка...
echo.
set rebooting_miui=1
%fastboot% -w              || %error_format% data       && pause>nul && goto :Tools
%fastboot% reboot recovery || %error_reboot% в recovery && pause>nul && goto :Tools
%echo%Успешно.
echo.
pause>nul && exit

:GApps_Question
CLS
%echo%Cкачать GApps?
echo.
if %android_ver% NEQ 12 (echo.1^) Да, pico) else (echo.1^) Да)
if %android_ver% NEQ 12 (echo.2^) Да, nano ^(вариант, если нужен OK Google^)) else (echo.1^) Да, c OK Google)
echo.3) Нет
echo.
set /p gapps="Ваш выбор: "
if %gapps% NEQ 1 if %gapps% NEQ 2 if %gapps% NEQ 3 goto :GApps_Question
if %gapps%==1 set gapps_ver=pico&& set g_assist=0
if %gapps%==2 set gapps_ver=nano&& set g_assist=1
if %gapps%==3 %adb% reboot 
if %gapps%==3 goto :Open_post

:GApps_Download
if not exist %~dp0GApps mkdir GApps
set pshcommand=$a = Get-Content %~dp0GApps\opengapps^

$a -match 'https://downloads\.sourceforge\.net/project/opengapps/arm64/......../open_gapps-arm64-%android_ver%\.0-%gapps_ver%-........\.zip' ^| Out-Null^

$Matches.0
if %android_ver% NEQ 12 (powershell -Command "& {Invoke-WebRequest 'https://api.opengapps.org/list' -outfile %~dp0GApps\opengapps}"
powershell -Command "^& ^{!pshcommand!^}^">%~dp0GApps\link.txt
ping -n 2 127.0.0.1 >nul
for /f "usebackq delims=" %%a in (%~dp0GApps\link.txt) do set date_download=%%a
set date_download=!date_download:~58,8!)
if %android_ver%==12 (for /f "tokens=2 delims= " %%a in ('find /i "GAppsA12" versions.txt') do set date_download=%%a)
CLS
%echo%Скачивание GApps...
if %android_ver%==12 (%gdrive% download --path "GApps" 19M4a78dSDmfoCyvWL5nxHAj3AvSe-BQ3 || %error_download% GApps && pause>nul && exit
if %g_assist%==1 %gdrive% download --path "GApps" 16Hor7wqraG2yWa0f9jOkOkTHv78jlPiH || %error_download% Voice Match addon && pause>nul && exit)
if %android_ver% NEQ 12 %curl% -L -o %~dp0GApps\gapps_a%android_ver%_%gapps_ver%_!date_download!.zip https://downloads.sourceforge.net/project/opengapps/arm64/!date_download!/open_gapps-arm64-%android_ver%.0-%gapps_ver%-!date_download!.zip
%echo%Успешно.
del /f /q %~dp0GApps\link.txt && del /f /q %~dp0GApps\opengapps
if %upd_gapps%==1 if %clear_flash_custom%==1 goto :Download_Custom
if %upd_gapps%==1 if %clear_flash_custom%==2 goto :Download_MIUI
goto :GApps_Flash

:GApps_Flash
for /f "delims=" %%a in ('dir %~dp0GApps /s /b gapps_a%android_ver%_*.zip') do set "name=%%~na"
for /f "tokens=1-22 delims=_" %%a in ('echo.!name!') do set date_downloaded=%%d
for /f "tokens=1-22 delims=_" %%a in ('echo.!name!') do set gapps_ver=%%c
if %android_ver%==12 set gapps_ver=bit
CLS
%echo%Установить GApps?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p install_gapps="Ваш выбор: "
if %install_gapps% NEQ 1 if %install_gapps% NEQ 2 goto :GApps_flash
if %install_gapps%==2 %adb% reboot
if %install_gapps%==2 goto :Open_post
CLS
%echo%Убедитесь, что вы загрузились в рекавери, ввели пароль, если требовалось, и перевели телефон в режим adb sideload
echo.
pause
CLS
%echo%Установка GApps...
echo.
set flashing_gapps=1
%adb% sideload %~dp0GApps\gapps_a%android_ver%_%gapps_ver%_%date_downloaded%.zip || %error_flash% GApps && pause>nul && goto :GApps_Flash
if %android_ver%==12 if %clear_flash_custom%==1 goto :Question_assistant
if %android_ver%==12 if %clear_flash_custom%==2 if %g_assis%t==1 goto :G_Assistant_Flash
if %android_ver% LSS 12 goto :Success
:Question_assistant
CLS
%echo%Установить аддон для для работы гугл ассистента?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p g_assist="Ваш выбор: "
if %g_assist% NEQ 1 if %g_assist% NEQ 2 goto :Question_assistant
if %g_assist%==2 goto :Success
:G_Assistant_Flash
CLS
%echo%Вернитесь в меню Advanced и вновь нажмите на ADB Sideload
echo.
pause && CLS
%echo%Установка аддона для работы гугл ассистента...
%adb% sideload %~dp0GApps\Addon_assistant.zip || %error_flash% аддона для работы гугл ассистента && pause>nul && goto :G_Assistant_Flash
:Success
%adb% reboot
echo. 
echo.Успешно.
set flashing_gapps=0

:Open_post
CLS
%echo%Открыть пост с прошивкой?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p open_post="Ваш выбор: "
if %open_post% NEQ 1 if %open_post% NEQ 2 goto :Open_post
if %open_post%==2 exit
powershell -Command "& {Start-Process '!post_link!'}"
pause>nul && exit

:Error_flashing_custom
pause>nul && del /f /q %rom%\*.img >nul && del /f /q %rom%\*.txt >nul && del /f /q %rom%\*.bin >nul && goto :Unpack_Custom

:Error_flashing_miui
pause>nul && del /f /q MIUI%miui_ver%\*.img >nul && del /f /q MIUI%miui_ver%\*.txt >nul && del /f /q MIUI%miui_ver%\*.bin >nul && goto :Unpack_MIUI

:Disclaimer2
CLS
%echo%ИСПОЛЬЗУЙТЕ ТОЛЬКО В СЛУЧАЕ, ЕСЛИ У ВАС УЖЕ УСТАНОВЛЕН %display_rom%^^!
echo.
echo.1) Продолжить
echo.2) Назад
echo.
set /p clear_flash_custom="Ваш выбор: "
if %clear_flash_custom% NEQ 1 if %clear_flash_custom% NEQ 2 goto :Disclaimer2
if %clear_flash_custom%==1 goto :Custom_update
if %clear_flash_custom%==2 goto :Choice2
