json.array!(@wages) do |wage|
  json.extract! wage, :amount, :employee_id, :starting_date
  json.url wage_url(wage, format: :json)
end
