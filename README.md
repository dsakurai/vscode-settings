# My VSCode Settings

This project generates my personal VSCode settings.
It can update existing settings or create a new one.
It keeps a back up of the old version.

Optionally, if you have existing settings directory that is inaccessible from this script, you can copy them in any accesible directory and run this script.

Run the following:
```
./generate-vscode-settings.sh
```

This will ask a few questions on the output directory and setting values.

## Demo

The following command will generate the default settings in the [`demo`](demo) directory.
```
./generate-vscode-settings.sh -d
```

## Maintenance

Run 
```
./generate-vscode-settings.sh -d
```
and add the generated settings file in git.
