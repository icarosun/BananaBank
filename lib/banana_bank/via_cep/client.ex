defmodule BananaBank.ViaCep.Client do
  def call(cep) do
    client = Tesla.client([{Tesla.Middleware.BaseUrl, "https://viacep.com.br/ws"}, Tesla.Middleware.JSON])

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

  defp handle_response({:ok, %Tesla.Env{status: 400}}) do
    {:error, :internal_server_error}
  end
end
