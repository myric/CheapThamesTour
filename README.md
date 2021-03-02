# Cheap Thames Tour

A simple, cheap tour along the Thames, utilizing an ESP32's joystick and Google StreetView imagery from commercial ferries and tourboats.

# The Story

As lockdown eases, London begins to heal, and its fauna return to the pubs, streets, and river. Ferries and the Uber boat begin to ply the river once again, carting bankers and tourists to and fro. Zipping among the ferries you see a number of inflatable jetboats also vying for the returning tourists. You eye them, but your family is drawn to the large BUDGET sign at one grimly rundown dock. The boat looks like it should have been left to rust and you can definitely see some exposed wires, but the owner is offering a hell of a bargain and everyone likes a good deal, right? He looks a little sweaty, though, as he tells you to keep your hands and feet inside the boat at all times and, "Please, please, do not touch the green button."

# What It Does

The script opens with the view of a bow looking down the river, a little ways above Lambeth Bridge. The switch turns the boat on (as can be seen by the LED on the control and the bowlights turning on onscreen). Once the boat is on, the joystick controls movement down and up the river, while the red button switches the view around to see back up the river. Although not strictly realistic for a "jetboat" the stern is animated with the same image as the bow, in a nod to the common double-ended European riverboats that line the Thames as well as its tributary canals and remaining quays. To differentiate, a white stern light is animated in place of the red-green bowlight when the view is reversed.

The last item is the green button, which has no obvious effect when pressed. What it does do is start increasing the probability that aliens will appear with each frame change. This will continue increasing until either 100% probability, or until the button is pressed again, which will trigger the probability to start decreasing until they no longer appear.

# How It Works

This repo contains code for both an ESP32 and for the Processing sketch. The ESP32 takes in input from the joystick, buttons, and switch, controls the LED (responding to the switch), and formats a serial message. Wiring for this can be found via Freenove's tutorials and Arduino's educational materials.

The repo also contains the source images in the Assets folder: this contains 52 images, screencapped from Google Maps Street View showing for and aft views at 26 locations along the river. Additionally, there is a transparent cutout of a boat's bow and another of a flying saucer complete with mysterious beam.

The Processing script loads the images into an array (this takes a few moments on a laptop and quite a bit more on the Raspberry Pi). It displays starting at 1 and overlays with the bow. When the boat is "turned on", the script draws glowing bow lights or stern lights depening on orientation.

# Replication

Other than the wiring diagrams, all that would be needed would be to ascertain the serial port your machine is reading from. Something more robust might be able to test multiple ports to find the one sending the right strings, but this script does not do that at this point.
