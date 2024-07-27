DECLARE FUNCTION GetGameName$ (sGameDir AS STRING)
DEFINT A-E, G-K, M-O, Q-R, T-Z
DEFLNG L, P
DEFSTR S

'$INCLUDE: 'Types.bas'

sDirName = RTRIM$(LTRIM$(COMMAND$))
IF sDirName = "" THEN sDirName = "."
sFileName = sDirName + "\SSthumb.bmp"
ON ERROR GOTO Failed
OPEN sFileName FOR INPUT AS #1: CLOSE #1
ON ERROR GOTO 0
PRINT GetGameName$(sDirName)
END

Failed:
PRINT "Not Found: '" + sFileName + "'"
END



FUNCTION GetGameName$ (sGameDir AS STRING)
  DIM sName AS STRING * 52, sFileName
  DIM iFile AS INTEGER
  DIM BmpHead AS BmpHeader

  iFile = FREEFILE
  sFileName = sGameDir + "\SSthumb.bmp"
  OPEN sFileName FOR INPUT AS #iFile
  CLOSE #iFile
  OPEN sFileName FOR BINARY ACCESS READ AS #iFile
  IF LOF(iFile) > 1024 THEN
    GET #iFile, LEN(BmpHead) + (240 * 4) + 1, sName
  END IF
  CLOSE #iFile
  'PRINT "<" + sName + ">", LEN(sName)
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

