TDK
===
## Instalación

Download from github
```
$ git clone https://github.com/jeslopalo/tdk.git
```

## Development mode (manual)

1. Create a ```.environment``` file with an environment name (it will be a configuration file suffix)
2. Create a configuration file with the appropiate suffix (ie. if ```.environment``` file contains *dev*, then ```$TDK_HOME/config/config-dev.json```

## Development mode (command)

* Activation: execute ```bin/devmode <environment_name>``` to activate development mode, loading ```$TDK_HOME/config/config-<environment_name>.json```
* Deactivation: execute ```bin/devmode``` to deactivte development mode, loading ```$TDK_HOME/config/config.json```
