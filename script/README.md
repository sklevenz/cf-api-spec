# Helper Scripts

## vacuum-dashboard-z.sh

```bash
vacuum dashboard gen/openapi.yaml --ignore-file cfg/vacuum-ignore.yaml --hard-mode --watch
```

## vacuum-dashboard.sh

```bash
vacuum dashboard gen/openapi.yaml --ruleset cfg/vacuum-ruleset.yaml --ignore-file cfg/vacuum-ignore.yaml --watch
```

## vacuum-generate-ignore-rules.sh

```bash
vacuum report gen/openapi.yaml -o > gen/report.yaml -z
vacuum generate-ignorefile gen/report.yaml gen/ignore.yaml
```

Copy ignore rules from `./gen/ignore.yaml` to  `./cfg/vacuum-ignore.yaml`

