defmodule Plexy.LoggerTest do
  use ExUnit.Case, async: true

  alias Plexy.Logger
  import ExUnit.CaptureLog

  test "logs with keyword lists" do
    logged = capture_log(fn ->
      Logger.debug(foo: 1, test: "bar")
    end)

    assert logged =~ "foo=1"
    assert logged =~ "test=bar"
  end

  test "logs regular strings" do
    logged = capture_log(fn ->
      Logger.debug("foo=bar")
    end)

    assert logged =~ "foo=bar"
  end

  test "logs strings with spaces inside of quotes" do
    logged = capture_log(fn ->
      Logger.debug(foo: "bar baz")
    end)

    assert logged =~ "foo=\"bar baz\""
  end

  test "logs counts for a given metric" do
    logged = capture_log(fn ->
      Logger.count(:foo, 1)
    end)

    assert logged =~ "count#plexy.foo=1"
  end

  test "logs counts for a given metric, assuming the count is one" do
    logged = capture_log(fn ->
      Logger.count(:foo)
    end)

    assert logged =~ "count#plexy.foo=1"
  end

  test "logs time elapsed for given code block" do
    logged = capture_log(fn ->
      Logger.measure(:sleeping, fn ->
        :timer.sleep(100)
      end)
    end)

    assert logged =~ "measure#plexy.sleeping=1"
  end

  test "redacts configured keys" do
    logged = capture_log(fn ->
      Logger.debug(password: "mystuff")
    end)

    assert logged =~ "password=REDACTED"
  end

  test "filters configured keys" do
    logged = capture_log(fn ->
      Logger.debug(secret: "mystuff")
    end)

    refute logged =~ "secret"
  end
end
