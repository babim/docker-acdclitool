# Usage
acdcli amazon cloud drive tool on debian
```
docker run -it --name acdcli -v ~/.cache/acd_cli:/cache -v /yourdata:/data babim/acdcli
```

If not have uid and gid option. ACD_CLI with run in uid 1000
add uid and gid option
```
-e uid="0" -e gid="0"
```
