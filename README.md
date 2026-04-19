# My Dotfiles Generator

This project generates my personal dotfiles.

This project updates existing settings or generate a new settings files.
It keeps a back up of the old version.

Go to [`demo`](demo) for example settings files generated.

## How to Use This Project
The script will ask you where the VS Code settings directory lies.

Optionally, if you have existing settings directory that is inaccessible from this script, you can copy them in any accesible directory and run this script.

Run the following:
```
./generate-vscode-settings.py
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
