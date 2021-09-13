include: "./customer_facts.view"

view: customer_clustering_input {
  derived_table: {
    sql: SELECT *
    ,DATE_DIFF(CURRENT_DATE(),CAST(customer_first_purchase_date AS DATE),MONTH) AS months_customer_tenure
    FROM ${customer_facts.SQL_TABLE_NAME} ;;
  }
}

view: customer_clustering_model {
  derived_table: {
    datagroup_trigger: monthly
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='kmeans',
        num_clusters=4) AS
      SELECT
         * EXCEPT(customer_id)
      FROM ${customer_clustering_input.SQL_TABLE_NAME};;
  }
}

view: customer_clustering_prediction_base {
  label: "Customer Clusters 👤"
  derived_table: {
    datagroup_trigger: monthly
    sql: SELECT * EXCEPT (nearest_centroids_distance) FROM ml.PREDICT(
      MODEL ${customer_clustering_model.SQL_TABLE_NAME},
      (SELECT * FROM ${customer_clustering_input.SQL_TABLE_NAME}));;
  }
}

view: customer_clustering_prediction {
  derived_table: {
    datagroup_trigger: monthly
    sql: WITH customer_clustering_prediction_aggregates AS (SELECT
      CENTROID_ID,
      AVG(customer_average_basket_size ) AS average_basket_size,
      AVG(customer_lifetime_transactions ) AS average_number_of_transactions,
      AVG(customer_lifetime_quantity ) AS average_total_quantity,
      AVG(customer_lifetime_sales ) AS average_total_sales,
      AVG(months_customer_tenure) AS average_customer_tenure,
      COUNT(DISTINCT customer_id) AS customer_count
      FROM ${customer_clustering_prediction_base.SQL_TABLE_NAME}
      GROUP BY 1
    ), customer_clustering_prediction_centroid_ranks AS (SELECT
      centroid_id,
      RANK() OVER (ORDER BY average_customer_tenure asc) as average_tenure_rank,
      RANK() OVER (ORDER BY average_customer_tenure desc) as inverse_average_tenure_rank,
      RANK() OVER (ORDER BY average_basket_size desc) as average_basket_size_rank,
      RANK() OVER (ORDER BY average_total_sales desc) as average_total_sales_rank
      FROM customer_clustering_prediction_aggregates
    )
    SELECT customer_clustering_prediction_base.*
      ,CASE
        WHEN customer_clustering_prediction_centroid_ranks.inverse_average_tenure_rank = 1 THEN 'Loyal Customers'
        WHEN customer_clustering_prediction_centroid_ranks.average_tenure_rank = 1 THEN 'New Joiners'
        WHEN customer_clustering_prediction_centroid_ranks.average_basket_size_rank = 1 THEN 'Big-basket Shoppers'
        WHEN customer_clustering_prediction_base.centroid_id IS NOT NULL THEN 'Mid-tier Customers'
        ELSE NULL
      END AS customer_segment
    FROM ${customer_clustering_prediction_base.SQL_TABLE_NAME} customer_clustering_prediction_base
    JOIN customer_clustering_prediction_centroid_ranks
      ON customer_clustering_prediction_base.centroid_id = customer_clustering_prediction_centroid_ranks.centroid_id;;
  }

  dimension: centroid_id {
    type: number
    hidden: yes
    sql: ${TABLE}.CENTROID_ID ;;
  }

  dimension: customer_id {
    hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: customer_segment {
    type: string
    sql: ${TABLE}.customer_segment ;;
    link: {
      url: "/dashboards/retail_block_model_v2::customer_segment_deepdive?Customer%20Segment={{value | encode_uri}}&Date%20Range={{ _filters['transactions.date_comparison_filter'] | url_encode }}"
      label: "Drill into {{rendered_value}}"
    }
  }

  #  To avoid _filters warning in link:
  dimension: customer_segment_basic_dim {
    hidden: yes
    type: string
    sql: ${TABLE}.customer_segment ;;
  }
}
