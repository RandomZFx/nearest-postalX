# Nearest PostalsX

This is a modified version of DevBlocky's [Nearest Postals Script](https://github.com/DevBlocky/nearest-postal/) to add a UI and extra features, while still keeping support for any already created jsons for postals. File name should still be the same nearest-postal and installation instruction should follow the same!

## New Features

* Added Ability to use UI or just basic native to config
* Added Commands to hide and show UI
* Ability to move UI's location, stored within the client sided (persistent between restarts)

## Command

To draw a route to a certain postal, type `/postal [postalName]` and to remove just type `/postal`

It will automatically remove the route when within 100m of the destination

Some Added commands would:

- `/postalon` - Toggle postal UI ON
- `/postaloff` - Toggle postal UI OFF
- `/editpostal` - Move the UI Component (press ESC while in edit mode to exit mode)


## Development

This script provides a simple way of working on a new postal map

1. In the resource `fxmanifest.lua` file, uncomment the `cl_dev.lua` requirement line
2. Do `refresh` and `restart nearest-postal` in-game
3. Teleport to the first postal code in numerical order
4. Type `/setnext [postalCode]` where postalCode is the postal that you are at
5. Type `/next` to insert it
6. Teleport to the next postal code in numerical order
7. Type `/next` to insert it
8. Repeat from step 6 on

If you make a mistake, you can either remove a specific postal using `/remove [postalCode]` or remove the last postal inserted with `/rl` (this will decrease the next value also)

When done with that, you can print all of the postals you just inserted into console with the `/json` command and then copy it from your `CitizenFX.log` file


