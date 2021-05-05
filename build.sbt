ThisBuild / organization := "com.company"
ThisBuild / scalaVersion := "2.12.13"

lazy val root = project
  .in(file("."))
  .settings(
    name := "scalatest-native",
    version := "0.1",
  )
  .aggregate(`integration-tests`)

lazy val `integration-tests` = project
  .in(file("integration-tests"))
  .enablePlugins(DockerPlugin)
  .configs(IntegrationTest)
  .settings(
    Defaults.itSettings,
    libraryDependencies ++= Seq(
      "org.scalatest" %% "scalatest" % "3.2.5" % IntegrationTest,
      "com.typesafe" % "config" % "1.4.0" % IntegrationTest,
      "org.scalameta" %% "svm-subs" % "20.2.0" % Compile,
    )
  )
