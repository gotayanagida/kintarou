class CreateReportStamps < ActiveRecord::Migration[5.1]
  def change
    create_table :report_stamps do |t|
      t.references :report, foreign_key: true
      t.references :stamp, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
