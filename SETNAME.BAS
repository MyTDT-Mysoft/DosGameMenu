DECLARE FUNCTION TRIM$ (sTemp$)
DECLARE FUNCTION GetGameName$ (sGameDir AS STRING)
DEFINT A-E, G-K, M-O, Q-R, T-Z
DEFLNG L, P
DEFSTR S

'$INCLUDE: 'Types.bas'

DIM sNameOut AS STRING, sFilename AS STRING
DIM sOut AS STRING, sDesc AS STRING
DIM iFile AS INTEGER
DIM BmpHead AS BmpHeader

sCmd = TRIM$(COMMAND$): sFolder = "": sDesc = ""
IF LEFT$(sCmd, 1) = CHR$(34) THEN
  iTemp = INSTR(2, sCmd, CHR$(34))
  IF iTemp THEN
    sDesc = TRIM$(MID$(sCmd, iTemp + 1))
    sFolder = MID$(sCmd, 2, iTemp - 2)
  END IF
ELSE
  iTemp = INSTR(2, sCmd, " ")
  IF iTemp THEN
    sDesc = TRIM$(MID$(sCmd, iTemp + 1))
    sFolder = TRIM$(LEFT$(sCmd, iTemp - 1))
  END IF
END IF

IF sFolder = "" OR sDesc = "" THEN
  PRINT "Usage: SETNAME " + CHR$(34) + "folder" + CHR$(34) + " GAME NAME"
  PRINT "Ex:"
  PRINT "SETNAME " + CHR$(34) + "mygame" + CHR$(34) + " This is my game"
  PRINT "SETNAME " + CHR$(34) + "." + CHR$(34) + " current folder game"
  PRINT "SETNAME " + CHR$(34) + "c:\game" + CHR$(34) + " game over another folder"
  END
END IF
IF LEFT$(sDesc, 1) = CHR$(34) THEN sDesc = MID$(sDesc, 2)
IF RIGHT$(sDesc, 1) = CHR$(34) THEN sDesc = LEFT$(sDesc, LEN(sDesc) - 1)
sDesc = LCASE$(LTRIM$(RTRIM$(LEFT$(sDesc, 35))))
iStart = 1
DO
  MID$(sDesc, iStart, 1) = UCASE$(MID$(sDesc, iStart, 1))
  iStart = INSTR(iStart + 1, sDesc, " ")
  IF iStart = 0 THEN EXIT DO
  iStart = iStart + 1
LOOP
iStart = 1
DO
  MID$(sDesc, iStart, 1) = UCASE$(MID$(sDesc, iStart, 1))
  iStart = INSTR(iStart + 1, sDesc, "^")
  IF iStart = 0 THEN EXIT DO
  sDesc = LEFT$(sDesc, iStart - 1) + MID$(sDesc, iStart + 1)
LOOP
FOR iN = 1 TO LEN(sDesc)
  IF MID$(sDesc, iN, 1) = "_" THEN MID$(sDesc, iN, 1) = " "
NEXT iN
sDesc = TRIM$(sDesc): sOut = sDesc
sFilename = sFolder + "\SSthumb.bmp"

iFileChk = 1: iFile = FREEFILE
ON ERROR GOTO zzError
OPEN sFilename FOR INPUT AS #iFile
CLOSE #iFile
ON ERROR GOTO 0
iFileChk = 0

OPEN sFilename FOR BINARY AS #iFile
IF LOF(iFile) < 1024 THEN
  PRINT "SSthumb.bmp too small (not valid/corrupted?)"
  END
END IF

sDesc = "$" + sDesc + "$": sName = ""
FOR iCNT = 1 TO LEN(sDesc) STEP 3
  sNameOut = sNameOut + MID$(sDesc, iCNT, 3) + CHR$(0)
NEXT iCNT
sNameOut = sNameOut + STRING$(64 - LEN(sNameOut), 0)

PUT #iFile, LEN(BmpHead) + (240 * 4) + 1, sNameOut
CLOSE #iFile
PRINT "Name Set to: [" + sOut + "]"
END

zzError:
IF iFileChk THEN
  PRINT "Failed to open '" + sFilename + "'"
  PRINT "First parameter must be path to the game or a ."
  END
END IF
iERR = ERR: iERRL = ERRL
PRINT "Error. ("; iERR; "/"; iERRL; ")"
END

FUNCTION GetGameName$ (sGameDir AS STRING)
  DIM sName AS STRING * 52, sFilename
  DIM iFile AS INTEGER
  DIM BmpHead AS BmpHeader

  iFile = FREEFILE
  sFilename = sGameDir + "\SSthumb.bmp"
  OPEN sFilename FOR INPUT AS #iFile
  CLOSE #iFile
  OPEN sFilename FOR BINARY ACCESS READ AS #iFile
  IF LOF(iFile) > 1024 THEN
    GET #iFile, LEN(BmpHead) + (240 * 4) + 1, sName
  END IF
  CLOSE #iFile
  PRINT "<" + sName + ">", LEN(sName)
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

FUNCTION TRIM$ (sTemp$)
  TRIM$ = LTRIM$(RTRIM$(sTemp$))
END FUNCTION

