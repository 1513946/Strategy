README

SimuroSot5: SimuroSot Miro-Middle Game

========================== 

This is the 2023 FIRA SimuroSot Miro-Middle Game platform.

OS: Windows 7 or later version.
Development Environment: Visual Studio 2010.

1. Installation
You can go to: https://github.com/zerowind168/SIM5-exe/raw/master/SIM5Installation.exe to download the Installation package.

2.Run the program 
Running SimuroSot5.exe will start the platform.

3. File Explaination
3.1 The file structure
[c:\Strategy]
 ......[blue]
        .......Team1.dll
 ......[yellow]
        .......Team2.dll
 ......SimuroSot5.exe
 ......WorldModel.exe
 ......Referee.dll
 ......Strategy4Blue.dll
 ......Strategy4Yellow.dll
 ......[src]
       ......[Strategy4Blue]
       ......[Strategy4Yellow]

3.2 details explaination for the files
1. SimuroSot5.exe
This is the start-up program. When it is running, it will start all the necessary program. After started, click the "Start" button on the dialog will start the game.You can pause the game by clicking the "Pause" button, and you can exit the game by clicking the "Close" button.

2. WorldModel.exe
This is the original platform for middle league SimuroSot. It runs the world model for the game. WorldModel.exe is designed by Moon, Dr Jun Jo, Michael Pagano, Anthony, Greg Cranitch, Karen Noller (in no particular order).We would like to thank them for their great contributions.


3. Referee.dll
This is the computer referee module for judging the ongoing situations.

4. Strategy4Blue.dll
This is the team for blue side. Strategy developers need to replace it with their own developed team, but they must keep the same file name. There is a template for developing, Strategy4Blue folder holds all the needed files.

5. Strategy4Yellow.dll
This is the team for yellow side. Strategy developers need to replace it with their own developed team, but they must keep the same file name. There is a template for developing, Strategy4Yellow folder holds all the needed files.
