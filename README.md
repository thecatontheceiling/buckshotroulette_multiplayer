This code is really messy and it's P2P which means it's *extremely trivial* to cheat. I don't know why Mike thought this was a good idea. If public matchmaking is added, then it will be a shitshow.

All of the bullets in the shotgun are stored in the "sequence_in_shotgun" variable and you can mod the game to display this variable on-screen so you will **always** know what the next bullets are:
https://github.com/thecatontheceiling/buckshotroulette_multiplayer/blob/f817f018045457a09b5c03e12606353dda2b3b8f/global%20scripts/MP_RoundManager.gd#L423
![image](https://github.com/user-attachments/assets/2a60fb9b-9cef-4062-ac58-2a75dc2b59d6)


There's likely other things you can do like sending malformed packets to mess with other people but I didn't bother trying that out myself.
