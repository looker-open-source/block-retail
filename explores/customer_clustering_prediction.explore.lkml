include: "/views/*.view"

explore: customer_clustering_prediction {
  hidden: yes
  label: "(4) Customer Segments 👤"
  fields: [customer_clustering_prediction.customer_segment_basic_dim]
}
