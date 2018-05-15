Devkit
======
## Instalación

Download from github
```
$ git clone https://github.com/jeslopalo/devkit.git
```

## Development mode (manual)

1. Create a ```.environment``` file with an environment name (it will be a configuration file suffix)
2. Create a configuration file with the appropiate suffix (ie. if ```.environment``` file contains *dev*, then ```$DEVKIT_HOME/config/config-dev.json```

## Development mode (command)

* Activation: execute ```bin/devmode <environment_name>``` to activate development mode, loading ```$DEVKIT_HOME/config/config-<environment_name>.json```
* Deactivation: execute ```bin/devmode``` to deactivte development mode, loading ```$DEVKIT_HOME/config/config.json```
