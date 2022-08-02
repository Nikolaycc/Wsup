defmodule WsupTest do
  use ExUnit.Case
  doctest Wsup

  test "greets the world" do
    assert Wsup.hello() == :world
  end
end
