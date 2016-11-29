# Usage
acdcli amazon cloud drive tool on alpine linux
```
docker run -it --name acdcli -v ~/.cache/acd_cli:/cache -v /yourdata:/data babim/acdcli
```
Amazon Cloud Drive will mount to /cloud (default) and this container share /cloud over Webdav
`-e CLOUDPATH=/cloud`

If not have uid and gid option. ACD_CLI with run in uid 1000 add uid and gid option
or set 0 to run with root
```
-e auid="0" -e agid="0"
```
I you want use https proxy
```
-e PROXY=https://test.lan:8443
```
If want mount
`--privileged`

volume -v
```
CONFIGPATH default: /cache
CACHEPATH default: /cache
```
Read/write (default is false)
`-e READWRITE=true`
