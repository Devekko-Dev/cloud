defmodule Cloud.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CloudWeb.Telemetry,
      Cloud.Repo,
      {DNSCluster, query: Application.get_env(:cloud, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Cloud.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Cloud.Finch},
      # Start a worker by calling: Cloud.Worker.start_link(arg)
      # {Cloud.Worker, arg},
      # Start to serve requests, typically the last entry
      CloudWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cloud.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CloudWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
