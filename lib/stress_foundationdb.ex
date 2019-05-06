defmodule StressFoundationdb do
  @moduledoc """
  Documentation for StressFoundationdb.
  """

  @doc """
  Hello world.

  ## Examples

      iex> StressFoundationdb.hello()
      :world

  """
  @prefix_unique "unique_hash"

  def read do
    [{_, db}] = :ets.lookup(:fdb, :db)

    speed = get_speed() || 1

    Enum.map(1..speed, fn _ ->
      Task.async(fn ->
        FDB.Database.transact(db, fn tr ->
          date = Date.utc_today() |> Date.to_string()
          token = "token"
          hash = "hash"

          Enum.map(1..2, fn _ ->
            FDB.Transaction.get_q(tr, "#{@prefix_unique}#{date} #{token}#{hash}")
            |> FDB.Future.map(fn offer_val -> {"offer", offer_val} end)
          end)
          |> FDB.Future.all()
          |> FDB.Future.await()
        end)
      end)
    end)
    |> Enum.map(fn pid -> Task.await(pid) end)
  end

  def write do
    [{_, db}] = :ets.lookup(:fdb, :db)

    FDB.Database.transact(db, fn tr ->
      date = Date.utc_today() |> Date.to_string()
      token = "token"
      hash = "hash"

      :ok =
        FDB.Transaction.set(
          tr,
          "#{@prefix_unique}#{date} #{token}#{hash}",
          "1"
        )
    end)
  end

  def read_write() do
    [{_, db}] = :ets.lookup(:fdb, :db)

    speed = get_speed() || 10_000

    Enum.map(1..speed, fn _ ->
      Task.async(fn ->
        FDB.Database.transact(db, fn tr ->
          date = Date.utc_today() |> Date.to_string()
          token = "token"
          hash = "hash"

          FDB.Transaction.set(
            tr,
            "#{@prefix_unique}#{date} #{token}#{hash}",
            "1"
          )

          Enum.map(1..1, fn _ ->
            FDB.Transaction.get_q(tr, "#{@prefix_unique}#{date} #{token}#{hash}")
            |> FDB.Future.map(fn offer_val -> {"offer", offer_val} end)
          end)
          |> FDB.Future.all()
          |> FDB.Future.await()
        end)
      end)
    end)
    |> Enum.map(fn pid -> Task.await(pid) end)
  end

  def get_speed() do
    Application.get_env(:stress_foundationdb, :speed)
  end
end
