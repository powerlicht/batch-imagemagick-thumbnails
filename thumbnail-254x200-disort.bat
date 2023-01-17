@ECHO OFF &SETLOCAL
cd arbeitsVZ
CHCP 65001>NUL
REM #################################################################################################################
REM ### aktuelles DATUM ermitteln                                                                               ######
REM #################################################################################################################
for /f "skip=8 tokens=2,3,4,5,6,7,8 delims=: " %%D in ('robocopy /l * \ \ /ns /nc /ndl /nfl /np /njh /XF * /XD *') do (
 set "dow=%%D"
 set "month=%%F"
 set "day=%%E"
 set "HH=%%H"
 set "MM=%%I"
 set "SS=%%J"
 set "year=%%G"
)

 SET "dow=%dow:~0,-1%"
 SET "day=%day:~0,-1%"

if %day% LEQ 9 SET "day=0%day%"

if %month% equ Januar (set "month=01")
if %month% equ Februar (set "month=02")
REM old --- if %month% equ März (set "month=03")
if %month:~-2% equ rz (set "month=03")
if %month% equ April (set "month=04")
if %month% equ Mai (set "month=05")
if %month% equ Juni (set "month=06")
if %month% equ Juli (set "month=07")
if %month% equ August (set "month=08")
if %month% equ September (set "month=09")
if %month% equ Oktober (set "month=10")
if %month% equ November (set "month=11")
if %month% equ Dezember (set "month=12")



REM #################################################################################################################
REM ### Variablen "TAG" "MONAT" "JAHR" aktuelle heutige DATUMS-Angaben zuweisen                                ######
REM #################################################################################################################
SET vartag=%day%
SET varmonat=%month%
SET varjahr=%year%



REM #################################################################################################################
REM ### Output-Verzeichnis 'o' erstellen für die THUMBnails
REM #################################################################################################################
if not exist o (ECHO Verzeichnis o existiert nicht und wird angelegt
	mkdir o)



REM #################################################################################################################
REM NameZusatz immer mit UNTERSTRICH-beginnend ... Erweitert, bei Eingabe wird automatisch ein Unterstrich eingefügt
REM #################################################################################################################
COLOR 3F
SET /p "nameZusatz=Namenszusatz: "
IF NOT "%nameZusatz%"=="" (
    SET "nameZusatz=_%nameZusatz%"
) ELSE (
    SET nameZusatz=
)



REM #################################################################################################################
REM partiell EXIF-Informationen loeschen --- Model-Name + Hersteller-Name + Seriennummer
REM #################################################################################################################
for %%f in (*.jpg) do @c:\tools\_photo\exiftool_2021-01-06.exe -overwrite_original %%f -Make= -Model= -CameraModel= -InternalSerialNumber= -ImageUniqueID=
REM for %%f in (*.jpg) do @c:\tools\_photo\exiftool_2019.11.27.exe -overwrite_original %%f -Make= -Model= -CameraModel= -InternalSerialNumber=



REM #################################################################################################################
REM große Bilder COPY > 'o' Ordner
REM #################################################################################################################
for %%f in (*.jpg) do @copy "%%f" ".\o\%%~nf%nameZusatz%.jpg"




REM #################################################################################################################
REM Erzeugung von THUMBNAILS im Ordnuner 'o'
REM ################################################################################################################# -thumbnail 184x138 ^
for %%f in (*.jpg) do @C:\tools\_photo\ImageMagick-7.0.10-34-portable-Q16-x64\convert.exe %%f  -quality 75% ^
-set option:dsize %%[size] -set option:dw %%[width] -set option:dh %%[height] -set option:od %%[exif:DateTimeOriginal] ^
-set option:model %%[exif:model] ^
-distort SRT 1.5,0 -gravity center ^
-thumbnail 254x200 ^
-define jpeg:size=%%[dw]X%%[dh] -gravity center -background black ^
-extent 254x200   ^
-gravity NorthWest -background white -fill white -annotate 0x0 "" -splice 0x15 ^
-gravity NorthWest -background white -fill red -annotate 0x0+5 "%%~nf.jpg"  ^
-gravity NorthEast -background white -fill black -annotate 0x0+5 "%%[dsize]"  ^
-gravity SouthWest -background white -fill white -annotate 0x0 "" -splice 0x15 ^
-gravity SouthEast -background white -fill green -annotate 0x0+5 "%%[od] Uhr" ^
-gravity SouthWest -background white -fill blue -annotate 0x0+5 "%%[dw]x%%[dh]"  ^
-bordercolor black -border 1x1 ^
.\o\%%~nf%nameZusatz%_thumb.jpg



@REM pause
@REM pause
@REM pause
@REM pause

REM #################################################################################################################
REM ### BBCODE der THUMBnails erzeugen                                                                         ######
REM ################################################################################################################# 
for %%f in (./*.jpg) do echo [url=/img/%varjahr%/%varmonat%/%vartag%/%%~nf%nameZusatz%.jpg][img]/img/%varjahr%/%varmonat%/%vartag%/%%~nf%nameZusatz%_thumb.jpg[/img][/url] >>%year%.%month%.%day%_bilder-liste_urllokal-img.txt
REM #### ECHO OHNE ZEILENUMBRUCH:
for %%f in (./*.jpg) do echo|<NUL SET /p="[url=/img/%varjahr%/%varmonat%/%vartag%/%%~nf%nameZusatz%.jpg][img]/img/%varjahr%/%varmonat%/%vartag%/%%~nf%nameZusatz%_thumb.jpg[/img][/url] " >>%year%.%month%.%day%_bilder-liste_urllokal-img_%nameZusatz%.txt



REM #################################################################################################################
REM ### BBCODE in die Zwischenablage                                                                           ######
REM #################################################################################################################
type %year%.%month%.%day%_bilder-liste_urllokal-img_%nameZusatz%.txt  | clip.exe



REM #################################################################################################################
REM ### im NETZLAUFWERK vom HTTP-Server Ordnerstruktur DATUMs-sortiert anlegen
REM #################################################################################################################
if not exist "\\NETZLAUFWERK\ApacheServer\htdocs\img\%varjahr%" (mkdir "\\NETZLAUFWERK\ApacheServer\htdocs\img\%varjahr%")
if not exist "\\NETZLAUFWERK\ApacheServer\htdocs\img\%varjahr%\%varmonat%" (mkdir "\\NETZLAUFWERK\ApacheServer\htdocs\img\%varjahr%\%varmonat%")
if not exist "\\NETZLAUFWERK\ApacheServer\htdocs\img\%varjahr%\%varmonat%\%vartag%" (mkdir "\\NETZLAUFWERK\ApacheServer\htdocs\img\%varjahr%\%varmonat%\%vartag%")



REM #################################################################################################################
REM CD ./o/
REM for %%f in (*.jpg) do @move "%%f" "\\NETZLAUFWERK\ApacheServer\htdocs\img\2019\09\16\%%~nxf"
REM #################################################################################################################
REM ### THUMBnails nach HTTP-Server VERSCHIEBEN
REM ###  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
REM ### ! ! ! ! ! ! ! --- im Zielordner werden Dateien OHNE RüCKFRAGE üBERSCHRIEBEN --- ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
REM ###  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! 
REM #################################################################################################################
PAUSE
for %%f in (".\o\*.jpg") do @move "%%f" "\\NETZLAUFWERK\ApacheServer\htdocs\img\%varjahr%\%varmonat%\%vartag%\%%~nxf"
