# moinapp-cli

*The command line interface for moin*

# Usage

Print out the help:
```bash
$ moin
```

## SignUp/Login

SignUp for a new account:
```bash
$ moin --create <USERNAME> --password <PASSWORD> --email <GRAVATAR-EMAIL>
```

Login with your existing credentials:
```bash
$ moin --login <USERNAME> --password <PASSWORD>
```

## Get user info

*You need to login before you can use this method.*

```bash
$ moin --get <USERNAME>
```

## Send a moin

*You need to login before you can use this method.*

```bash
$ moin <USERNAME>
```
