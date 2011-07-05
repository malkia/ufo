@IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" ("%~dpn064.cmd" %*) ELSE ("%~dpn032.cmd" %*)



