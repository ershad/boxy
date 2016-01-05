### How to add datadog-agent for basic monitoring

* Add the Datadog API key to the node:

```json
{
  "datadog": {
    "api_key": "$datadog_api_key"
  }
}
```

* The datadog API key can be obtained by logging into `https://www.datadoghq.com/` using the account credentials.

* Add datadog-agent recipe to node's run list

```json
....
  "run_list": [
    ....
      "recipe[boxy-rails::watchdog]",
    ....
  ],
....
```
