Trolling tutorial:

1. Go to where Buckshot Roulette is installed
2. Click into the File Explorer address bar and type "cmd", press enter.
3. Type in "Buckshot Roulette.exe" (with the quotation marks included) into the console and press enter.
4. Join a multiplayer game. When you reach the animation where it shows you the count of the lives and blanks, go back to the command prompt window and look for a text saying "sequence_in_shotgun". Should look something like this (i.e. "sequence_in_shotgun": ["blank", "blank", "live", "live", "blank", "live"]):
![image](https://github.com/user-attachments/assets/30a9a6e1-561b-40cc-9b22-ee9e3033c891)

(Since the official release of multiplayer, you can make sequence_in_shotgun appear in the console on demand by using an item

Also, manipulating multiplayer games (even when you're not the host!) using specially crafted packets is trivially easy. Just as an example, you can force anyone to shoot themselves, or always be able to steal others items. I encourage you to look through the code and figure out more exploits :)