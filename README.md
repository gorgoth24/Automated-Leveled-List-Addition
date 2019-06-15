![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1556486257-489146781.png "Title")

## Mod Page
[LE]( https://www.nexusmods.com/skyrim/mods/98170?tab=description "oldrim")
[SE]( https://www.nexusmods.com/skyrimspecialedition/mods/25395?tab=description&BH=0 "special edition")


# Introduction
You've just downloaded a sweet armor mod off the nexus and realized it's only available via a crafting recipe or a single dinky chest in Riverwood.  You want it to show up naturally in your game but lack the knowledge or, more likely, the willpower to manually add it to all the appropriate leveled lists.  You've come to the right place.

Automated Leveled List Addition is an aptly named xEdit script that reduces all aspects of item integration to a single click.  Wait! If this mod is so simple why are there so many goddamn buttons?!?  I've created a [video]( https://www.youtube.com/watch?v=p0yVEmFrhh4&feature=youtu.be ) covering the features explained below but **~90+% of users will only ever need the 'OK' button**. 

This script is like a Bashed/Smashed Patch for items. This mod doesn't replace Bashed/Smashed Patches. It doesn't have any compatibility issues with Lootification. It's not replacing anything.  This is a totally new tool offering something not found anywhere else.


# Frequently Asked Questions
How does this mod differ from Bashed/Smashed Patches? This script makes items compatible with leveled lists. A Bashed/Smashed Patch then makes leveled lists compatible with each other.

How does this mod differ from a mod like [Lootification](https://www.nexusmods.com/skyrimspecialedition/mods/10970)?  Lootification uses a script that runs in-game, while you are playing Skyrim, to manipulate leveled lists. The changes made by this mod are more stable, more compatible, and have more options than mods like Lootification. But, unlike Lootification, this mod isn't plug-and-play. It's a tool to help someone of any skill level make sensible edits to existing mods.

How does this mod differ from [SkyAI](https://www.nexusmods.com/skyrimspecialedition/mods/17111)? My mod is similar to SkyAI but adds to all leveled lists (instead of just vendors) and generates enchanted versions/recipes.


![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1556487213-1536771392.png "Features")
### **Automated Leveled List Addtion**
  - Supports all mod-added lists
  - Supports all vanilla equipable items including Weapons, Armor, Clothes, and Jewelry
  - Supports mod-added slots like capes, multi-part armor, accessory slots, etc.
  - Supports Male/Female-Only armors with a keyword
### **Automated Generation of Enchanted Versions**
  - Enchanted items are added to the appropriate lists
  - Supports all vanilla enchantments
  - Supports many mod-added enchantments, including [Wintermyst](https://www.nexusmods.com/skyrimspecialedition/mods/18603) and [Summermyst](https://www.nexusmods.com/skyrimspecialedition/mods/6285)
  - Options menu for %Chance, Enchantment strength, configurable tier levels, and more
### **Automated Recipe Creation**
  - Creates crafting, tempering, and breakdown recipes
  - Supports all item types above
  - Options menu to configure recipes, scaling, and more
### **QOL Functions**
  - 'Remove' function for easy load order changes
  - 'Patch' function to simplify compatibility patches
  - 'Bulk' function to process multiple plugins en masse


![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1556535934-1182812305.png "Installation")
### Download
**note:** This is an xEdit script
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1556540460-1355078843.png "Download")
### Open
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1556541455-2007623751.png "Open")
### Drag and Drop
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1556542019-1287907144.png "Drag and Drop")
### Done


![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1556546039-644201739.png "Detailed Info")
## NORMAL USERS DO **NOT** NEED TO KNOW THE INFORMATION IN THIS SECTION


The mod is specifically designed so that all a normal user needs to do is press 'Ok'.  
  The graphics are for power users who want to do something specific.
    'How it works' is technical information intended for mod authors.


### 0. [Main Menu <-- Click to jump to this section in the video](https://youtu.be/p0yVEmFrhh4?t=119)
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560454004-693498490.png)
### 1. [Currently Selected Records](https://youtu.be/p0yVEmFrhh4?t=203)
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560386407-765214485.png)
#### How it works: 
This menu will allow you to select which item you are editing in this menu and other menus.  This menu also allows you to change the relevant game values of the currently selected record.  Changes to the game values and/or the Male/Female-Only script are saved when switching between items or when the 'Ok' button is pressed.

The Male/Female-Only script will add the mesh for the vanilla counterpart of this item to the opposite gender.  For example, say this script is run on female-only armor with a 'Daedric' level armor value.  Any male characters that wear this armor will look like they are wearing vanilla Daedric armor.  Any female characters that wear this armor will still use the custom female-only armor mesh.

Alternatively, you could add the 'FemaleOnly' keyword or add 'FemaleOnly' to the armor EditorID and this script will automatically run as part of normal script operations.  This would save you from having to check this check box a million times.  The FemaleOnly keyword's FormID does not matter - the script checks the name of the keyword for 'FemaleOnly' (if you don't know what this sentence means don't worry, it's not important).  'MaleOnly' works the same way.

Like many other aspects of this mod, which mesh is assigned to the opposite gender is based on the **Item Template**.  Information on how to change the template can be found in the *(3) Automated Leveled List Addition How it works section* and the corresponding *(3) Automated Leveled List Addition* section of the video.
### 2. [Output Plugins](https://youtu.be/p0yVEmFrhh4?t=321)
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560397354-1153904955.png)
#### How it works:
**Output Plugins** can be set individually for the three main sections of the script.  If the plugin is not detected it will be created.  There's a confirmation box to make sure you don't accidentally dump everything into a typo.  Additionally, the default **Output Plugins** can be set in the 'Settings' section at the top of the code for those looking to avoid re-entering plugin names every time the script is run.
### 3. [Automated Leveled List Addition](https://youtu.be/p0yVEmFrhh4?t=390)
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560438657-1173161184.png)
#### How it works:

**Current Lists** is a list of all the leveled lists that **Selected Item** will be added to.  The script populates **Current Lists** by comparing the **Selected Item** to the [vanilla tiers](https://en.uesp.net/wiki/Skyrim:Armor) (including changes like those made in [WACCF](https://www.nexusmods.com/skyrimspecialedition/mods/18994)).  Weapons, Armor, and Jewelry use Damage, Armor, and Gold Value respectively when determining appropriate leveled lists.  Clothing does not have a vanilla tier system and will be assigned to one of the basic 'farm clothes' sets at random. 

**Example:** A sword with iron levels of damage will be added to all leveled lists that use the vanilla Iron Sword.  

Non-primary slots (items that are not a Helmet, Gauntlets, Torso, Boots, or Shield) prioritize vanilla keywords like 'ClothingHands' when determining appropriate lists.  If a recognizable keyword is not found, a non-primary slot item will be associated with a default primary slot. 

**Example:** Slot 131 is associated with the head.  Without an overriding keyword like 'ClothingBody', a slot 131 item would be associated with slot 30, the helmet slot, when determining appropriate lists.

A complete list of supported armor slots can be found on [this page](http://wiki.tesnexus.com/index.php/Skyrim_bodyparts_number).  A list of the default slot associations can be found on this page.

[* Set Template Item (Advanced)](https://youtu.be/p0yVEmFrhh4?t=480) Opens a menu that lets you manually set the template item. 

Understanding what a template is and how to set a custom template is really important for Mod Authors to get the most out of this script.  Most of the script is based on a single function: GetTemplate.  This function returns a vanilla equivalent of an item that serves as the basis for leveled list addition, enchantment generation, and COBJ creation.  

Example: You're creating a mod that adds new silver weapons so that each damage tier gets its own silver weapon.  GetTemplate runs on a silver sword that has iron levels of damage.   GetTemplate returns 'Iron Sword' from vanilla Skyrim as a template.  The script runs using the vanilla 'Iron Sword' as a template.  Your item will be added to any leveled list containing the vanilla 'Iron Sword'.  It will also have any enchantments 'Iron Sword' has and have a crafting recipe similar to 'Iron Sword'.

But what if I don't want to add a new item for the player?  What if I want to add a new kind of armor to the Falmer of Skyrim?  The easiest way to accomplish this is to set a custom template.  Press * to open the custom template menu and select 'Custom' from the Item Type drop down.  Then use the drop downs to find vanilla Falmer armor in Skyrim.esm and click 'Ok'.  Run the script.  Like the above example your armor will appear in any leveled list that the vanilla Falmer Armor would appear.  It will also have any enchantments the vanilla Falmer Armor has and have a crafting recipe similar to Falmer Armor.

This can also be used to quickly replicate the implementation of a custom item.  Let's say you're creating a big mod and adding multiple instances of similar records to the same leveled lists.  Add the first item, Item A, to the correct leveled lists manually.  Then run this script on all the other items using Item A as a template.  Now the leveled lists that contain Item A also contain all the other records.

### 4. [Automated Generation of Enchanted Versions](https://youtu.be/p0yVEmFrhh4?t=642)
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560445306-1678580890.png)
#### How it works:
The script automatically detects supported plugins, like [Wintermyst](https://www.nexusmods.com/skyrimspecialedition/mods/18603) and [Summermyst](https://www.nexusmods.com/skyrimspecialedition/mods/6285), and [Generates Enchanted Versions](https://www.nexusmods.com/skyrimspecialedition/mods/21595?tab=posts) based on the type of item.  Enchanted versions are added to the leveled lists by replacing any instance of the original item with a leveled list that has **Percent Chance** for an enchanted item. 

Example: The script runs on an Iron Sword.  **(4) Automated Generation of Enchanted Versions** creates a leveled list of enchanted versions (Iron Sword of Frost, Iron Sword of Fire, etcetera) using the levels from **Configure Tiers** (Iron Sword of Frost IV will appear at Tier Level 04: Level 30).  This list is then added to a list with 9 copies of the original item and 1 copy of the enchanted list.  This results in a 90% chance for a regular item and a 10% chance for an enchanted item.  Stronger items will appear as you level up just like in vanilla Skyrim.

A full list of compatible plugins can be found in the Compatibility and Permissions seciton.  Please post if you'd like to see a new enchantment mod supported - it's often as simple as adding a single line of code.
### 5. [Crafting/Tempering/Breakdown Recipies](https://youtu.be/p0yVEmFrhh4?t=826)
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560450720-41303974.png)
#### How it works:
**Note:** If an item already have a crafting, tempering, or breakdown recipe the script will automatically skip this section.  

**Crafting Recipes** prioritize material type when deciding on ingredients.  Iron swords require iron ingots and so on.  **Recipe Scaling** is my solution to game balance issues introduced when a mod item with a low-tier material type has high damage for late-game viability.

Example: A mod's steel sword has daedric levels of damage so that it can be viable in the late game.  Since it is a steel sword it will be crafted with steel ingots.  **Recipe Scaling** increases the number of ingots required in order to preserve some semblance of game balance.  So, instead of getting a daedric-level sword out of 2 steel ingots, it'll require something like 32 steel ingots.

**Tempering Recipes** are created using a rewritten-from-scratch SkyrimUtils' makeTemperable function.  The function still works best when an item has the proper keywords but it will now generate a recipe based on an item's Armor/Damage/Value if a keyword is unavailable.  Like many other parts of the script, what item is used when keywords are unavailable is based on an item's template.  More information can be found in the **'Set Template** section of **(3) Automated Leveled List Addition**.

**Breakdown Recipes** are generated using the exact function from [Mator's Automation Tools](https://www.nexusmods.com/skyrim/mods/49373/) (with Mator's permission) that uses an item's crafting COBJ to create a recipe that gives you smithing resources from completed items.  More information on this function is available on his modpage.
### [QOL Functions](https://youtu.be/p0yVEmFrhh4?t=1000)
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560454318-1336096076.png)
#### How it works:
If you want to remove a mod from your load order without breaking the output file you first need to use the Remove function.  Remove will search **Selected File** for any record that has **Remove Plugin** as a master. 

**Example:** I want to remove **Weapons of the 3rd Era** from my mod list.  Run the script on your **Output File**, typically **Automated Leveled List Addition.esp**, and press **Remove**.  Make sure the **Selected File** is correct.  Then find **Weapons of the 3rd Era.esp** in the **Remove Plugin** list.  Finally, click **Add** to mark **Weapons of the 3rd Era.esp** for removal.  Then press 'Ok'.  You are now able to remove **Weapons of the 3rd Era** from your load order without breaking **Remove Plugin**, usually **Automated Leveled List Addition.esp**.
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560454541-277467530.png)
#### How it works:
**Patch** simplifies compatibility patch creation.  Simply complete the sentence and the script will automatically create a compatibility patch between two mods.  Feel free to upload any compatibility patch generated by this tool to the Nexus as long as credit is given.  

This function works by adding a step in normal script operations that checks if the record in question is found in **Destination File**.  All options specified in other menus should be included in the generated patch.

**Note:** I mention an issue in the video where there isn't one. Adding UUNP to Skyrim.esm would absolutely work. There's also code to handle load order issues baked into the script.
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560454764-611075290.png)
#### How it works:
**Bulk** simply allows you to specify multiple **Input Plugins** as input for the script.  Using this function will almost certainly require using the 64-bit version of xEdit in order to allocate enough memory for the script to run properly.  All supported items will be processed and dumped into a single massive output file.  **Note:** This can take an extremely long time and is hardware-dependent.  
![alt text](https://staticdelivery.nexusmods.com/mods/1704/images/25395/25395-1560458481-48101908.png)
The script will add to leveled lists based on your specific load order.  This means that re-balancing mods like [Requiem](https://www.nexusmods.com/skyrim/mods/19281), [MorrowLoot Ultimate](https://www.nexusmods.com/skyrimspecialedition/mods/3058), and [YASH](https://www.nexusmods.com/skyrim/mods/32562) are supported.  Mods that use script-injected leveled list manipulation like [Loot and Degradation](https://www.nexusmods.com/skyrimspecialedition/mods/21744) and [World's Dawn](https://www.nexusmods.com/skyrim/mods/73094) are untested; post with feedback if you use these mods.

**You have my permission to upload anything you create with the script to nexus as your own work. Credit is appreciated!**

I have Mator's permission to use some code from [Mator's Automation Tools](http://www.nexusmods.com/skyrim/mods/49373/). While all the SkyrimUtils functions I've used are re-written from scratch I still feel like I should credit SkyrimUtils for being awesome in general. I'd also like to thank Martinezer and his [Generate Enchanted Versions](https://www.nexusmods.com/skyrimspecialedition/mods/5100) script for starting this whole adventure. While the two mods no longer share code his mod is the inspiration for this mod.

Currently Supported Enchantment Mods: 
- [Wintermyst](https://www.nexusmods.com/skyrimspecialedition/mods/18603)
- [Summermyst](https://www.nexusmods.com/skyrimspecialedition/mods/6285)
- [Holy Enchantments](https://www.nexusmods.com/skyrim/mods/50439/)
- [Lost Enchantments](https://www.nexusmods.com/skyrim/mods/55590/)
- [More Interesing Loot](https://www.nexusmods.com/skyrim/mods/48869/)

