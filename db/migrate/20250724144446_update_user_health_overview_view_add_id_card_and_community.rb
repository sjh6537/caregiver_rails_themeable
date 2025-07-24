class UpdateUserHealthOverviewViewAddIdCardAndCommunity < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW user_health_overview AS
      SELECT
        users.id AS user_id,
        users.name AS user_name,
        users.id_card AS user_id_card,
        users.phone AS user_phone,
        users.address AS user_address,
        users.birthday AS user_birthday,
        communities.name AS community_name,
        reports.id AS report_id,
        reports.bmi,
        reports.heart_rate,
        reports.blood_pressure1,
        reports.blood_pressure2,
        reports.blood_sugar,
        reports.blood_oxygen,
        reports.body_fat,
        reports.temperature,
        reports.hemoglobin,
        reports.hematocrit,
        reports.uric_acid,
        reports.total_cholesterol,
        reports.weight,
        reports.ketones,
        reports.created_at AS report_created_at
      FROM
        users
      JOIN
        user_health_reports AS reports ON users.id = reports.user_id
      LEFT JOIN
        communities ON communities.id = users.community_id;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE VIEW user_health_overview AS
      SELECT
        users.id AS user_id,
        users.name AS user_name,
        users.phone AS user_phone,
        users.address AS user_address,
        users.birthday AS user_birthday,
        reports.id AS report_id,
        reports.bmi,
        reports.heart_rate,
        reports.blood_pressure1,
        reports.blood_pressure2,
        reports.blood_sugar,
        reports.blood_oxygen,
        reports.body_fat,
        reports.temperature,
        reports.hemoglobin,
        reports.hematocrit,
        reports.uric_acid,
        reports.total_cholesterol,
        reports.weight,
        reports.ketones,
        reports.created_at AS report_created_at
      FROM
        users
      JOIN
        user_health_reports AS reports ON users.id = reports.user_id;
    SQL
  end
end
