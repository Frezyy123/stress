defmodule StressFoundationdb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias FDB.{Database, Cluster}

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: StressFoundationdb.Worker.start_link(arg)
      # {StressFoundationdb.Worker, arg},
    ]

    :ets.new(:fdb, [:named_table, :public, read_concurrency: true])
    db = setup_fdb()
    :ets.insert(:fdb, {:db, db})
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StressFoundationdb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def setup_fdb() do
    FDB.start(600)

    Application.get_env(:stress_foundationdb, :cluster_file_path)
    |> Cluster.create()
    |> Database.create()
  end
end
