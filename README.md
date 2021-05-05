# Run integration-tests in a Docker image

First we need to build the Docker base image
```
    make build-base 
```

Then, the integration tests image
```
    make build-tests
```

And run:
```
    make run-tests
```

To test the native image version, please see the `TODO`s in integration-tests/build.sbt