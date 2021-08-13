# Mario vs Luigi Infinite

This Project is a fangame / remake of the Game Mode "Mario vs Luigi" from New Super Mario Bros. DS.

## Features

The Game features mostly the same things given in the Original game.
Some things, like the Twister in the Ice Level or the Blue Shell Item, don't exist yet.

Additional Features:
* Up to 4 Players
* Custom Levels
* Fast Pipes
* PAW Block (Destroys Blocks around it)
* Hammer Item from SMB3
* A few Splitscreen configurations
* SMB and SMB Lost Levels Graphics
* And more

## Download Version 0.9.5

You can download pre-compiled Versions here.
* Windows https://drive.google.com/file/d/1mvQEN4Sl3N_z92DzboGILa6rwu5NWvcP/view?usp=sharing
* Linux https://drive.google.com/file/d/1hIY0XRCmfN-EC8OZ3qJzwVbbDc79p3AL/view?usp=sharing
* MAC OS (untested) https://drive.google.com/file/d/15-z6fH5Srzsku51ixpi09cuoojEjWzaF/view?usp=sharing

# Development

The Project runs smoothly in Godot 3.2.3 mono, which i suggest for working with this project. (Should work without mono too)
I haven't tested higher Godot Versions, but i ran into Problems when i upgraded from 3.1 to 3.2.3.

## Levels

The easiest thing to Implement are Levels.
You just..
* duplicate (Copy+Paste) one of the existing Levels from the "Levels" Folder (like "CustomL_UnnamedX.tscn") edit that level as you wish
* Beware: Blocks should be in the Block Node, Enemies in the Enemy node, Star Spawns in it's Node and so forth
* There isn't a clear Documentation for Levels, but all of this is managed in Misc/BigStar.gd (respawning Level Parts)
You don't really have to read that - you just have to implement the levels similar to the existing ones
* After that, add the Level Path to the Array in Levels/Levels.gd, along with a Path of a Screenshot of the Level and a Name

Now the Level should appear in the Level-Choosing Menu and is ready to be played!
