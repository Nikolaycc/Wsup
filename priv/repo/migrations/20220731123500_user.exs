defmodule Wsup.Repo.Migrations.User do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :name, :string
      add :email, :string
      add :password, :string
      add :age, :integer

      timestamps()
    end
  end
end
