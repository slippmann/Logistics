@ECHO OFF

SET data="*.dzn"

FOR /R %%A IN (%data%) DO (
  ECHO %%~nxA
  minizinc logistics_test.mzn %%~nxA
  ECHO.
  ECHO.
)

PAUSE