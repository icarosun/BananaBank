defmodule BananaBankWeb.AccountsControllerTest do
  use BananaBankWeb.ConnCase

  import Mox

  alias BananaBank.Accounts
  alias BananaBank.Users
  alias Users.User
  alias Accounts.Account

  setup do
    params = %{
      "name" => "Joao",
      "cep" => "29650000",
      "password" => "123456",
      "email" => "joao@frutas.com"
    }

    body =
      %{
        "bairro" => "",
        "cep" => "29650-000",
        "complemento" => "",
        "ddd" => "27",
        "estado" => "Espírito Santo",
        "gia" => "",
        "ibge" => "3204609",
        "localidade" => "Santa Teresa",
        "logradouro" => "",
        "regiao" => "Sudeste",
        "siafi" => "5691",
        "uf" => "ES",
        "unidade" => ""
      }

    {:ok, %{user_params: params, body: body}}
  end

  describe "create/2" do
    test "successfully creates an account", %{conn: conn, body: body, user_params: params} do
      expect(BananaBank.ViaCep.ClientMock, :call, fn "29650000" -> {:ok, body} end)

      {:ok, %User{id: id}} = Users.create(params)

      account_params = %{
        "balance" => "10",
        "user_id" => id
      }

      response =
        conn
        |> post(~p"/api/accounts", account_params)
        |> json_response(:created)

      assert %{
               "data" => %{"balance" => "10", "id" => _account, "user_id" => ^id},
               "message" => "Conta criado com sucesso!"
             } = response
    end
  end

  describe "transaction/2" do
    test "successfully creates an account", %{conn: conn, body: body, user_params: params} do
      expect(BananaBank.ViaCep.ClientMock, :call, 2, fn "29650000" -> {:ok, body} end)

      {:ok, %User{id: from_user_id}} = Users.create(params)
      {:ok, %User{id: to_user_id}} = Users.create(params)

      {:ok, %Account{id: from_account_id}} =
        Accounts.create(%{
          "balance" => "10",
          "user_id" => from_user_id
        })

      {:ok, %Account{id: to_account_id}} =
        Accounts.create(%{
          "balance" => "100",
          "user_id" => to_user_id
        })

      params_transaction = %{
        "from_account_id" => from_account_id,
        "to_account_id" => to_account_id,
        "value" => 10
      }

      response =
        conn
        |> post(~p"/api/accounts/transaction", params_transaction)
        |> json_response(:created)

      assert %{
               "from_account" => %{"balance" => "0", "id" => ^from_account_id, "user_id" => ^from_user_id},
               "message" => "Transferência realizada com sucesso",
               "to_account" => %{"balance" => "110", "id" => ^to_account_id, "user_id" => ^to_user_id}
             } = response
    end
  end
end
