# Arcade-Stargate_MiSTer
Arcade Stargate for MiSTer 

-- Arcade: Stargate, by Funkycochise
-- based on Robotron port to MiSTer by oldgit, Sorgelig 
-- https://github.com/MiSTer-devel/Arcade-Robotron_MiSTer
-- Additional credits :
-- gen_ram.vhd
-- Copyright 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
-- cpu09l - Version : 0128 
-- Synthesizable 6809 instruction compatible VHDL CPU core 
-- Copyright (C) 2003 - 2010 John Kent
-- cpu68 - Version 9th Jan 2004 0.8 
-- 6800/01 compatible CPU core 
-- GNU public license - December 2002 : John E. Kent
-- 
-- This port is only possible because of previous work by many many others - Thank You 
-- to find out more search "Williams robotron" on a search engine.
--
-- 
-- Keyboard players inputs :
-- F10 : Advance (if you stuck at boot on message "Factory Settings restored", just hit F10)
-- F1 / 1 : Start 1
-- F2 / 2 : Start 2
-- F3 / 5 : Coin
-- Arrow Up : Up
-- Arrow Down : Down
-- Arrow Left/right : thust
-- Ctrl / W : Fire
-- Alt / A : Smartbomb
-- Space : Reverse
-- Shift : Inviso
-- D / 1 / F1 : Hyperspace
-- S : Thrust

-- Joystick remap support
--

                            *** Attention ***

ROMs are not included. In order to use this arcade, you need to provide a correct ROM file.

    Add the required zipped rom file to the rom folder in releases.
    Execute bat file - it will show the name of zip file containing required files.
    Find this zip file somewhere. You need to find the file exactly as required. 
	Do not rename other zip files even if they also replresent the same game - they are not compatible! 
	The name of zip is taken from M.A.M.E. project, so you can get more info about hashes and contained files there.
    If everything goes without errors or warnings, then you will get the rom file.
    Place the rom file into root of SD card together with the .rbf file.
