## opshview

Simple command line tools to read host/service status from OpsView

## Perl interface

`OpsView.pl` is a Perl script that connects to the OpsView REST API.

    perl OpsView.pl [-u|--username *username*] [-p|--password password]
                    [-d|--destination url] [-t|--token token] [--help]
                    command [argument ...]

The initial connection is done using the user name and password:

    perl OpsView.pl -u foo -p bar command [argument ...]

Once a connection has been open, it can be resumed by passing a unique token:

    perl OpsView.pl -u foo -t 1460e8bdd5361634fb2f7a02fdeda154ec1a0897 command [argument ...]

## Shell interface

`opsh.sh` is the command line companion of `OpsView.pl`. It spawns a sub shell once the
connection to OpsView has been established. This avoids passing the username/token for
each command.

The shell script also defines aliases and completion for the commands handled by the
Perl interface. 

## License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png" /></a><br />This work by <a xmlns:cc="http://creativecommons.org/ns#" href="https://github.com/freongrr/opshview" property="cc:attributionName" rel="cc:attributionURL">Fabien Cortina</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons Attribution-ShareAlike 3.0 Unported License</a>.
