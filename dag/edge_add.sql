CREATE OR REPLACE FUNCTION edge_add(new_node_start INTEGER, new_node_end INTEGER)
RETURNS SETOF tc
LANGUAGE SQL
AS $$
WITH tc_new (node_start, node_end) AS (
    SELECT tc.node_start, new_node_end
    FROM tc
    WHERE node_end = new_node_start
UNION
    SELECT new_node_start, node_end
    FROM tc
    WHERE new_node_end = node_start
UNION
    SELECT tc1.node_start, tc2.node_end
    FROM
        tc tc1
    JOIN
        tc tc2
        ON (tc1.node_end, tc2.node_start) = 
           (new_node_start, new_node_end)
UNION
    SELECT new_node_start, new_node_end
)
SELECT *
FROM tc_new
WHERE NOT EXISTS (
    SELECT 1 FROM tc
    WHERE
        (tc_new.node_start, tc_new.node_end) =
        (tc_new.node_start, tc.node_end)
    )
$$;
