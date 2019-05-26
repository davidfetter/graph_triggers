CREATE OR REPLACE FUNCTION edge_remove(old_node_start INTEGER, old_node_end INTEGER)
RETURNS SETOF tc
LANGUAGE SQL
AS $$
WITH suspect (node_start, node_end) AS (
    SELECT x.node_start, y.node_end
    FROM
        tc x
    JOIN
        tc y
        ON (x.node_end, y.node_start) =
           (old_node_start, old_node_end)
UNION
    SELECT node_start, old_node_end
    FROM tc
    WHERE node_end = old_node_start
UNION
    SELECT old_node_start, node_end
    FROM tc
    WHERE node_start = old_node_end
UNION
    SELECT old_node_start, old_node_end
    FROM tc
    WHERE (node_start, node_end) = (old_node_start, old_node_end)
),
trusty (node_start, node_end) AS (
    SELECT *
    FROM  tc
    WHERE NOT EXISTS (
        SELECT 1
        FROM suspect
        WHERE
            (tc.node_start, tc.node_end) =
            (suspect.node_start, suspect.node_end)
    )
UNION
    SELECT *
    FROM edge
    WHERE
        node_start <> old_node_start AND
        node_end <> old_node_end
)
    SELECT * FROM trusty
UNION
    SELECT t1.node_start, t2.node_end
    FROM trusty t1 JOIN trusty t2
    ON t1.node_end = t2.node_start
UNION
    SELECT t1.node_start, t3.node_end
    FROM
        trusty t1
    JOIN
        trusty t2
        ON (t1.node_end = t2.node_start)
    JOIN
        trusty t3
        ON (t2.node_end = t3.node_start)
$$;
