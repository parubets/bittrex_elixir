defmodule BittrexElixir.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(Bittrex.Api.Transport, []),
    ]
    opts = [strategy: :one_for_one, name: BittrexElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
