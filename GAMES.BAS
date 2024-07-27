DECLARE SUB SearchGame (sSearchLetter$)
DECLARE FUNCTION GetGameName$ (sGameDir AS STRING)
DECLARE FUNCTION CreateGameList% (sOutArray$())
DECLARE SUB RedimPreserve (sArray() AS STRING, iNewSize AS INTEGER)
DECLARE SUB try ()
DECLARE FUNCTION Catch% (iX AS INTEGER)
DECLARE SUB UpdateThumb (sDirName AS STRING)
DECLARE SUB StartupGui ()
DECLARE SUB DrawText (iX AS INTEGER, iY AS INTEGER, sText AS STRING, iMode AS INTEGER)
DECLARE SUB LoadBitmap (sFileName AS STRING, iTarget() AS INTEGER, lPalOut() AS LONG, iStartOut AS INTEGER)

'$INCLUDE: 'Types.bas'
'$INCLUDE: '256x192.bas'

CONST LineSz = (256 * 9 + 4) \ 2
CONST ScrollSz = (70 * 8 + 4) \ 2

REDIM SHARED TextBuff(LineSz), BackText(LineSz * 7)
REDIM SHARED ImgScroll(ScrollSz), WhiteRect(LineSz * 7)
REDIM SHARED iBack(0) AS INTEGER, iThumb(0)
REDIM SHARED lBackPal(255) AS LONG, lThumbPal(255)
REDIM SHARED sGames(0) AS STRING, sDesc(0) AS STRING
DIM SHARED iBackStart, iThumbStart, iGames, iError

iGames = CreateGameList(sGames())
REDIM sDesc(iGames) AS STRING
SetMode256x200
StartupGui

DIM SHARED iSel AS INTEGER, iCur AS INTEGER, iScroll AS INTEGER
DIM SHARED iScrPY AS INTEGER, iScrSz AS INTEGER, iScrOver AS INTEGER
DIM SHARED iMenuCNT AS INTEGER, iScrMax AS INTEGER, iOldSel AS INTEGER
DIM SHARED dUpdateTimer AS DOUBLE

iMenuCNT = UBOUND(sGames): iScrMax = (iMenuCNT - 7)
IF iScrMax < 0 THEN iScrMax = -1

iScrOver = (iMenuCNT - (7 - 2))
IF iScrOver < 0 THEN iSrcOver = 0
iScrSz = (50 \ iScrOver): iSel = VAL(COMMAND$)
IF iScrSz < 3 THEN iScrSz = 3
iOldSel = -1: dUpdateTimer = TIMER
IF iSel < 0 OR iSel > iMenuCNT THEN iSel = 0
IF iSel > 3 THEN iScroll = iSel - 3
IF iScroll > (iScrMax + 1) THEN iScroll = (iScrMax + 1)
iCur = iSel - iScroll

DO
  
  IF iGames > 0 THEN
    sDesc(iGames) = GetGameName$(sGames(iGames))
    iGames = iGames - 1
  END IF

  'COLOR 255: LOCATE 1, 1
  'PRINT iCur; iSel; iScroll
 
  WAIT &H3DA, 8
  iEnd = iStart + 1: IF iEnd = 5 THEN iEnd = 6
  FOR iCNT = iStart TO iEnd
    iPos = iScroll + iCNT
    IF iPos >= 0 AND iPos <= iMenuCNT THEN
      IF LEN(sDesc(iPos)) = 0 THEN
        sDesc(iPos) = GetGameName$(sGames(iPos))
      END IF
      sGameName = " " + sDesc(iPos) + " "
      iY = 122 + iCNT * 10
      iX = 128 - (LEN(sGameName) * 4)
      PUT (0, iY), BackText(iCNT * LineSz), PSET
      DrawText iX, iY + 1, sGameName, ((iCNT <> iCur) OR 3)
      IF iCNT = iCur THEN
        LINE (iX, iY)-(iX + (LEN(sGameName) * 8) - 1, iY), 255
      END IF
    END IF
  NEXT iCNT
  iStart = iStart + 2
  IF iStart >= 6 THEN
    PUT (248, 122), ImgScroll(0), PSET
    iButY = 132 + ((50 * iScroll) \ iScrOver)
    IF (iButY + iScrSz) > 181 THEN iButY = 181 - iScrSz
    LINE (248, iButY)-(255, iButY + iScrSz), 254, BF

    IF iSel <> iOldSel THEN
      IF ABS(TIMER - dUpdateTimer) > .1 THEN
        dUpdateTimer = TIMER: iOldSel = iSel
        UpdateThumb sGames(iSel)
      END IF
    END IF

    iStart = 0
  END IF
 
  sKey = INKEY$
  IF LEN(sKey) THEN
    SELECT CASE sKey
    CASE CHR$(0) + "H"
      IF iCur > 0 THEN
        iCur = iCur - 1
      ELSE
        IF iScroll > 0 THEN iScroll = iScroll - 1
      END IF
      IF iSel > 0 THEN iSel = iSel - 1
    CASE CHR$(0) + "P"
      iTemp = 6: IF iTemp > iMenuCNT THEN iTemp = iMenuCNT
      IF iCur < iTemp THEN
        iCur = iCur + 1
      ELSE
        IF iScroll <= iScrMax THEN iScroll = iScroll + 1
      END IF
      IF iSel < iMenuCNT THEN iSel = iSel + 1
    CASE "0" TO "9", "A" TO "Z", "a" TO "z"
      SearchGame sKey
    CASE CHR$(27)
      'try
      '  TempFile = FREEFILE
      '  OPEN "PosMenu.bat" FOR OUTPUT AS #TempFile
      '  PRINT #TempFile, "@del PosMenu.bat"
      '  CLOSE #TempFile
      'iResu = Catch(0)
      EXIT DO
    CASE CHR$(13)
      TempFile = FREEFILE
      try
        OPEN sGames(iSel) + "\play.bat" FOR INPUT AS #TempFile
      iResu = Catch(0)
      IF iResu = 0 THEN
        CLOSE #TempFile
        try
          OPEN "PosMenu.bat" FOR OUTPUT AS #TempFile
          PRINT #TempFile, "cd " + sGames(iSel)
          PRINT #TempFile, "call play"
          PRINT #TempFile, "cd .."
          PRINT #TempFile, "menu.bat" + STR$(iSel)
          CLOSE #TempFile
        iResu = Catch(0)
        EXIT DO
      ELSE
        SOUND 1000, 4
      END IF
    END SELECT
  END IF
  
LOOP

SCREEN 0: WIDTH 80, 25
RESET: SYSTEM

GameList:
DATA LSL6,MMMX,NMAREV2,RAPTOR,SETTLERS
DATA TIM2,WACKY,WARCRAFT,XATAX

ErrorCatch:
iError = 1
RESUME NEXT

FUNCTION Catch (iX AS INTEGER)
  Catch = iError
  ON ERROR GOTO 0
  iError = 0
END FUNCTION

FUNCTION CreateGameList (sOutArray() AS STRING)
  DIM iList AS INTEGER, iCount AS INTEGER, iMax
  DIM sFile AS STRING, sLine AS STRING, sTemp AS STRING

  iList = FREEFILE
  sFile = STR$((TIMER * 18.2) MOD 65536)
  sFile = "x" + MID$(sFile, 2) + "x.lst"
 
  try
    SHELL "dir /ad >" + sFile
    OPEN sFile FOR INPUT AS #iList
  iResu = Catch(0)
  IF iResu THEN CreateGameList = 0: EXIT FUNCTION

  REDIM sOutArray(7) AS STRING
  iMax = 7: iCount = 0
 
  WHILE NOT EOF(iList)
    LINE INPUT #iList, sTemp
    DO
      IF LEN(sTemp) = 0 THEN EXIT DO
      iPos = INSTR(1, sTemp, CHR$(10))
      IF iPos THEN
        sLine = LEFT$(sTemp, iPos - 1)
        sTemp = MID$(sTemp, iPos + 1)
      ELSE
        sLine = sTemp: sTemp = ""
      END IF

      sLine = LTRIM$(UCASE$(sLine))
      IF INSTR(1, sLine, "<DIR>") THEN
        iPos = INSTR(1, sLine, " ")
        IF iPos THEN sLine = LEFT$(sLine, iPos - 1)
        IF sLine <> "." AND sLine <> ".." THEN
          IF iCount > iMax THEN
            iMax = iMax + 8: RedimPreserve sOutArray(), iMax
          END IF
          sOutArray(iCount) = sLine
          iCount = iCount + 1
        END IF
      END IF

    LOOP
  WEND
  
  CLOSE #iList
  try
    KILL sFile
  iResu = Catch(0)

  IF iCount THEN
    iCount = iCount - 1
    RedimPreserve sOutArray(), iCount
    DO
      iFound = 0
      FOR iCNT = 0 TO iCount - 1
        IF sOutArray(iCNT) > sOutArray(iCNT + 1) THEN
          SWAP sOutArray(iCNT), sOutArray(iCNT + 1)
          iFound = 1
        END IF
      NEXT iCNT
    LOOP WHILE iFound
  END IF
  CreateGameList = iCount

END FUNCTION

SUB DrawText (iX AS INTEGER, iY AS INTEGER, sText AS STRING, iMode AS INTEGER)
  iLen = LEN(sText)
  IF iLen < 1 THEN EXIT SUB ELSE IF iLen > 39 THEN EXIT SUB
  IF iX < 0 OR iY < 0 OR iX > 255 OR iY > 191 THEN EXIT SUB
  LOCATE 25, 1: COLOR 255: PRINT sText;
  iSz = iLen * 8: IF (iX + iSz) > 319 THEN iSz = 319 - iX
  IF iMode = 3 THEN PUT (0, 192), WhiteRect(0), XOR
  GET (0, 192)-(iSz - 1, 199), TextBuff(0)
  SELECT CASE iMode
  CASE 0: PUT (iX, iY), TextBuff(0), PSET
  CASE 1: PUT (iX, iY), TextBuff(0), PRESET
  CASE 2: PUT (iX, iY), TextBuff(0), AND
  CASE ELSE: PUT (iX, iY), TextBuff(0), OR
  END SELECT
        
END SUB

FUNCTION GetGameName$ (sGameDir AS STRING)
  DIM sName AS STRING * 37, sFileName
  DIM iFile AS INTEGER
  DIM BmpHead AS BmpHeader

  iFile = FREEFILE
  sFileName = sGameDir + "\SSthumb.bmp"

  try
    OPEN sFileName FOR INPUT AS #iFile
  iResu = Catch(0)
  IF iResu THEN
    GetGameName$ = sGameDir
    EXIT FUNCTION
  END IF
  CLOSE #iFile

  OPEN sFileName FOR BINARY ACCESS READ AS #iFile
  IF LOF(iFile) > 1024 THEN
    GET #iFile, LEN(BmpHead) + (240 * 4) + 1, sName
  END IF
  CLOSE #iFile
  IF ASC(sName) = 36 THEN
    iPosi = 4
    FOR iCNT = 5 TO LEN(sName) STEP 4
      MID$(sName, iPosi, 3) = MID$(sName, iCNT, 3)
      iPosi = iPosi + 3
    NEXT iCNT
    iPosi = INSTR(2, sName, "$")
    IF iPosi THEN
      GetGameName$ = MID$(sName, 2, iPosi - 2)
    ELSE
      GetGameName$ = MID$(sName, 2)
    END IF
  ELSE
    GetGameName$ = sGameDir
  END IF
END FUNCTION

SUB LoadBitmap (sFileName AS STRING, iTarget() AS INTEGER, lPalOut() AS LONG, iStartOut AS INTEGER)

  DIM iFileSz AS INTEGER, lFileSz AS LONG
  DIM OldHead AS SavHeader, NewHead AS SavHeader
  DIM BmpHead AS BmpHeader

  iFile = FREEFILE
  
  try
    OPEN sFileName FOR INPUT AS #iFile
  iResu = Catch(0)
  IF iResu THEN iStartOut = -1: EXIT SUB
 
  CLOSE #iFile: OPEN sFileName FOR BINARY AS #iFile
  lFileSz = LOF(iFile)
  IF lFileSz < LEN(BmpHeader) THEN
    CLOSE #iFile
    iStartOut = -1
    EXIT SUB
  END IF

  IF lFileSz > 32767 THEN iFileSz = lFileSz - 65536 ELSE iFileSz = lFileSz
 
  REDIM iTarget(lFileSz \ 2) AS INTEGER
  NewHead.sCheck = CHR$(253)
  NewHead.iSeg = VARSEG(iTarget(LBOUND(iTarget)))
  NewHead.iPtr = VARPTR(iTarget(LBOUND(iTarget))) + 7
  NewHead.iSz = iFileSz - 7
                      
  GET #iFile, 1, BmpHead
  FOR iCNT = 0 TO 255
    GET #iFile, , lPalOut(iCNT)
    lPalOut(iCNT) = ((lPalOut(iCNT) \ 4) AND &H3F3F3F)
  NEXT iCNT

  DEF SEG = VARSEG(lPalOut(0))
  lPtr = VARPTR(lPalOut(0))
  FOR iCNT = 0 TO 255
    IB = PEEK(lPtr): iR = PEEK(lPtr + 2)
    POKE lPtr, iR: POKE lPtr + 2, IB
    lPtr = lPtr + 4
  NEXT iCNT

  GET #iFile, 1, OldHead
  PUT #iFile, 1, NewHead
  CLOSE #iFile
 
  DEF SEG = NewHead.iSeg
  BLOAD sFileName, NewHead.iPtr
  OPEN sFileName FOR BINARY AS #iFile
  PUT #iFile, 1, OldHead
  CLOSE #iFile
 
  iStartOut = ((BmpHead.lData \ 2) - 2)
  iTarget(iStartOut) = BmpHead.lWidth * 8
  iTarget(iStartOut + 1) = BmpHead.lHeight

END SUB

SUB RedimPreserve (sArray() AS STRING, iNewSize AS INTEGER)
  iOldSz = UBOUND(sArray)
  IF iNewSize < 0 OR iNewSize = iOldSz THEN EXIT SUB
  IF iNewSize < iOldSz THEN iOldSz = iNewSize
  REDIM sTempArray(iOldSz)
  FOR iCNT = 0 TO iOldSz
    sTempArray(iCNT) = sArray(iCNT)
  NEXT iCNT
  REDIM sArray(iNewSize) AS STRING
  FOR iCNT = 0 TO iOldSz
    sArray(iCNT) = sTempArray(iCNT)
  NEXT iCNT
  ERASE sTempArray
END SUB

SUB SearchGame (sSearchLetter AS STRING)
  sChar = UCASE$(LEFT$(sSearchLetter, 1))
  iPosi = iSel: iFound = -1
  DO
    iPosi = iPosi + 1
    IF iPosi > iMenuCNT THEN iPosi = 0
    IF iPosi = iSel THEN EXIT DO
    IF LEN(sDesc(iPos)) = 0 THEN
      sDesc(iPos) = GetGameName$(sGames(iPos))
    END IF
    IF UCASE$(LEFT$(sDesc(iPosi), 1)) = sChar THEN
      iFound = iPosi: EXIT DO
    END IF
  LOOP
  IF iFound = -1 THEN SOUND 16384, 1: EXIT SUB
  iSel = iFound
  IF iSel < 0 OR iSel > iMenuCNT THEN iSel = 0
  IF iSel < iScroll OR iSel > (iScroll + 6) THEN iScroll = iSel - 3
  IF iScroll < 0 THEN iScroll = 0
  IF iScroll > (iScrMax + 1) THEN iScroll = (iScrMax + 1)
  iCur = iSel - iScroll
END SUB

SUB SetMode256x200
  SCREEN 13

  iVal = (&H63 + &H0) OR &H0 'R_COM,R_W256,R_H200

  OUT &H3C2, iVal
  OUT &H3D4, &H11: OUT &H3D4 + 1, &HE

  RESTORE HorRegs256
  FOR iCNT = 0 TO 6
    READ iLow, iHigh
    OUT &H3D4, iLow: OUT &H3D4 + 1, iHigh
  NEXT iCNT
  RESTORE VerRegs200
  FOR iCNT = 0 TO 7
    READ iLow, iHigh
    OUT &H3D4, iLow: OUT &H3D4 + 1, iHigh
  NEXT iCNT

  OUT &H3D4, &H8: OUT &H3D4 + 1, &H0 'vert.panning = 0

  OUT &H3D4, &H14: OUT &H3D4 + 1, &H40'chain 4
  OUT &H3D4, &H17: OUT &H3D4 + 1, &HA3
  OUT &H3C4, &H4: OUT &H3C4 + 1, &HE
  
  OUT &H3C4, &H1: OUT &H3C4 + 1, &H1
  OUT &H3C4, &H2: OUT &H3C4 + 1, &HF 'enable writing to all planes
  OUT &H3CE, &H5: OUT &H3CE + 1, &H40'256 color mode
  OUT &H3CE, &H6: OUT &H3CE + 1, &H5 'graph mode & A000-AFFF

  iVoid = INP(&H3DA) 'reset 3C0
  OUT &H3C0, &H30: OUT &H3C0, &H41
  OUT &H3C0, &H33: OUT &H3C0, &H0

  FOR iCNT = 0 TO 15 'EGA PAL
    OUT &H3C0, iCNT: OUT &H3C0, iCNT
  NEXT iCNT

  OUT &H3C0, &H20

END SUB

SUB StartupGui
  PALETTE USING lBackPal(0)
  LoadBitmap "back2.bmp", iBack(), lBackPal(), iBackStart
  IF iBackStart < 0 THEN PRINT "Failed to load bitmap.": END

  PUT (0, 0), iBack(iBackStart), PSET
  REDIM iBack(((256 * 120 + 4) \ 2)) AS INTEGER
  LINE (48, 0)-(207, 119), 255, B, &H3333
  FOR iCNT = 1 TO 117 STEP 2
    LINE (49, iCNT)-(206, iCNT), 0, , &H5555
    LINE (49, iCNT + 1)-(206, iCNT + 1), 0, , &HAAAA
  NEXT iCNT
  DrawText 96, 56, "No Image", -1
  GET (48, 0)-(207, 119), iBack(0)

  FOR iCNT = 0 TO 6
    iY = 122 + iCNT * 10
    GET (0, iY)-(247, iY + 8), BackText(iCNT * LineSz)
  NEXT iCNT
  LINE (0, 192)-(255, 199), 255, BF
  GET (0, 192)-(255, 199), WhiteRect(0)

  DrawText 248, 122, CHR$(219), -1: DrawText 248, 124, CHR$(219), -1
  DrawText 248, 132, CHR$(177), -1: DrawText 248, 134, CHR$(177), -1
  DrawText 248, 142, CHR$(177), -1: DrawText 248, 144, CHR$(177), -1
  DrawText 248, 152, CHR$(177), -1: DrawText 248, 154, CHR$(177), -1
  DrawText 248, 162, CHR$(177), -1: DrawText 248, 164, CHR$(177), -1
  DrawText 248, 172, CHR$(177), -1: DrawText 248, 174, CHR$(177), -1
  DrawText 248, 182, CHR$(219), -1: DrawText 248, 184, CHR$(219), -1
  GET (248, 122)-(255, 191), ImgScroll(0)

END SUB

SUB try
 iError = 0
 ON ERROR GOTO ErrorCatch
END SUB

SUB UpdateThumb (sDirName AS STRING)
  LoadBitmap sDirName + "\SSthumb.bmp", iThumb(), lThumbPal(), iThumbStart
  WAIT &H3DA, 8
  IF iThumbStart < 0 THEN
    PUT (48, 0), iBack(0), PSET
    PALETTE USING lBackPal(0)
    EXIT SUB
  END IF
  FOR CNT = 240 TO 255
    lThumbPal(CNT) = lBackPal(CNT)
  NEXT CNT
  PALETTE USING lThumbPal(0)
  PUT (48, 0), iThumb(iThumbStart), PSET
  LINE (48, 0)-(207, 119), 255, B, &H5555
END SUB

