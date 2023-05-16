# Acoins
Small coin-collecting platform game developed with MIPS Assembly. Created as a final project for CSCB58.\
<img src="https://github.com/eunniie/Acoins/assets/114002081/95ef2682-50c2-461f-bec4-9dc3ff9f7452" width="400"/><img src="https://github.com/eunniie/Acoins/assets/114002081/f55381f7-5cd3-4afc-ba16-28033fbe7f2d" width="400"/>

# How To Play
- Use `WASD` to move around the map
- Press `P` to play/restart the game at any point
- Avoid the dangerous obstacles and collect all of the coins to win!


# To Set-Up
- Install Java and open the `Mars.jar` file 
- Use Mars to open the `game.asm` file
- Under `Tools` open `Bitmap Display` and `Keyboard and Display MMIO Simulator`
- Make the following configurations to `Bitmap Display`:
  - Unit width in pixels: 8 
  - Unit height in pixels: 8 
  - Display width in pixels: 512 
  - Display height in pixels: 512 
  - Base Address for Display: 0x10008000 ($gp)
- Click `Connect to MIPS` on both tools
- Assembly & run the program and type your controls in the keyboard simulator to move around

