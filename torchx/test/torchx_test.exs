defmodule TorchxTest do
  use ExUnit.Case, async: true

  doctest Torchx

  alias Torchx.Backend, as: TB

  # Torch Tensor creation shortcut
  defp tt(data, type \\ {:f, 32}), do: Nx.tensor(data, type: type, backend: TB)
  defp bt(data, type \\ {:f, 32}), do: Nx.tensor(data, type: type, backend: Nx.BinaryBackend)

  defp assert_equal(tt, data, type \\ {:f, 32}),
    do: assert(Nx.backend_transfer(tt) == Nx.tensor(data, type: type))

  describe "tensor" do
    test "add" do
      a = tt([[1, 2], [3, 4]], {:s, 8})
      b = tt([[5, 6], [7, 8]])

      c = Nx.add(a, b)

      assert_equal(c, [[6.0, 8.0], [10.0, 12.0]])
    end

    test "dot" do
      a = tt([[1, 2], [3, 4]])
      b = tt([[5, 6], [7, 8]])

      c = Nx.dot(a, b)

      assert_equal(c, [[19, 22], [43, 50]])
    end
  end

  @types [{:s, 8}, {:u, 8}, {:s, 16}, {:s, 32}, {:s, 64}, {:bf, 16}, {:f, 32}, {:f, 64}]
  # , :subtract, :dot]
  @ops [:add, :subtract, :divide, :multiply]
  describe "binary ops" do
    for op <- @ops,
        type_a <- @types,
        type_b <- @types do
      test "#{op}(#{Nx.Type.to_string(type_a)}, #{Nx.Type.to_string(type_b)})" do
        a = tt([[1, 2], [3, 4]], unquote(type_a))
        b = tt([[5, 6], [7, 8]], unquote(type_b))

        c = Kernel.apply(Nx, unquote(op), [a, b])

        binary_a = Nx.backend_transfer(a, Nx.BinaryBackend)
        binary_b = Nx.backend_transfer(b, Nx.BinaryBackend)
        binary_c = Kernel.apply(Nx, unquote(op), [binary_a, binary_b])

        assert(Nx.backend_transfer(c) == binary_c)
      rescue
        e in RuntimeError ->
          IO.puts(
            "#{unquote(op)}(#{Nx.Type.to_string(unquote(type_a))}, #{
              Nx.Type.to_string(unquote(type_b))
            }): #{e.message}"
          )
      end
    end
  end
end
