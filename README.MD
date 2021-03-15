

## BUILD AND PUSH

```bash
docker build -t registry.lvh.me:5000/gjuljo/election .
```

``` bash
docker push registry.lvh.me:5000/gjuljo/election
```

## INSTALL AND UNINSTALL

```bash
helm upgrade -i -n spid election chart
```

```bash
helm uninstall -n spid election
```

```bash
curl http://election.lvh.me
```

## TESTING IN K3D

```bash
curl http://election.lvh.me
```

```bash
for i in {1..10}; do curl http://election.lvh.me; sleep 1; done
```

```bash
while true; do curl http://election.lvh.me; sleep 1; echo ""; done
```
