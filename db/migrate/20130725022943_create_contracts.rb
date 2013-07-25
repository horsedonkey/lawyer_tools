class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.text :original
      t.text :undefined_terms

      t.timestamps
    end
  end
end
