# iphoneipa-resign

Resigns an iPhone .ipa with your own signing certificate

## Dependencies
All dependencies are included, no need to install manually anymore!

## Usage, GUI version

Download the the latest zip file release from https://github.com/dabear/iphoneipa-resign/releases  and extract the app within. Open the app within. You may have to right click the app, then cmd-click "open" to be able to run it.


Download the iphone app you want to resign together with the mobileprovisionfile from apple. Drag and drop both the iphone .ipa and .mobileprovisionfile to the Resign IPA app


<img width="759" alt="screenshot_25_07_2017__21_30" src="https://user-images.githubusercontent.com/442324/28590603-fdf24326-7182-11e7-8370-fa8859205b76.png">

You will now get two new files. If anything went wrong, consult the resignlog.txt file for details
![image](https://user-images.githubusercontent.com/442324/28590667-43f0d824-7183-11e7-840c-bb06c050ffb5.png)



## Usage, command line version

Download or clone this repository to your Mac. Open a command line and change directory to where you downloaded this app, then run:
```
./resign.sh <ipafile> <mobileprovisionfile>
```

Example:
```
./resign.sh $HOME/Downloads/HelpDiabetes.ipa $HOME/Downloads/bjorningewildcard.mobileprovision

```

 Instructions for generating/downloading mobileprovisionfiles can be found online at the following location: https://calvium.com/how-to-make-a-mobileprovision-file/

