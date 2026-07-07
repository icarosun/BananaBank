defmodule BananaBank.ViaCep.Client do
  @default_url "https://viacep.com.br/ws"

  def call(url \\ @default_url, cep) do
    client = Tesla.client([{Tesla.Middleware.BaseUrl, base_url: url}, Tesla.Middleware.JSON])

    client
    |> Tesla.get("/#{cep}/json")
    |> handle_response()
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: %{"erro" => "true"}}}) do
    {:error, :not_found}
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response({:ok, %Tesla.Env{status: 400}}) do
    {:error, :bad_request}
  end

  defp handle_response({:error, _}) do
    {:error, :internal_server_error}
  end
end
