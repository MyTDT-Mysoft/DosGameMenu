DEFINT A-Z
DEFLNG L, P
DEFSNG F
DEFSTR S

TYPE SavHeader
  sCheck AS STRING * 1
  iSeg  AS INTEGER
  iPtr  AS INTEGER
  iSz   AS INTEGER
END TYPE


TYPE BmpHeader
  sBM     AS STRING * 2
  lSize   AS LONG
  iRes1   AS INTEGER
  iRes2   AS INTEGER
  lData   AS LONG
  lDibSz  AS LONG
  lWidth  AS LONG
  lHeight AS LONG
  iPlanes AS INTEGER
  iBits   AS INTEGER
  lComp   AS LONG
  lImgSz  AS LONG
  lHres   AS LONG
  lVres   AS LONG
  lPalCnt AS LONG
  lUsage  AS LONG
END TYPE

