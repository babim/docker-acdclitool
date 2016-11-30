[![](https://images.microbadger.com/badges/image/babim/acdcli.svg)](https://microbadger.com/images/babim/acdcli "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/babim/acdcli.svg)](https://microbadger.com/images/babim/acdcli "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/babim/acdcli:single.svg)](https://microbadger.com/images/babim/acdcli:single "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/babim/acdcli:single.svg)](https://microbadger.com/images/babim/acdcli:single "Get your own version badge on microbadger.com")

[![](https://images.microbadger.com/badges/image/babim/acdcli:webdav.svg)](https://microbadger.com/images/babim/acdcli:webdav "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/babim/acdcli:webdav.svg)](https://microbadger.com/images/babim/acdcli:webdav "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/babim/acdcli:webdav.single.svg)](https://microbadger.com/images/babim/acdcli:webdav.single "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/babim/acdcli:webdav.single.svg)](https://microbadger.com/images/babim/acdcli:webdav.single "Get your own version badge on microbadger.com")

# Usage
acdcli amazon cloud drive tool on alpine linux
```
docker run -it --name acdcli -v ~/.cache/acd_cli:/cache -v /yourdata:/data -v /cloudmount:/cloud babim/acdcli
```
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
