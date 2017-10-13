connection: "bq-looker-datablocks"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.


explore: geo {
  from: bq_logrecno_bg_map

  join: tract_zcta_map {
    from: bq_tract_zcta_map
    sql_on: ${geo.geoid11} = ${tract_zcta_map.geoid11};;
    relationship: many_to_one
  }

  join: zcta_distances {
    from: bq_zcta_distances
    sql_on: ${tract_zcta_map.ZCTA5} = ${zcta_distances.zip2} ;;
    relationship: one_to_one
    required_joins: [tract_zcta_map]
  }
}
