# Usage
acdcli amazon cloud drive tool on alpine linux
```
docker run -it --name acdcli -v ~/.cache/acd_cli:/cache -v /yourdata:/data -v /cloudmount:/cloud babim/acdcli
```
If not have uid and gid option. ACD_CLI with run in uid 1000 add uid and gid option
```
-e auid="0" -e agid="0"
```
