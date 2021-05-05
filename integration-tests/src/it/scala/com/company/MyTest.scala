package com.company

import com.typesafe.config.{Config, ConfigFactory}
import org.scalatest._
import flatspec._
import matchers._

class MyTest extends AnyFlatSpec with should.Matchers {

  "MyTest" should "read from reference.conf" in {
    val config: Config = ConfigFactory.load()
    val testKey: String = config.getString("value")
    testKey shouldBe "test"
  }
}
