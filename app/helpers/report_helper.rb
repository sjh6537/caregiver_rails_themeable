module ReportHelper
  def format_health_report(report)
    text = "你有一份新的健康報告：\n\n"
    text += "#{I18n.t('Table.Measure_Time')}: #{report.measure_time}\n"
    text += "#{I18n.t('Table.BMI')}: #{report.bmi}\n" if report.bmi.present?
    text += "#{I18n.t('Table.Weight')}: #{report.weight}\n" if report.weight.present?
    text += "#{I18n.t('Table.Temperature')}: #{report.temperature}\n" if report.temperature.present?
    text += "#{I18n.t('Table.Blood_Pressure1')}: #{report.blood_pressure1}\n" if report.blood_pressure1.present?
    text += "#{I18n.t('Table.Blood_Pressure2')}: #{report.blood_pressure2}\n" if report.blood_pressure2.present?
    text += "#{I18n.t('Table.Heart_Rate')}: #{report.heart_rate}\n" if report.heart_rate.present?
    text += "#{I18n.t('Table.Blood_Sugar')}: #{report.blood_sugar}\n" if report.blood_sugar.present?
    text += "#{I18n.t('Table.Blood_Oxygen')}: #{report.blood_oxygen}\n" if report.blood_oxygen.present?
    text += "#{I18n.t('Table.Hemoglobin')}: #{report.hemoglobin}\n" if report.hemoglobin.present?
    text += "#{I18n.t('Table.Hematocrit')}: #{report.hematocrit}\n" if report.hematocrit.present?
    text += "#{I18n.t('Table.Uric_Acid')}: #{report.uric_acid}\n" if report.uric_acid.present?
    text += "#{I18n.t('Table.Ketones')}: #{report.ketones}\n" if report.ketones.present?
    text += "#{I18n.t('Table.Total_Cholesterol')}: #{report.total_cholesterol}\n" if report.total_cholesterol.present?
    text += "#{I18n.t('Table.Measure_Time')}: #{report.measure_time}\n" if report.measure_time.present?
    text
  end

  def format_fitness_report(report)
    text = "你有一份新的運動報告：\n\n"
    text += "#{I18n.t('Table.Measure_Time')}: #{report.report_date}\n" if report.exercise_type.present?
    text += "#{I18n.t('Table.Exercise_Type')}: #{report.exercise_type}\n" if report.exercise_type.present?
    text += "#{I18n.t('Table.Fitness_Device')}: #{report.fitness_device.name}\n" if report.fitness_device.present?
    text += "#{I18n.t('Table.Start_Time')}: #{report.start_time}\n" if report.start_time.present?
    text += "#{I18n.t('Table.End_Time')}: #{report.end_time}\n" if report.end_time.present?
    text += "#{I18n.t('Table.Duration')}: #{report.duration}\n" if report.duration.present?
    text += "#{I18n.t('Table.Intensity')}: #{report.intensity}\n" if report.intensity.present?
    text += "#{I18n.t('Table.Calories_Burned')}: #{report.calories_burned}\n" if report.calories_burned.present?
    text
  end
end
