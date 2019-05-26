CREATE TABLE tc (
    node_start INTEGER NOT NULL,
    node_end INTEGER NOT NULL,
    CHECK(node_start <> node_end)
);
