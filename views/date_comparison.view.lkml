view: date_comparison {
  extension: required

  filter: date_comparison_filter {
    view_label: "Date Comparison 📅"
    type: date
  }

  parameter: comparison_type {
    view_label: "Date Comparison 📅"
    type: unquoted
    allowed_value: {
      label: "Current year only"
      value: "current"
    }
    allowed_value: {
      label: "Year"
      value: "year"
    }
    allowed_value: {
      label: "Week"
      value: "week"
    }
    default_value: "current"
  }

  dimension: selected_comparison {
    view_label: "Date Comparison 📅"
    sql: {% if comparison_type._parameter_value == "year" %}
    ${this_year_vs_last_year}
    {% elsif comparison_type._parameter_value == "week" %}
    ${this_week_vs_last_week}
    {% else %}
    0
    {% endif %};;
  }

  dimension: this_year_vs_last_year {
    view_label: "Date Comparison 📅"
    type: string
    sql: CASE
      WHEN {% condition date_comparison_filter %} ${transaction_raw} {% endcondition %} THEN 'This Year'
      WHEN ${transaction_raw} >= TIMESTAMP(DATE_ADD(CAST({% date_start date_comparison_filter %} AS DATE), INTERVAL -1 YEAR)) AND ${transaction_raw} < TIMESTAMP(DATE_ADD(CAST({% date_end date_comparison_filter %} AS DATE), INTERVAL -1 YEAR)) THEN 'Prior Year'
    END;;
  }

  dimension: this_week_vs_last_week {
    view_label: "Date Comparison 📅"
    type: string
    sql: CASE
      WHEN {% condition date_comparison_filter %} ${transaction_raw} {% endcondition %} THEN 'This Week'
      WHEN ${transaction_raw} >= TIMESTAMP(DATE_ADD(CAST({% date_start date_comparison_filter %} AS DATE), INTERVAL -1 WEEK)) AND ${transaction_raw} < TIMESTAMP(DATE_ADD(CAST({% date_end date_comparison_filter %} AS DATE), INTERVAL -1 WEEK)) THEN 'Prior Week'
    END;;
  }
}
