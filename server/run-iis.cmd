@echo off
cd /d "%~dp0"
set ENV_FILE=.env.iis
set NODE_ENV=production
node src\index.js