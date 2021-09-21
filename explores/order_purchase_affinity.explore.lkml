include: "/views/*.view"

explore: order_purchase_affinity {
  label: "(3) Item Affinity 🔗"
  view_label: "Item Affinity"

  always_filter: {
    filters: {
      field: affinity_timeframe
      value: "last 90 days"
    }
    filters: {
      field: order_items_base.product_level
      value: "product"
    }
  }

  join: order_items_base {}

  join: total_orders {
    type: cross
    relationship: many_to_one
  }
}
