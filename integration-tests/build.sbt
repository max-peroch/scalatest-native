import com.typesafe.sbt.packager.Keys.scriptClasspath
import com.typesafe.sbt.packager.docker.{Cmd, DockerPermissionStrategy, ExecCmd}

Universal / mappings := {
  val itJar = (IntegrationTest / packageBin).value
  val compileDeps = (Compile / fullClasspath).value
  val itDeps = (IntegrationTest / dependencyClasspath).value
  itDeps.diff(compileDeps).map(_.data).map(dep => dep -> s"lib/${dep.getName}") ++
    (Compile / dependencyClasspath).value.map(_.data).map(dep => dep -> s"lib/${dep.getName}") :+
    (itJar -> s"lib/${itJar.getName}")
}
scriptClasspath := Seq("*")
Docker / packageName := s"${(LocalProject("root") / name).value}-${name.value}"
Docker / version := "latest"
Docker / dockerGroupLayers := PartialFunction.empty
dockerBaseImage := "graalvm-base:latest"
dockerPermissionStrategy := DockerPermissionStrategy.CopyChown
dockerEntrypoint := Seq()
dockerCommands ++= Seq(
  ExecCmd(
    "RUN",
    "native-image",
    "--static",
    "--no-server",
    "--no-fallback",
    "--libc=musl",
    "--install-exit-handlers",
    "--allow-incomplete-classpath",
    "-H:ConfigurationFileDirectories=conf",
    "-H:Name=/opt/docker/scalatest",
    "-H:IncludeResourceBundles=org.scalatest.ScalaTestBundle",
    "-cp",
    "lib/*",
    "org.scalatest.tools.Runner"
  ),
  ExecCmd(
    "RUN",
    "/app/upx-3.96-amd64_linux/upx",
    "-7",
    s"${(Docker / defaultLinuxInstallLocation).value}/scalatest"
  ),
  // TODO: This works
  ExecCmd(
    "ENTRYPOINT",
    "java",
    "-cp", "lib/*", "org.scalatest.tools.Runner", "-w", organization.value, "-eDF", "-R",
    s"lib/${(IntegrationTest / packageBin).value.getName}"
  ),
  // TODO: This doesn't. Comment out the entrypoint above and uncomment everything else below to test
  //  Cmd("FROM", "scratch"),
  //  Cmd(
  //    "COPY",
  //    "--from=mainstage",
  //    s"${(Docker / defaultLinuxInstallLocation).value}/scalatest",
  //    "/scalatest"
  //  ),
  //  Cmd(
  //    "COPY",
  //    "--from=mainstage",
  //    s"${(Docker / defaultLinuxInstallLocation).value}/lib",
  //    "/lib"
  //  ),
  //  ExecCmd(
  //    "ENTRYPOINT",
  //    "/scalatest",
  //    "-Dconfig.resource=reference.conf",
  //    "-w",
  //    organization.value,
  //    "-eDF",
  //    "-R",
  //    s"/lib/${(IntegrationTest / packageBin).value.getName}"
  //  )
)
