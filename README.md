# Acoins
Small coin-collecting platform game developed with MIPS Assembly. Created as a final project for CSCB58.

# How To Play
- Use `A` and `D` to move left and right and `space` to jump.
- Avoid the dangerous obstacles and collect all of the coins to win!

# To Set-Up
- Install Java and open the `Mars.jar` file 
- Use Mars to open the `game.asm` file
- Under `Tools` open `Bitmap Display` and `Keyboard and Display MMIO Simulator`
- Make the following configurations to `Bitmap Display`
  - Unit width in pixels: 8 
  - Unit height in pixels: 8 
  - Display width in pixels: 512 
  - Display height in pixels: 512 
  - Base Address for Display: 0x10008000 ($gp)
- Click `Connect to MIPS` on both tools
- Run the program and type your controls in the keyboard simulator to move around

