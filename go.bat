@echo off
cd rustris
cargo build
set err=%errorlevel%
cd ..
if %err% neq 0 goto end
python testris.py rustris\target\debug\rustris.exe
:end
