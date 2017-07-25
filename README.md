# iphoneipa-resign

Resigns an iPhone .ipa with your own signing certificate

## Dependencies
Currently depends on iResign.py. Please install it with python's pip module first!
To install pip, use the following command:

```
sudo easy_install pip
```

Then install iResign:
```
sudo pip install iResign
```


## Usage
```
./resign.sh <ipafile> <mobileprovisionfile>
```

Example:
```
./resign.sh $HOME/Downloads/HelpDiabetes.ipa $HOME/Downloads/bjorningewildcard.mobileprovision

```

 Instructions for generating/downloading mobileprovisionfiles can be found online at the following location: https://calvium.com/how-to-make-a-mobileprovision-file/

