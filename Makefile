build-base:
	docker build -t graalvm-base:latest .

build-tests:
	sbt "integration-tests / docker:publishLocal"

run-tests:
	docker run --rm scalatest-native-integration-tests:latest
