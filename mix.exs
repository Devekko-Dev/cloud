defmodule Cloud.MixProject do
  use Mix.Project

  def project do
    [
      app: :cloud,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      aliases: aliases(),
      deps: deps(),
      releases: [
        cloud: [
          applications: [runtime_tools: :permanent],
          include_executables_for: [:unix],
          build_host_ssh: System.get_env("BUILD_HOST_SSH"),
          deploy_hosts_ssh: System.get_env("DEPLOY_HOSTS_SSH"),
          steps: [
            &Horizon.Ops.BSD.Step.setup/1,
            :assemble,
            :tar
          ],
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Cloud.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ex_money_sql, "~> 1.0"},
      {:bcrypt_elixir, "~> 3.0"},
      {:picosat_elixir, "~> 0.2"},
      {:open_api_spex, "~> 3.0"},
      {:ash_cloak, "~> 0.1"},
      {:cloak, "~> 1.0"},
      {:ash_paper_trail, "~> 0.4"},
      {:ash_archival, "~> 1.0"},
      {:ash_double_entry, "~> 1.0"},
      {:ash_state_machine, "~> 0.2"},
      {:ash_admin, "~> 0.12"},
      {:ash_csv, "~> 0.9"},
      {:ash_money, "~> 0.1"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_authentication, "~> 4.0"},
      {:ash_sqlite, "~> 0.2"},
      {:ash_postgres, "~> 2.0"},
      {:ash_json_api, "~> 1.0"},
      {:ash_graphql, "~> 1.0"},
      {:ash_phoenix, "~> 2.0"},
      {:ash, "~> 3.0"},
      {:igniter, "~> 0.5"},
      {:phoenix, "~> 1.7.18"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
#      {:horizon, "~> 0.2", runtime: false},
      {:horizon, path: "lib/cloud/deps/horizon", only: [:dev, :gpu], override: true},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"}
    ]
  end

  @tailwindcss_freebsd_x64 "https://people.freebsd.org/~dch/pub/tailwind/v$version/tailwindcss-$target"

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],

      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],

      "assets.setup.freebsd": [
        "tailwind.install #{@tailwindcss_freebsd_x64}",
        "esbuild.install --if-missing"
       ],

      "assets.build": ["tailwind cloud", "esbuild cloud"],
      "assets.deploy": [
        "tailwind cloud --minify",
        "esbuild cloud --minify",
        "phx.digest"
      ]
    ]
  end
end
