connection: "@{CONNECTION_NAME}"
label: "Retail Application"

# View Includes
# include: "/views/**/*.view" # include all the views

# Explore Includes
include: "/explores/*.explore"
# Dashboard Includes
include: "/dashboards/*.dashboard.lookml" # include all the dashboards


# Value formats:
named_value_format: currency_k {
  value_format: "\"@{MAIN_CURRENCY_SYMBOL}\"#,##0.0,\" K\""
}
named_value_format: currency {
  value_format: "\"@{MAIN_CURRENCY_SYMBOL}\"#,##0.00"
}
named_value_format: currency_0 {
  value_format: "\"@{MAIN_CURRENCY_SYMBOL}\"#,##0"
}
named_value_format: unit_k {
  value_format: "#,##0.0,\" K\""
}

# Datagroups:

datagroup: daily {
  sql_trigger: SELECT CURRENT_DATE() ;;
  max_cache_age: "24 hours"
}

datagroup: weekly {
  sql_trigger: SELECT EXTRACT(WEEK FROM CURRENT_DATE()) ;;
}

datagroup: monthly {
  sql_trigger: SELECT EXTRACT(MONTH FROM CURRENT_DATE()) ;;
}

datagroup: forever {
  sql_trigger: SELECT 1 ;;
}
