# autobot
Recon scripts

## Install
1. Clone the repo inside your $HOME/opt.
    ```
    $ git clone https://github.com/nabin01/autobot.git $HOME/opt/autobot
    ```

2. Source utils.sh in your bashrc.
    ```
    $ source $HOME/opt/autobot/utils.sh
    ```

3. Create a soft link to rbot.sh on a directory in your PATH
    ```
    $ ln -s /home/username/opt/autobot/rbot.sh /home/username/bin/rbot
    $ rbot -h
    ```

## Usage
Rbot creates a directory inside your $HOME/data for each target you run. On the first run for a target, it asks you to create a inscope and outscope files.

Run rbot. 
```
$ rbot <program-name>
```