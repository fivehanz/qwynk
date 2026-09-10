defmodule Qwynk.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Owned by the application master process, so it lives as long as the app.
    Qwynk.Traffic.Cache.init()

    children = [
      QwynkWeb.Telemetry,
      Qwynk.Repo,
      {DNSCluster, query: Application.get_env(:qwynk, :dns_cluster_query) || :ignore},
      {Task.Supervisor, name: Qwynk.TaskSupervisor},
      {Phoenix.PubSub, name: Qwynk.PubSub},
      # Start a worker by calling: Qwynk.Worker.start_link(arg)
      # {Qwynk.Worker, arg},
      # Start to serve requests, typically the last entry
      QwynkWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :qwynk]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Qwynk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QwynkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
