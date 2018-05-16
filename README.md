Devkit
======
## Instalation

### Manual

If you want to test ```devkit```, download from github and source it.
```sh
$ git clone https://github.com/jeslopalo/devkit.git
...
$ cd devkit
$ source ./install.sh
```
If you want to install permanently then add ```$DEVKIT_HOME/bin``` to your ```$PATH```

### Zplug
Add to your ```packages.zsh```:

```sh
zplug jeslopalo/devkit, from:github, use:"bin/*", as:command
```

## Configuring
If you need to set a custom config file, then you can use ```devkit -c``` command.
```sh
$ devkit -c ~/path/to/file/config.json
```
